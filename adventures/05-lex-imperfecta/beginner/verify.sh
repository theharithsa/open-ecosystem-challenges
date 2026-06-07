#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

set_tracking_context "lex-imperfecta" "beginner" "05" "06" "2026"

OBJECTIVE="By the end of this level, you should have:

- All workloads missing the 'republic.rome/gens' label blocked at admission with a clear policy violation message
- All workloads running as privileged containers blocked at admission with a clear policy violation message
- All pods declaring 'republic.rome/traveler: peregrinus' automatically receiving the 'republic.rome/travel-permit: granted' label
- Confirmed that all other workloads deploy and run successfully in the cluster"

DOCS_URL="https://offon.dev/adventures/lex-imperfecta/levels/beginner"

print_header \
  'Challenge 05: Lex Imperfecta' \
  'Level 01: The Twelve Tables' \
  'Verification'

# Init test counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

check_prerequisites kubectl

print_sub_header "Running verification checks..."

# =============================================================================
# Objective 1: Workloads missing republic.rome/gens label are blocked
# =============================================================================
print_new_line
print_sub_header "1. Checking that unlabelled workloads are blocked..."

check_admission_blocked \
  "Pod without republic.rome/gens label" \
  "Check the 'require-labels' policy — what happens when a violation is detected?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-no-label
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_allowed \
  "Pod with republic.rome/gens label" \
  "Check the 'require-labels' policy — is the label pattern correct?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-with-label
  labels:
    republic.rome/gens: forum-romanum
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF



# =============================================================================
# Objective 2: Workloads running as privileged containers are blocked
# =============================================================================
print_new_line
print_sub_header "2. Checking that privileged workloads are blocked..."

check_admission_blocked \
  "Pod with privileged container" \
  "Check the 'no-privileged-containers' policy — does the deny condition cover regular containers?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-privileged
  labels:
    republic.rome/gens: castra-praetoria
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: true
EOF

check_admission_blocked \
  "Pod with privileged init container" \
  "Check the 'no-privileged-containers' policy — does the deny condition cover init containers?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-privileged-init
  labels:
    republic.rome/gens: castra-praetoria
spec:
  initContainers:
    - name: init
      image: busybox:stable
      command: ["sh", "-c", "exit 0"]
      securityContext:
        privileged: true
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_allowed \
  "Pod with non-privileged container" \
  "Check the 'no-privileged-containers' policy — is the deny condition correct?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-non-privileged
  labels:
    republic.rome/gens: forum-romanum
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF



# =============================================================================
# Objective 3: Peregrini receive a travel permit via mutation
# =============================================================================
print_new_line
print_sub_header "3. Checking that peregrini receive a travel permit..."

check_label_exists \
  "Peregrinus pod" \
  "republic.rome/travel-permit" \
  "granted" \
  "Check the 'stamp-travel-permit' policy — what does the mutation expression add?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-peregrinus
  labels:
    republic.rome/gens: forum-romanum
    republic.rome/traveler: peregrinus
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_label_not_exists \
  "Non-peregrinus pod" \
  "republic.rome/travel-permit" \
  "Check the 'stamp-travel-permit' policy — does the matchCondition target only peregrini?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-citizen
  labels:
    republic.rome/gens: forum-romanum
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF



# =============================================================================
# Objective 4: Compliant workloads deploy and run successfully
# =============================================================================
print_new_line
print_sub_header "4. Checking that compliant workloads are admitted..."

check_admission_allowed \
  "Fully compliant pod (label + non-privileged)" \
  "Check both policies — does the pod carry the required label and run without elevated privileges?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-compliant
  labels:
    republic.rome/gens: forum-romanum
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

# =============================================================================
# Summary & Next Steps
# =============================================================================
failed_checks_json="[]"
if [[ -n "${FAILED_CHECKS[*]:-}" ]]; then
  failed_checks_json=$(printf '%s\n' "${FAILED_CHECKS[@]}" | jq -R . | jq -s .)
fi

if [[ $TESTS_FAILED -gt 0 ]]; then
  # Track failure
  track_verification_completed "failed" "$failed_checks_json"

  print_verification_summary "lex-imperfecta" "$DOCS_URL" "$OBJECTIVE"
  exit 1
fi

# Track success
track_verification_completed "success" "$failed_checks_json"

# Success!
print_header "Test Results Summary"
print_success "✅ PASSED: All $TESTS_PASSED verification checks passed!"
print_new_line

# Run submission readiness checks
check_submission_readiness "05-lex-imperfecta" "beginner"
