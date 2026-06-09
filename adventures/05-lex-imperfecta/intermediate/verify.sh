#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

set_tracking_context "lex-imperfecta" "intermediate" "05" "06" "2026"

OBJECTIVE="By the end of this level, you should have:

- Empire-wide laws enforcing across every province: no privileged containers, every workload carries a valid gens and a province matching its namespace, scoped by namespace label rather than hardcoded names
- Aegyptus's scribe law applying only within Aegyptus, admitting scribe workloads exclusively
- The legacy exception scoped to Aegyptus's grandfathered workload and cannot be claimed by any other province
- The Tabularium's ledger on file: policy reports exported in OpenReports format as \`estate-audit.yaml\`"

DOCS_URL="https://offon.dev/adventures/lex-imperfecta/levels/intermediate"

# The estate audit the player files with the Tabularium (player-generated, never shipped)
LEDGER_FILE="$SCRIPT_DIR/estate-audit.yaml"

print_header \
  'Challenge 05: Lex Imperfecta' \
  'Level 02: Governing the Provinces' \
  'Verification'

# Init test counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

check_prerequisites kubectl jq

print_sub_header "Running verification checks..."

# =============================================================================
# Objective 1: The empire-wide laws enforce correctly across every province
# =============================================================================
print_new_line
print_sub_header "1. Checking the empire-wide laws across the provinces..."

check_admission_blocked \
  "Workload with no gens in a province" \
  "Every citizen counted in the census must declare something about themselves — does this one?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-census-no-gens
  namespace: gallia
  labels:
    republic.rome/province: gallia
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_blocked \
  "Workload whose declared province does not match its namespace" \
  "The census cross-checks where a workload claims to belong against where it actually runs." <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-census-mismatch
  namespace: gallia
  labels:
    republic.rome/gens: verus
    republic.rome/province: hispania
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_allowed \
  "Fully-registered workload in a province" \
  "A compliant citizen should pass freely — make sure the census is not turning away the well-behaved." <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-census-compliant
  namespace: gallia
  labels:
    republic.rome/gens: verus
    republic.rome/province: gallia
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_blocked \
  "Privileged workload in a province" \
  "What does the Senate forbid in the provinces, no matter who is asking?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-privileged
  namespace: britannia
  labels:
    republic.rome/gens: verus
    republic.rome/province: britannia
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: true
EOF

check_file_contains \
  "$SCRIPT_DIR/manifests/policies/require-census.yaml" \
  "republic.rome/realm" \
  "require-census scopes to provinces by label, not by hardcoded namespace names" \
  "The census should use the namespace labels to decide where it applies — what label do the province namespaces carry?"

check_file_not_contains \
  "$SCRIPT_DIR/manifests/policies/require-census.yaml" \
  "kubernetes.io/metadata.name" \
  "require-census does not hardcode individual namespace names" \
  "Listing namespace names explicitly is fragile — what would happen if a new province were added?"

check_admission_blocked \
  "Workload with no gens in Hispania" \
  "The census should reach every province — are there any it is not covering?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-census-hispania
  namespace: hispania
  labels:
    republic.rome/province: hispania
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_allowed \
  "Privileged workload in the infra realm" \
  "The infra realm lies outside the provinces' jurisdiction — empire-wide laws should not reach into it." <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-privileged-infra
  namespace: castra
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: true
EOF

# =============================================================================
# Objective 2: Aegyptus's scribe law takes effect only within Aegyptus
# =============================================================================
print_new_line
print_sub_header "2. Checking the reach of Aegyptus's provincial law..."

check_kyverno_violation \
  "$SCRIPT_DIR/manifests/policies/aegyptus-require-scribe-role.yaml" \
  "Non-scribe workload in Aegyptus" \
  "Aegyptus admits only scribes — does its local law correctly identify workloads that are out of order?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-aegyptus-non-scribe
  namespace: aegyptus
  labels:
    republic.rome/gens: verus
    republic.rome/province: aegyptus
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_allowed \
  "Scribe workload in Aegyptus" \
  "A proper Aegyptus scribe is fully in order — something may be turning it away that should not." <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-aegyptus-scribe
  namespace: aegyptus
  labels:
    republic.rome/gens: verus
    republic.rome/province: aegyptus
    republic.rome/role: scribe
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_allowed \
  "Non-scribe workload in another province (Gallia)" \
  "A law enacted for Aegyptus should have no say over Gallia — does it reach further than it should?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-gallia-non-scribe
  namespace: gallia
  labels:
    republic.rome/gens: verus
    republic.rome/province: gallia
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

# =============================================================================
# Objective 3: The legacy exception is scoped to Aegyptus alone
# =============================================================================
print_new_line
print_sub_header "3. Checking the reach of the legacy exception..."

check_admission_allowed \
  "Grandfathered legacy workload in Aegyptus" \
  "Aegyptus's grandfathered scribes hold a Senate exception — is it honoured where it belongs?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-aegyptus-legacy
  namespace: aegyptus
  labels:
    republic.rome/legacy: "true"
    republic.rome/province: aegyptus
    republic.rome/role: scribe
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_blocked \
  "Workload claiming legacy status in another province (Hispania)" \
  "An exception granted to Aegyptus's legacy scribes — should a workload in another province be able to invoke it?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-hispania-legacy
  namespace: hispania
  labels:
    republic.rome/legacy: "true"
    republic.rome/province: hispania
    republic.rome/role: scribe
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_blocked \
  "Non-legacy workload missing its gens in Aegyptus" \
  "The exception is only for the grandfathered — does a workload that never declared itself legacy deserve it?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-aegyptus-non-legacy
  namespace: aegyptus
  labels:
    republic.rome/province: aegyptus
    republic.rome/role: scribe
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

# =============================================================================
# Objective 4: The Tabularium's ledger is clean and on file
# =============================================================================
print_new_line
print_sub_header "4. Checking that the estate audit has been filed..."

check_file_exists \
  "$LEDGER_FILE" \
  "The Tabularium's ledger (estate-audit.yaml) is on file" \
  "The Senate needs the audit on file — export the estate's policy reports in the OpenReports format to estate-audit.yaml (see How to Play)."

# =============================================================================
# Summary & Next Steps
# =============================================================================
failed_checks_json="[]"
if [[ -n "${FAILED_CHECKS[*]:-}" ]]; then
  failed_checks_json=$(printf '%s\n' "${FAILED_CHECKS[@]}" | jq -R . | jq -s .)
fi

if [[ $TESTS_FAILED -gt 0 ]]; then
  track_verification_completed "failed" "$failed_checks_json"
  print_verification_summary "lex-imperfecta" "$DOCS_URL" "$OBJECTIVE"
  exit 1
fi

track_verification_completed "success" "$failed_checks_json"

print_header "Test Results Summary"
print_success "✅ PASSED: All $TESTS_PASSED verification checks passed!"
print_new_line

check_submission_readiness "05-lex-imperfecta" "intermediate"
