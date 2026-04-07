#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

OBJECTIVE="By the end of this level, you should:

- Provision storage vaults and ledger databases for each district dynamically
- Deploy the audit database only when there is more than one district
- Store state remotely in a GCS backend following best practices so the Guild can collaborate
- Resolve all TODOs in the code and successfully run tofu apply"

DOCS_URL="https://dynatrace-oss.github.io/open-ecosystem-challenges/02-building-cloudhaven/beginner"

print_header \
  'Challenge 02: Building CloudHaven' \
  'Level 1: The Foundation Stones' \
  'Smoke Test Verification'

check_prerequisites curl jq tofu

print_sub_header "Running smoke tests..."

# Track test results across all checks
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

# =============================================================================
# Run all checks
# =============================================================================

# Check 1: State bucket
check_gcp_bucket_exists "cloudhaven-tfstate" "state" \
  "The state bucket should be created by state.tf"
print_new_line

# Check 2: Backend is configured
check_tofu_backend_configured "gcs" "$SCRIPT_DIR"
print_new_line

check_gcp_bucket_versioning "cloudhaven-tfstate" "state bucket" \
  "Enable versioning on the state bucket for recovery from accidents"
print_new_line

# Check 3: District vaults
check_gcp_bucket_exists "cloudhaven-north-market-vault" "North Market vault" \
  "Use for_each to create a vault for each district in var.districts"
print_new_line

check_gcp_bucket_exists "cloudhaven-south-bazaar-vault" "South Bazaar vault" \
  "Use for_each to create a vault for each district in var.districts"
print_new_line

# Check 4: District ledgers
check_gcp_sql_instance_exists "cloudhaven-north-market-ledger" "North Market ledger" \
  "Use for_each to create a ledger for each district in var.districts"
print_new_line

check_gcp_sql_instance_exists "cloudhaven-south-bazaar-ledger" "South Bazaar ledger" \
  "Use for_each to create a ledger for each district in var.districts"
print_new_line

# Check 5: Audit database
check_gcp_sql_instance_exists "cloudhaven-merchant-audit" "Audit" \
  "The audit database should be created when there is more than 1 district (check the enabled condition)"
print_new_line

# =============================================================================
# Print summary
# =============================================================================

print_test_summary "the foundation stones" "$DOCS_URL" "$OBJECTIVE"
