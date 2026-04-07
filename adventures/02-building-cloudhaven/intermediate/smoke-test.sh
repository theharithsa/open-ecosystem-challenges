#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

OBJECTIVE="By the end of this level, you should have:

- All tests of the districts module pass
- A completed integration test that applies infrastructure against the mock GCP API
- Three districts deployed with correctly configured infrastructure (vaults and ledgers)"

DOCS_URL="https://dynatrace-oss.github.io/open-ecosystem-challenges/02-building-cloudhaven/intermediate"

print_header \
  'Challenge 02: Building CloudHaven' \
  'Level 2: The Modular Metropolis' \
  'Smoke Test Verification'

check_prerequisites curl jq tofu

print_sub_header "Running smoke tests..."

# Track test results across all checks
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

# =============================================================================
# Check 1: District module tests pass
# =============================================================================
print_test_section "Running district module tests..."

cd "$SCRIPT_DIR/modules/district"
if tofu test > /dev/null 2>&1; then
  print_success_indent "All district module tests pass"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  print_error_indent "District module tests are failing"
  print_hint "Run 'make test-district' to see which tests fail and fix the bugs"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILED_CHECKS+=("district_module_tests")
fi
cd "$SCRIPT_DIR"
print_new_line

# =============================================================================
# Check 2: Integration test passes
# =============================================================================
print_test_section "Running integration tests..."

# Start the test mock server
docker run -d -p 9000:8080 --name gcp-api-mock-test ghcr.io/katharinasick/gcp-api-mock:v1.1.4 > /dev/null 2>&1 || true
sleep 2

if tofu test > /dev/null 2>&1; then
  print_success_indent "Integration test passes"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  print_error_indent "Integration test is failing"
  print_hint "Complete the tests/integration.tftest.hcl file"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILED_CHECKS+=("integration_test")
fi

# Stop the test mock server
docker stop gcp-api-mock-test > /dev/null 2>&1 || true
docker rm gcp-api-mock-test > /dev/null 2>&1 || true
print_new_line

# =============================================================================
# Check 3: All three district vaults exist
# =============================================================================
check_gcp_bucket_exists "cloudhaven-north-market-vault" "North Market vault" \
  "Run 'make apply' to deploy the infrastructure"
print_new_line

check_gcp_bucket_exists "cloudhaven-south-bazaar-vault" "South Bazaar vault" \
  "Run 'make apply' to deploy the infrastructure"
print_new_line

check_gcp_bucket_exists "cloudhaven-scholars-district-vault" "Scholars District vault" \
  "Run 'make apply' to deploy the infrastructure"
print_new_line

# =============================================================================
# Check 4: All three district ledgers exist
# =============================================================================
check_gcp_sql_instance_exists "cloudhaven-north-market-ledger" "North Market ledger" \
  "Run 'make apply' to deploy the infrastructure" "the-modular-metropolis"
print_new_line

check_gcp_sql_instance_exists "cloudhaven-south-bazaar-ledger" "South Bazaar ledger" \
  "Run 'make apply' to deploy the infrastructure" "the-modular-metropolis"
print_new_line

check_gcp_sql_instance_exists "cloudhaven-scholars-district-ledger" "Scholars District ledger" \
  "Run 'make apply' to deploy the infrastructure" "the-modular-metropolis"
print_new_line

# =============================================================================
# Print summary
# =============================================================================

print_test_summary "the modular metropolis" "$DOCS_URL" "$OBJECTIVE"
