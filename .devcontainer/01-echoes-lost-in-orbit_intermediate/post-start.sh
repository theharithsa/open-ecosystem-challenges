#!/usr/bin/env bash
set -e

echo "✨ Starting level 2 - Intermediate"

REPO_URL="https://github.com/${GITHUB_REPOSITORY}.git"
sed -i "s|__REPO_URL__|${REPO_URL}|g" adventures/01-echoes-lost-in-orbit/intermediate/manifests/appset.yaml

kubectl apply -n argocd -f adventures/01-echoes-lost-in-orbit/intermediate/manifests/appset.yaml

# Give ArgoCD some time to process the ApplicationSet and create the Rollout application
sleep 10

# Update podinfo image to trigger a rollout
sed -i 's|podinfo:6.8.0|podinfo:6.9.3|g' adventures/01-echoes-lost-in-orbit/intermediate/manifests/base/rollout.yaml
git add adventures/01-echoes-lost-in-orbit/intermediate/manifests/base/rollout.yaml
git commit -m "Update podinfo image to 6.9.3"
git push

# Refresh ArgoCD to pick up the new commit
argocd app get echo-server-staging --refresh
argocd app get echo-server-prod --refresh

# Track that the environment is ready
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "echoes-lost-in-orbit" "intermediate" "01" "12" "2025"
track_container_initialized

lib/argo-rollouts/connect.sh