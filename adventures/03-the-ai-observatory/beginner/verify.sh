#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

OBJECTIVE="By the end of this level, you should:

- Enable OpenTelemetry instrumentation for the HubSystem using OpenLLMetry
- Send OpenLLMetry traces to the local collector at http://localhost:30107
- See and analyze traces in Jaeger to find out what causes the high bandwidth usage
- Provide the correct answer in quiz.txt"

DOCS_URL="https://dynatrace-oss.github.io/open-ecosystem-challenges/03-the-ai-observatory/beginner"

print_header \
  'Challenge 03: The AI Observatory' \
  'Level 1: Calibrating the Lens' \
  'Verification'

# Init test counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

check_prerequisites python3 curl jq

print_sub_header "Running verification checks..."

# 1) Static Code Check
check_file_contains "hubsystem.py" "Traceloop" "OpenLLMetry instrumentation" \
  "Did you import and initialize Traceloop in hubsystem.py?"
print_new_line

# 2) Runtime Verification (Jaeger Traces)
check_jaeger_traces "hubsystem.py" "HubSystem traces are present" \
  "No traces found. Did you run the app and chat with it? (make hubsystem)"
print_new_line

# 3) Quiz Check
# Base64 encoded answer to avoid spoilers in the script
EXPECTED_ANSWER=$(echo "U2FuY3R1YXJ5IE1vb24=" | base64 -d)
check_file_contains "quiz.txt" "$EXPECTED_ANSWER" "Quiz answer" \
  "Check the traces in Jaeger for the hidden prompt content" "true"
print_new_line

# =============================================================================
# Summary & Next Steps
# =============================================================================

# Build failed checks JSON array
failed_checks_json="[]"
if [[ -n "${FAILED_CHECKS[*]:-}" ]]; then
  failed_checks_json=$(printf '%s\n' "${FAILED_CHECKS[@]}" | jq -R . | jq -s .)
fi

if [[ $TESTS_FAILED -gt 0 ]]; then
  # Track failure
  track_verification_completed "failed" "$failed_checks_json"

  print_verification_summary "the ai observatory" "$DOCS_URL" "$OBJECTIVE"
  exit 1
fi

# Track success
track_verification_completed "success" "$failed_checks_json"

# Success!
print_header "Test Results Summary"
print_success "✅ PASSED: All $TESTS_PASSED verification checks passed!"
print_new_line

# Run submission readiness checks
check_submission_readiness "03-the-ai-observatory" "beginner"
