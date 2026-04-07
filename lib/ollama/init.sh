#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# Deploy Ollama to Kubernetes with TinyLlama model pre-loaded

echo "✨ Adding Ollama Helm repo"
helm repo add otwld https://helm.otwld.com/
helm repo update

echo "✨ Installing Ollama via Helm"
helm install ollama otwld/ollama \
  --version 1.40.0 \
  --namespace ollama --create-namespace \
  --values "$SCRIPT_DIR/values.yaml" \
  --wait \
  --timeout 10m

echo "✨ Waiting for Ollama to be ready"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=ollama -n ollama --timeout=300s

echo "✅ Ollama is ready with TinyLlama model"
