#!/usr/bin/env bash

# Print a styled header with multiple lines
# Usage: print_header "Line 1" "Line 2" "Line 3"
print_header() {
  gum style \
    --foreground 212 --border-foreground 212 --border double \
    --align center --width 60 --margin "1 0" --padding "1 2" \
    "$@"
}

# Print a styled subheader
# Usage: print_sub_header "Subheader text"
print_sub_header() {
  gum style --foreground 212 --bold "$@"
  echo ""
}

# Print success message
# Usage: print_success "Success message"
print_success() {
  gum style --foreground 120 "$@"
}

# Print error message
# Usage: print_error "Error message"
print_error() {
  gum style --foreground 196 "$@"
}

# Print info message
# Usage: print_info "Info message"
print_info() {
  gum style --foreground 246 "$@"
}

# Print warning message
# Usage: print_warning "Warning message"
print_warning() {
  gum style --foreground 214 "$@"
}

# Print indented success message
# Usage: print_success_indent "Message"
print_success_indent() {
  gum style --foreground 120 "  ✓ $*"
}

# Print indented error message
# Usage: print_error_indent "Message"
print_error_indent() {
  gum style --foreground 196 "  ❌ $*"
}

# Print indented info message
# Usage: print_info_indent "Message"
print_info_indent() {
  gum style --foreground 246 "  $*"
}

# Print indented hint message
# Usage: print_hint "Hint message"
print_hint() {
  gum style --foreground 246 "  💡 Hint: $*"
}

# Print test step message
# Usage: print_step "Step message"
print_step() {
  gum style --foreground 246 "  ⏳ $*"
}

# Print test section header
# Usage: print_test_section "Section name"
print_test_section() {
  gum style --bold "🔬 $*"
}

# Print a new line
# Usage: print_new_line
print_new_line() {
  echo ""
}

print_test_summary() {
  local level=$1
  local docs_url=$2
  local objective=$3

  # Build failed checks JSON array (handle empty array with set -u)
  local failed_checks_json="[]"
  if [[ -n "${FAILED_CHECKS[*]:-}" ]]; then
    failed_checks_json=$(printf '%s\n' "${FAILED_CHECKS[@]}" | jq -R . | jq -s .)
  fi

  print_header "Test Results Summary"

  if [[ $TESTS_FAILED -eq 0 ]]; then
    # Track success
    track_smoketest_completed "success" "$failed_checks_json"

    # test succeeded
    print_success "✅ PASSED: All $TESTS_PASSED checks passed"
    print_new_line
    print_info "It looks like you successfully completed this level! 🌟"

    print_info "Next steps:"
    print_info_indent "1. Commit your changes: git add . && git commit -m 'Solved Challenge'"
    print_info_indent "2. Push to main: git push origin main"
    print_info_indent "3. Manually trigger the 'Verify Adventure' workflow on GitHub Actions"
    print_info_indent "4. Once verified, share your success with the community! 🎉"
    print_new_line
    print_info "📖 For detailed verification instructions, see: https://dynatrace-oss.github.io/open-ecosystem-challenges/verification/"
    exit
  fi

  # Track failure
  track_smoketest_completed "failed" "$failed_checks_json"

  # test failed
  print_error "❌ FAILED: $TESTS_FAILED check(s) failed, $TESTS_PASSED passed"
  print_new_line
  gum style --bold "🎯 Challenge Objective:"
  print_info "$objective"
  print_new_line
  print_info "See $DOCS_URL for details"
}

# Verification summary tailored for local-only verification
# Behavior:
# - Always reports pass/fail based on TESTS_* counters
# - If passed and HEAD is pushed: print a copy-paste instruction message
# - If passed and not pushed: instruct user to commit & push, then rerun
# - If failed: print objective and docs URL
print_verification_summary() {
  local level=$1
  local docs_url=$2
  local objective=$3

  print_header "Test Results Summary"

  if [[ $TESTS_FAILED -eq 0 ]]; then
    print_success "✅ PASSED: All $TESTS_PASSED checks passed"
    print_new_line

    # Determine push status (do not fail the test if not pushed)
    local pushed="no"
    if command -v git_is_head_pushed >/dev/null 2>&1 && git_is_head_pushed; then
      pushed="yes"
    fi

    if [[ "$pushed" == "yes" ]]; then
      gum style --bold "📎 Copy & Paste"
      print_info "Your verification passed and changes are pushed. Copy the certificate from the next step and paste it into the Open Ecosystem."
      print_new_line
    else
      gum style --bold "📝 Next Steps"
      print_info "Looks great! Before you can submit, please commit and push all changes, then run the verification again."
      print_info_indent "git add . && git commit -m 'Complete verification' && git push"
      print_new_line
    fi
    return
  fi

  # test failed
  print_error "❌ FAILED: $TESTS_FAILED check(s) failed, $TESTS_PASSED passed"
  print_new_line
  gum style --bold "🎯 Challenge Objective:"
  print_info "$objective"
  print_new_line
  print_info "See $docs_url for details"
}
