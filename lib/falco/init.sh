#!/usr/bin/env bash
set -e

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help                        Display this help message"
  echo " --falco-version <ver>         Falco Helm chart version to install (required)"
  echo " --falcosidekick-version <ver> Falcosidekick Helm chart version to install (required)"
}

falco_version=""
falcosidekick_version=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      help
      exit 0
      ;;
    --falco-version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --falco-version requires a value" >&2
        exit 1
      fi
      falco_version="$2"
      shift 2
      ;;
    --falcosidekick-version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --falcosidekick-version requires a value" >&2
        exit 1
      fi
      falcosidekick_version="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$falco_version" ]]; then
  echo "Error: --falco-version is required" >&2
  exit 1
fi

if [[ -z "$falcosidekick_version" ]]; then
  echo "Error: --falcosidekick-version is required" >&2
  exit 1
fi

helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falcosidekick first so the service endpoint exists when Falco starts.
# The webui (with its Redis backend) is exposed as a NodePort and patched to 30111.
echo "✨ Installing Falcosidekick + UI"
helm install falcosidekick falcosecurity/falcosidekick \
  --namespace falco \
  --create-namespace \
  --version "$falcosidekick_version" \
  --set webui.enabled=true \
  --set webui.service.type=NodePort \
  --set webui.disableauth=true \
  --wait

echo "✨ Pinning Falcosidekick UI to NodePort 30111"
kubectl patch svc falcosidekick-ui -n falco \
  --type='json' \
  -p='[{"op":"replace","path":"/spec/ports/0/nodePort","value":30111}]'

# Install Falco with the modern eBPF driver (no kernel headers required).
# JSON output is routed to Falcosidekick via HTTP so alerts appear in the UI.
echo "✨ Installing Falco (modern eBPF)"
helm install falco falcosecurity/falco \
  --namespace falco \
  --version "$falco_version" \
  --set driver.kind=modern_ebpf \
  --set falco.json_output=true \
  --set falco.http_output.enabled=true \
  --set falco.http_output.url=http://falcosidekick.falco.svc.cluster.local:2801 \
  --wait

echo "✨ Waiting for Falco DaemonSet to be ready"
kubectl rollout status daemonset/falco -n falco --timeout=300s

echo "✅ Falco is ready (Falcosidekick UI: http://localhost:30111)"
