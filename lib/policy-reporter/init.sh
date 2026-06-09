#!/usr/bin/env bash
set -e

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    Policy Reporter Helm chart version to install (required)"
}

version=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      help
      exit 0
      ;;
    --version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --version requires a value" >&2
        exit 1
      fi
      version="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$version" ]]; then
  echo "Error: --version is required" >&2
  exit 1
fi

echo "✨ Installing Policy Reporter"
helm repo add policy-reporter https://kyverno.github.io/policy-reporter
helm repo update
helm install policy-reporter policy-reporter/policy-reporter \
  --namespace policy-reporter \
  --create-namespace \
  --version "$version" \
  --set ui.enabled=true \
  --set ui.service.type=NodePort \
  --wait

echo "✨ Waiting for Policy Reporter to be ready"
kubectl rollout status deployment/policy-reporter -n policy-reporter --timeout=300s

echo "✨ Pinning Policy Reporter UI to NodePort 30110"
# The chart template does not expose a nodePort value, so we patch after install
kubectl patch svc policy-reporter-ui -n policy-reporter \
  --type='json' \
  -p='[{"op":"replace","path":"/spec/ports/0/nodePort","value":30110}]'

echo "✅ Policy Reporter is ready (UI: http://localhost:30110)"
