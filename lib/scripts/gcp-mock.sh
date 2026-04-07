#!/usr/bin/env bash

# gcp-mock.sh - Helper functions for GCP API Mock verification
# These functions verify resources created via OpenTofu against the GCP mock API

GCP_MOCK_URL="${GCP_MOCK_URL:-http://localhost:30104}"

# -----------------------------------------------------------------------------
# Check if a GCS bucket exists
# Usage: check_gcp_bucket_exists "bucket-name" "Display Name" "Hint message"
# -----------------------------------------------------------------------------
check_gcp_bucket_exists() {
  local bucket_name=$1
  local display_name=$2
  local hint=$3

  print_test_section "Checking $display_name bucket..."

  if curl -sf "$GCP_MOCK_URL/storage/v1/b/$bucket_name" > /dev/null 2>&1; then
    print_success_indent "$display_name bucket exists: $bucket_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "$display_name bucket not found: $bucket_name"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_gcp_bucket_exists:$bucket_name")
  fi
}

# -----------------------------------------------------------------------------
# Check if a Cloud SQL instance exists
# Usage: check_gcp_sql_instance_exists "instance-name" "Display Name" "Hint message"
# -----------------------------------------------------------------------------
check_gcp_sql_instance_exists() {
  local instance_name=$1
  local display_name=$2
  local hint=$3
  local project="${4:-cloudhaven-infrastructure}"

  print_test_section "Checking $display_name database..."

  if curl -sf "$GCP_MOCK_URL/sql/v1beta4/projects/$project/instances/$instance_name" > /dev/null 2>&1; then
    print_success_indent "$display_name database exists: $instance_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "$display_name database not found: $instance_name"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_gcp_sql_instance_exists:$instance_name")
  fi
}

# -----------------------------------------------------------------------------
# Check if bucket versioning is enabled
# Usage: check_gcp_bucket_versioning "bucket-name" "Display Name" "Hint message"
# -----------------------------------------------------------------------------
check_gcp_bucket_versioning() {
  local bucket_name=$1
  local display_name=$2
  local hint=$3

  print_test_section "Checking $display_name versioning..."

  local versioning
  versioning=$(curl -sf "$GCP_MOCK_URL/storage/v1/b/$bucket_name" 2>/dev/null | jq -r '.versioning.enabled // false' 2>/dev/null) || versioning="false"

  if [[ "$versioning" == "true" ]]; then
    print_success_indent "$display_name has versioning enabled"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "$display_name does not have versioning enabled"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_gcp_bucket_versioning:$bucket_name")
  fi
}

# -----------------------------------------------------------------------------
# Check if OpenTofu backend is configured
# Usage: check_tofu_backend_configured "backend-type" "working-dir"
# -----------------------------------------------------------------------------
check_tofu_backend_configured() {
  local expected_backend=$1
  local working_dir=${2:-.}

  print_test_section "Checking remote state backend..."

  local backend_type=""
  if [[ -f "$working_dir/.terraform/terraform.tfstate" ]]; then
    backend_type=$(jq -r '.backend.type // empty' "$working_dir/.terraform/terraform.tfstate" 2>/dev/null || echo "")
  fi

  if [[ "$backend_type" == "$expected_backend" ]]; then
    print_success_indent "$expected_backend backend is configured"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "$expected_backend backend is not configured"
    print_hint "Configure the backend block in main.tf and run 'tofu init -migrate-state'"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_tofu_backend_configured:$expected_backend")
  fi
}

