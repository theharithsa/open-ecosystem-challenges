# ============================================================================
# Makefile for Blind by Design - Expert Level: Read the chart
# ============================================================================
# This Makefile provides convenient commands for running the Spring Boot lab
# alongside the Grafana LGTM stack and verifying your solution.
# ============================================================================

.PHONY: help lab probe verify

# Default target - show help
help:
	@echo "Blind by Design - Expert Level: Read the chart"
	@echo ""
	@echo "Application:"
	@echo "  make lab     - Start the Spring Boot lab on :8080"
	@echo "  make probe   - Hit the lab as a sample subject and pretty-print the response"
	@echo ""
	@echo "Verification:"
	@echo "  make verify  - Run verification checks (lab + flagd + LGTM + dashboard + 5xx-rate)"

# ----------------------------------------------------------------------------
# Application Targets
# ----------------------------------------------------------------------------

lab:
	@./mvnw spring-boot:run

probe:
	@curl -s 'http://localhost:8080/?userId=subject-42' | jq

# ----------------------------------------------------------------------------
# Verification Targets
# ----------------------------------------------------------------------------

verify:
	@./verify.sh
