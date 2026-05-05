# ============================================================================
# Makefile for Blind by Design - Beginner Level: Stand up the lab
# ============================================================================
# This Makefile provides convenient commands for running
# the Spring Boot lab and verifying your solution.
# ============================================================================

.PHONY: help lab probe verify

# Default target - show help
help:
	@echo "Blind by Design - Beginner Level: Stand up the lab"
	@echo ""
	@echo "Application:"
	@echo "  make lab                       - Start the Spring Boot lab on :8080"
	@echo "  make probe                     - Hit the lab endpoint and pretty-print the response"
	@echo ""
	@echo "Verification:"
	@echo "  make verify                    - Run verification checks"

# ----------------------------------------------------------------------------
# Application Targets
# ----------------------------------------------------------------------------

lab:
	@./mvnw spring-boot:run

probe:
	@curl -s http://localhost:8080/ | jq

# ----------------------------------------------------------------------------
# Verification Targets
# ----------------------------------------------------------------------------

verify:
	@./verify.sh
