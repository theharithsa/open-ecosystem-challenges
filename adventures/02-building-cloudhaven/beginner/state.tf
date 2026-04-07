# ============================================================================
# Remote State Backend Bucket
# ============================================================================
# This file creates the GCS bucket used to store OpenTofu remote state.
# ============================================================================

resource "google_storage_bucket" "tfstate" {
  name     = "cloudhaven-tfstate"
  location = "EU"

  # Prevent accidental deletion of the state bucket
  force_destroy = false

  # Use Standard storage class for frequently accessed state files
  storage_class = "STANDARD"

  # TODO: should we enable versioning? sounds important for state files but
  #       wasn't sure how to do it... look into this later maybe

  # Uniform bucket-level access for simplified permissions
  uniform_bucket_level_access = true

  # Lifecycle rules to manage old state versions
  lifecycle_rule {
    condition {
      num_newer_versions = 10
      with_state         = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 90
    }
    action {
      type = "Delete"
    }
  }

  # Soft delete policy for recovery from accidental deletions
  soft_delete_policy {
    retention_duration_seconds = 604800 # 7 days
  }

  # Labels for organization and cost tracking
  labels = {
    environment = "cloudhaven"
    purpose     = "tfstate"
    managed_by  = "opentofu"
  }
}
