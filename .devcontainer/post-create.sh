#!/usr/bin/env bash
set -euo pipefail

lib/shared/init.sh

echo "→ Installing mkdocs-material..."
pip install --quiet mkdocs-material mkdocs-monorepo-plugin

echo "✓ Done! Run 'mkdocs serve' to start the docs server."

