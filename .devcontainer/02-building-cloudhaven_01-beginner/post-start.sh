#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/02-building-cloudhaven/beginner"

echo "✨ Starting level 1 - Beginner"

cd "$CHALLENGE_DIR"
tofu init

# Track that the environment is ready
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker-legacy.sh"
track_codespace_initialized

