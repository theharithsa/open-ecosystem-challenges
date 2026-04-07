# ============================================================================
# CloudHaven Infrastructure - Variables
# ============================================================================
# This file defines the merchant districts for CloudHaven:
# - North Market: The bustling northern trading hub
# - South Bazaar: The vibrant southern marketplace
#
# Districts can be enabled/disabled individually using the `enabled` flag.
# ============================================================================

variable "districts" {
  description = "Map of merchant districts for CloudHaven"
  type = map(object({
    name        = string
    description = string
    enabled     = bool
  }))
  default = {
    north-market = {
      name        = "North Market"
      description = "The bustling northern trading hub"
      enabled     = true
    }
    south-bazaar = {
      name        = "South Bazaar"
      description = "The vibrant southern marketplace"
      enabled     = true
    }
  }
}
