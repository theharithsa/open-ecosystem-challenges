# ============================================================================
# Makefile for Blind by Design - Intermediate Level: Outcome by cohort
# ============================================================================
# This Makefile provides convenient commands for running the Spring Boot lab
# in different country cohorts and verifying your solution.
# ============================================================================

.PHONY: help lab lab-germany lab-austria probe verify

# Default target - show help
help:
	@echo "Blind by Design - Intermediate Level: Outcome by cohort"
	@echo ""
	@echo "Application:"
	@echo "  make lab            - Start the lab with no COUNTRY (no targeting branch fires)"
	@echo "  make lab-germany    - Start the lab with COUNTRY=de (exercises the country branch)"
	@echo "  make lab-austria    - Start the lab with COUNTRY=at (no targeting branch fires)"
	@echo "  make probe          - Hit the lab as a zyklop subject and pretty-print the response"
	@echo ""
	@echo "Verification:"
	@echo "  make verify         - Run verification checks"

# ----------------------------------------------------------------------------
# Application Targets
# ----------------------------------------------------------------------------

lab:
	@./mvnw spring-boot:run | tee app.log

lab-germany:
	@./run-germany.sh

lab-austria:
	@./run-austria.sh

probe:
	@curl -s 'http://localhost:8080/?species=zyklop' | jq

# ----------------------------------------------------------------------------
# Verification Targets
# ----------------------------------------------------------------------------

verify:
	@./verify.sh
