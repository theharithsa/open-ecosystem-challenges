#!/usr/bin/env bash

# kyverno.sh - Shared library for Kyverno policy checks

# Check that a policy flags a resource as a violation (using kyverno apply).
# Works for both Audit and Deny policies — the CLI tests rules regardless of action mode.
# Reads resource YAML from stdin.
# Usage: check_kyverno_violation "policy-file" "display name" "hint" <<EOF ... EOF
check_kyverno_violation() {
  local policy_file=$1
  local display_name=$2
  local hint=$3

  local tmpfile
  tmpfile=$(mktemp --suffix=.yaml)
  cat > "$tmpfile"

  print_test_section "Checking $display_name is flagged as a policy violation..."

  if ! kyverno apply "$policy_file" --resource "$tmpfile" &>/dev/null; then
    print_success_indent "$display_name is correctly flagged as a violation"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "$display_name was not flagged — check the policy rules"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("kyverno_violation:$display_name")
  fi
  rm -f "$tmpfile"
}

# Check that a policy does NOT flag a resource as a violation (using kyverno apply).
# Reads resource YAML from stdin.
# Usage: check_kyverno_no_violation "policy-file" "display name" "hint" <<EOF ... EOF
check_kyverno_no_violation() {
  local policy_file=$1
  local display_name=$2
  local hint=$3

  local tmpfile
  tmpfile=$(mktemp --suffix=.yaml)
  cat > "$tmpfile"

  print_test_section "Checking $display_name passes the policy..."

  if kyverno apply "$policy_file" --resource "$tmpfile" &>/dev/null; then
    print_success_indent "$display_name correctly passes the policy"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "$display_name was incorrectly flagged as a violation"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("kyverno_no_violation:$display_name")
  fi
  rm -f "$tmpfile"
}
