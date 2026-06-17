#!/usr/bin/env bash

# Deploy a manifest from stdin, wait for Falco to process the resulting
# syscall events, then assert the named rule fired in Falco's output.
# Cleans up the deployed manifest afterwards.
#
# Usage: check_falco_alert "display name" "Exact Falco Rule Name" "hint" <<'EOF'
#   <pod or workload manifest that triggers the rule>
# EOF
check_falco_alert() {
  local display_name=$1
  local rule_name=$2
  local hint=$3
  local wait_seconds=${4:-10}

  local manifest
  manifest=$(cat)

  print_test_section "Checking Falco detects: $display_name..."

  echo "$manifest" | kubectl apply -f - >/dev/null 2>&1

  sleep "$wait_seconds"

  local found=false
  if kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco --since=60s 2>/dev/null \
      | grep -qF "\"rule\":\"${rule_name}\""; then
    found=true
  fi

  echo "$manifest" | kubectl delete -f - --ignore-not-found >/dev/null 2>&1 &

  if [[ "$found" == "true" ]]; then
    print_success_indent "Falco rule '${rule_name}' fired correctly"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "Falco rule '${rule_name}' did not fire"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("falco_alert:${display_name}")
  fi
}
