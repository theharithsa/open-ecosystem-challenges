#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "lex-imperfecta" "intermediate" "05" "06" "2026"
track_container_created

"$REPO_ROOT/lib/shared/init.sh" --version v0.17.0
"$REPO_ROOT/lib/kubernetes/init.sh" \
  --kind-version v0.32.0 \
  --kubectl-version v1.36.1 \
  --kubens-version v0.11.0 \
  --k9s-version v0.50.18 \
  --helm-version v4.2.0
"$REPO_ROOT/lib/kyverno/init.sh" --version 3.8.1 --cli-version v1.18.1
"$REPO_ROOT/lib/policy-reporter/init.sh" --version 3.7.4
