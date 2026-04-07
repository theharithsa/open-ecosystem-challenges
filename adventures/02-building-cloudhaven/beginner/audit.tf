# ============================================================================
# CloudHaven Infrastructure - Audit Module
# ============================================================================
# This configuration provisions auditing resources for CloudHaven.
#
# If there is more than one district, we want to create a database to keep
# track of the merchants' activities in each district.
# ============================================================================

# ----------------------------------------------------------------------------
# Audit Database
# One for all districts
# ----------------------------------------------------------------------------

# TODO: hmm the audit db isn't showing up in the plan... the enabled thing
#       looks right to me though?? maybe check the condition idk
resource "google_sql_database_instance" "merchant_audit" {
  lifecycle {
    # OpenTofu 1.11+ 🎉
    # https://opentofu.org/docs/v1.11/language/meta-arguments/enabled/
    enabled = var.districts > 1
  }

  name             = "cloudhaven-merchant-audit"
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
      purpose     = "merchant-audit"
      managed-by  = "opentofu"
      environment = "cloudhaven"
    }
  }

  deletion_protection = true
}

