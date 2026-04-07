# ============================================================================
# CloudHaven Infrastructure - Outputs
# ============================================================================
# These outputs expose resource information for other systems
# and team members to consume.
# ============================================================================

output "districts" {
  description = "Infrastructure details for each district"
  value = {
    for k, v in google_storage_bucket.vault : k => {
      vault = {
        name = v.name
        url  = v.url
      }
      ledger = {
        connection_name    = google_sql_database_instance.ledger[k].connection_name
        private_ip_address = google_sql_database_instance.ledger[k].private_ip_address
        database_version   = google_sql_database_instance.ledger[k].database_version
      }
    }
  }
}

