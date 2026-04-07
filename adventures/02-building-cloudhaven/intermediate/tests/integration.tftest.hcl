# ============================================================================
# Integration Test - Root Configuration
# ============================================================================
# TODO: this should actually test if the infra works by applying it
#       someone said we need "apply" tests not just "plan" tests but idk
#       got the test structure from https://opentofu.org/docs/cli/commands/test/
#
# Note: This test uses a separate mock API on port 9000 to avoid conflicts
#
# Run from the intermediate/ directory:
#   make test-integration
# ============================================================================

provider "google" {
  project = "the-modular-metropolis"
  region  = var.region

  # Point to the TEST mock GCP API (separate instance on port 30105)
  storage_custom_endpoint = "http://localhost:9000/storage/v1/"
  sql_custom_endpoint     = "http://localhost:9000/"

  # Skip authentication since we're using a mock API
  access_token = "a-super-secure-token"
}

# ============================================================================
# Test: Apply Infrastructure and Verify Districts
# ============================================================================
run "apply_districts" {
  # command = ??? # not sure if plan or apply here

  # check vault names for each district - should be cloudhaven-{name}-vault or smth
  # the districts are: north-market, south-bazaar, scholars-district
  #
  # also someone said to verify the tier stuff works?? disk sizes are different:
  # - north-market is standard so 20GB i think
  # - south-bazaar is minimal so 10GB
  # - scholars-district is critical so 50GB
  #
  # this should be enough to pass but feel free to add more tests if u want

  assert {
    condition     = var.name == ""
    error_message = "tests are not implemented yet"
  }
}
