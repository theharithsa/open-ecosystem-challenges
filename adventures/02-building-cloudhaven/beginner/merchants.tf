# ============================================================================
# CloudHaven Infrastructure - Merchant Districts
# ============================================================================
# This configuration provisions infrastructure for the merchant districts
# defined in variables.tf.
#
# Each district requires:
# - A storage vault (bucket) for storing merchant goods
# - A ledger database for tracking inventory
#
# TODO: sooo this should create a vault AND ledger for each district but i only
#       got it working for one. heard something about for_each? leaving this for
#       the next person, good luck lol
# ============================================================================

# ----------------------------------------------------------------------------
# Storage Vaults (Buckets)
# One per district, used for storing merchant goods
# ----------------------------------------------------------------------------
resource "google_storage_bucket" "vault" {
  name                        = "cloudhaven-${each.key}-vault"
  location                    = "EU"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age                = 90
      with_state         = "ARCHIVED"
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }

  soft_delete_policy {
    retention_duration_seconds = 604800 # 7 days
  }

  labels = {
    district    = each.key
    purpose     = "merchant-storage"
    managed-by  = "opentofu"
    environment = "cloudhaven"
  }
}

# ----------------------------------------------------------------------------
# Ledger Databases
# One per district, used for tracking merchant inventory
# ----------------------------------------------------------------------------
resource "google_sql_database_instance" "ledger" {
  name             = "cloudhaven-${each.key}-ledger"
  database_version = "POSTGRES_15"
  region           = "europe-west1"

  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"
    disk_size         = 10
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 4 # 4 AM
      update_track = "stable"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/cloudhaven/global/networks/default"
    }

    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    user_labels = {
      district    = each.key
      purpose     = "merchant-ledger"
      managed-by  = "opentofu"
      environment = "cloudhaven"
    }
  }

  deletion_protection = true
}

