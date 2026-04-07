#!/usr/bin/env bash
# tracker.sh - Helper functions for sending bizevents to Dynatrace via codespace-tracker
# This script provides reusable functions for observability tracking across all adventures

# Load tracking context from rc file (set by set_tracking_context)
# shellcheck disable=SC1090
[[ -f ~/.bashrc ]] && source ~/.bashrc

TRACKER_URL="https://grzxx1q7wd.execute-api.us-east-1.amazonaws.com/default/codespace-tracker"
EVENT_TYPE="open-ecosystem-challenges"

# -----------------------------------------------------------------------------
# Set tracking context (persists to rc files for all scripts)
# Usage: set_tracking_context "02-building-cloudhaven" "beginner"
# -----------------------------------------------------------------------------
set_tracking_context() {
  local adventure=$1
  local level=$2

  export ADVENTURE="$adventure"
  export LEVEL="$level"

  echo "export ADVENTURE=\"$adventure\"" >> ~/.bashrc
  echo "export ADVENTURE=\"$adventure\"" >> ~/.zshrc
  echo "export LEVEL=\"$level\"" >> ~/.bashrc
  echo "export LEVEL=\"$level\"" >> ~/.zshrc
}

# -----------------------------------------------------------------------------
# Send an event to Dynatrace
# Usage: send_event "event.action" '{"extra": "fields"}'
# -----------------------------------------------------------------------------
send_event() {
  local action=$1
  local extra_fields=${2:-"{}"}

  # Build the payload using jq for proper JSON handling
  local payload
  payload=$(jq -n \
    --arg event_type "$EVENT_TYPE" \
    --arg action "$action" \
    --arg adventure "${ADVENTURE:-unknown}" \
    --arg level "${LEVEL:-unknown}" \
    --arg github_user "${GITHUB_USER:-unknown}" \
    --arg github_repo "${GITHUB_REPOSITORY:-unknown}" \
    --arg codespace_id "${CODESPACE_NAME:-local}" \
    --argjson extra "$extra_fields" \
    '{
      "type": $event_type,
      "action": $action,
      "adventure": $adventure,
      "level": $level,
      "github.user": $github_user,
      "github.repo": $github_repo,
      "codespace.id": $codespace_id
    } + $extra'
  )

  # Send to tracker API (silent, don't fail the script)
  curl -sS -X POST "$TRACKER_URL" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    >/dev/null 2>&1 || true
}

# -----------------------------------------------------------------------------
# Event: codespace.created
# Send when codespace starts provisioning (post-create.sh)
# -----------------------------------------------------------------------------
track_codespace_created() {
  send_event "codespace.created"
}

# -----------------------------------------------------------------------------
# Event: codespace.initialized
# Send when environment is ready (post-start.sh)
# -----------------------------------------------------------------------------
track_codespace_initialized() {
  send_event "codespace.initialized"
}

# -----------------------------------------------------------------------------
# Event: smoketest.completed
# Send when smoke test finishes
# Usage: track_smoketest_completed "success" '["check1","check2"]'
# -----------------------------------------------------------------------------
track_smoketest_completed() {
  local status=$1
  local failed_checks=${2:-"[]"}

  send_event "smoketest.completed" "$(jq -n \
    --arg status "$status" \
    --argjson failed_checks "$failed_checks" \
    '{status: $status, failed_checks: $failed_checks}'
  )"
}

track_verification_completed() {
  local status=$1
  local failed_checks=${2:-"[]"}

  send_event "verification.completed" "$(jq -n \
    --arg status "$status" \
    --argjson failed_checks "$failed_checks" \
    '{status: $status, failed_checks: $failed_checks}'
  )"
}
