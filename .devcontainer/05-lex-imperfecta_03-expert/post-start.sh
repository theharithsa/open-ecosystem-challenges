#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/05-lex-imperfecta/expert"

echo "✨ Starting Lex Imperfecta - Expert Level"

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

echo "📜  Deploying census archive..."
kubectl apply -f "$CHALLENGE_DIR/manifests/secrets/"

echo "⚖️  Applying policies..."
kubectl apply -f "$CHALLENGE_DIR/manifests/policies/"

echo "📋  Applying exceptions..."
kubectl apply -f "$CHALLENGE_DIR/manifests/exceptions/"

echo "🦅  Loading Falco rules..."
helm upgrade falco falcosecurity/falco \
  --namespace falco \
  --reuse-values \
  --set-file 'customRules.praetorian-guard\.yaml='"$CHALLENGE_DIR/falco-rules.yaml" \
  --wait > /dev/null

echo "🧹  Clearing Falcosidekick event history..."
kubectl exec -n falco falcosidekick-ui-redis-0 -- redis-cli FLUSHALL > /dev/null
kubectl rollout restart deployment/falcosidekick-ui -n falco > /dev/null
kubectl rollout status deployment/falcosidekick-ui -n falco --timeout=60s > /dev/null

echo "🏟️  Deploying workloads..."
# The intruder (speculator) is among these. Some workloads may be blocked
# by a misconfigured exception — open Falcosidekick UI at http://localhost:30111
# and Policy Reporter at http://localhost:30110 to begin your investigation.
kubectl apply -f "$CHALLENGE_DIR/manifests/workloads/" 2>&1 || true

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "lex-imperfecta" "expert" "05" "06" "2026"
track_container_initialized

echo ""
echo "🏛️  The estate is deployed."
echo ""
echo "   Policy Reporter:   http://localhost:30110"
echo "   Falcosidekick UI:  http://localhost:30111"
echo ""
echo "   The intruder is already in the estate. The Guard sees nothing."
echo "   Run 'make verify' to check your progress."
echo ""
