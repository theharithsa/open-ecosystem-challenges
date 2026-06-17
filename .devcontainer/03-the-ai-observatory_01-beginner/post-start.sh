#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/03-the-ai-observatory/beginner"

echo "✨ Starting The AI Observatory - Beginner Level"

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install -r "$CHALLENGE_DIR/requirements.txt" --quiet

# Track that the environment is ready
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker-legacy.sh"
set_tracking_context "03-the-ai-observatory" "beginner"
track_codespace_initialized