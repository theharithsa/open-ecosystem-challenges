#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

echo "✨ Creating otel namespace"
kubectl create namespace otel || true

echo "✨ Deploying OTEL Collector manifests"
kubectl apply -n otel -f "$SCRIPT_DIR/manifests/"

echo "✨ Waiting for OTEL Collector to be ready"
kubectl rollout status deployment/collector -n otel --timeout=120s

echo "✅ OTEL Collector is ready"
