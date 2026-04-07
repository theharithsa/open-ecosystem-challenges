#!/usr/bin/env bash
set -e

lib/shared/init.sh
lib/kubernetes/init.sh
lib/argocd/init.sh --read-only
lib/argo-rollouts/init.sh
lib/kube-state-metrics/init.sh
lib/prometheus/init.sh