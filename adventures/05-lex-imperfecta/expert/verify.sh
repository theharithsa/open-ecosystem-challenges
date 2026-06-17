#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

set_tracking_context "lex-imperfecta" "expert" "05" "06" "2026"

OBJECTIVE="By the end of this level, you should have:

- The Praetorian Guard awake: Falco fires an alert every time an unauthorized process reads the census archive, with live alerts streaming into the Falcosidekick UI
- The gate closed: the intruder is denied re-admission; the policy that kept privileged containers out now covers every path to unchecked host power
- The archive sealed: the census-archive secret is inaccessible to any workload that does not bear the Archivist role
- The empire-wide laws holding: all intermediate-level checks still green across every province"

DOCS_URL="https://offon.dev/adventures/lex-imperfecta/levels/expert"

print_header \
  'Challenge 05: Lex Imperfecta' \
  'Level 03: Quis Custodiet' \
  'Verification'

# Init test counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

check_prerequisites kubectl jq

print_sub_header "Running verification checks..."

# =============================================================================
# Objective 1: Empire-wide laws still hold (regression from intermediate)
# =============================================================================
print_new_line
print_sub_header "1. Checking the empire-wide laws still hold..."

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

check_admission_blocked \
  "Privileged workload in a province (no exception)" \
  "What does the Senate forbid in the provinces, no matter who is asking?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-privileged-no-exception
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

check_admission_blocked \
  "Non-scribe workload in Aegyptus" \
  "Aegyptus admits only one kind of workload — is its local law still in force there?" <<'EOF'
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

# =============================================================================
# Objective 2: The gate is closed — the policy covers capabilities, not just privileged
# =============================================================================
print_new_line
print_sub_header "2. Checking that the policy covers dangerous capabilities..."

check_admission_blocked \
  "Pod with a dangerous capability in a province" \
  "Look at what the intruder is carrying — and what the policy currently checks." <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-cap-sysadmin
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
        capabilities:
          add: ["SYS_ADMIN"]
EOF

check_admission_blocked \
  "Pod with another dangerous capability in a province" \
  "Does the policy cover all the ways a container can acquire elevated power?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-cap-netadmin
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
        privileged: false
        capabilities:
          add: ["NET_ADMIN"]
EOF

check_admission_allowed \
  "Pod with no dangerous capabilities in a province" \
  "A workload with no elevated capabilities should still be admitted — make sure the policy is not over-reaching." <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-cap-none
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
# Objective 3: The archive is sealed — census-archive mount is restricted
# =============================================================================
print_new_line
print_sub_header "3. Checking that the census archive is sealed..."

check_admission_blocked \
  "Pod mounting census-archive without the Archivist role" \
  "What distinguishes a workload that should have access from one that should not?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-census-mount-no-role
  namespace: gallia
  labels:
    republic.rome/gens: verus
    republic.rome/province: gallia
spec:
  volumes:
    - name: archive
      secret:
        secretName: census-archive
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
      volumeMounts:
        - name: archive
          mountPath: /run/secrets/census-archive
EOF

check_admission_allowed \
  "Pod mounting census-archive with the Archivist role" \
  "A workload bearing the Archivist seal should be permitted to access the census rolls." <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-census-mount-archivist
  namespace: gallia
  labels:
    republic.rome/gens: verus
    republic.rome/province: gallia
    republic.rome/role: archivist
spec:
  volumes:
    - name: archive
      secret:
        secretName: census-archive
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
      volumeMounts:
        - name: archive
          mountPath: /run/secrets/census-archive
EOF

check_admission_blocked \
  "Pod mounting census-archive under a different volume name" \
  "A volume has a name, and it has a reference to what it actually contains — which one does your policy inspect?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-census-mount-renamed
  namespace: gallia
  labels:
    republic.rome/gens: verus
    republic.rome/province: gallia
spec:
  volumes:
    - name: definitely-not-census
      secret:
        secretName: census-archive
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
      volumeMounts:
        - name: definitely-not-census
          mountPath: /run/secrets/census-archive
EOF

# =============================================================================
# Objective 4: The Praetorian Guard is awake — Falco rule is in place
# (Phase 2: Falco alert verification via Falcosidekick events API)
# =============================================================================
print_new_line
print_sub_header "4. Checking that the Praetorian Guard is awake (Falco)..."

check_falco_alert \
  "census archive read" \
  "Praetorian Guard - Census Archive Read" \
  "The guard can only report what it has been told to watch — does the rule cover the right syscall and the right path?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: falco-tripwire
  namespace: gallia
  labels:
    republic.rome/gens: verus
    republic.rome/province: gallia
    republic.rome/role: archivist
spec:
  restartPolicy: Never
  containers:
    - name: tripwire
      image: busybox:stable
      command: ["cat", "/run/secrets/census-archive/registrations"]
      securityContext:
        privileged: false
      volumeMounts:
        - name: archive
          mountPath: /run/secrets/census-archive
  volumes:
    - name: archive
      secret:
        secretName: census-archive
EOF

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

check_submission_readiness "05-lex-imperfecta" "expert"
