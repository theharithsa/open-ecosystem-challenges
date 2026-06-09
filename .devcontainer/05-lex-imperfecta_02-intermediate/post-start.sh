#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/05-lex-imperfecta/intermediate"

echo "✨ Starting Lex Imperfecta - Intermediate Level"

echo "🏛️  Creating provinces..."
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: gallia
  labels:
    republic.rome/realm: province
---
apiVersion: v1
kind: Namespace
metadata:
  name: hispania
  labels:
    republic.rome/realm: province
---
apiVersion: v1
kind: Namespace
metadata:
  name: aegyptus
  labels:
    republic.rome/realm: province
---
apiVersion: v1
kind: Namespace
metadata:
  name: britannia
  labels:
    republic.rome/realm: province
---
apiVersion: v1
kind: Namespace
metadata:
  name: castra
  labels:
    republic.rome/realm: infra
EOF

echo "⚖️  Applying policies..."
kubectl apply -f "$CHALLENGE_DIR/manifests/policies/"

echo "📜  Applying exceptions..."
kubectl apply -f "$CHALLENGE_DIR/manifests/exceptions/"

echo "🏟️  Deploying workloads..."
# Some workloads may be blocked by misconfigured policies — this is intentional.
# Open Policy Reporter at http://localhost:30110 to start investigating.
kubectl apply -f "$CHALLENGE_DIR/manifests/workloads/" 2>&1 || true

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "lex-imperfecta" "intermediate" "05" "06" "2026"
track_container_initialized
