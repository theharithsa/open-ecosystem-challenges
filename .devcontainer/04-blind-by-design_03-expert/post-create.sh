#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker-legacy.sh"
set_tracking_context "04-blind-by-design" "expert"
track_codespace_created

# gum is used by the verify.sh / output.sh helpers
"$REPO_ROOT/lib/shared/init.sh" --version v0.17.0 # https://github.com/charmbracelet/gum/releases

# jq is needed by verify.sh; the Java devcontainer image is debian-based.
if ! command -v jq >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends jq
fi

CHALLENGE_DIR="$REPO_ROOT/adventures/04-blind-by-design/expert"

# Make the Maven wrapper executable so the participant can just `./mvnw ...`
if [[ -f "$CHALLENGE_DIR/mvnw" ]]; then
  chmod +x "$CHALLENGE_DIR/mvnw"
fi

# Download the OpenTelemetry Java Agent. The Spring Boot Maven Plugin
# attaches it via -javaagent (see expert/pom.xml). One jar per Codespace
# — skip if already present so re-runs are cheap.
OTEL_AGENT_VERSION="v2.27.0"
OTEL_AGENT_DIR="$REPO_ROOT/tools"
OTEL_AGENT_JAR="$OTEL_AGENT_DIR/opentelemetry-javaagent.jar"
mkdir -p "$OTEL_AGENT_DIR"
if [[ ! -f "$OTEL_AGENT_JAR" ]]; then
  echo "⬇️  Downloading OpenTelemetry Java Agent $OTEL_AGENT_VERSION..."
  curl -fsSL \
    -o "$OTEL_AGENT_JAR" \
    "https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/$OTEL_AGENT_VERSION/opentelemetry-javaagent.jar" \
    || echo "⚠️  Failed to fetch the OpenTelemetry Java Agent — traces and metrics will not flow until the jar is present at $OTEL_AGENT_JAR"
fi

echo "✨ Pre-warming the Maven dependency cache so the first ./mvnw is fast..."
( cd "$CHALLENGE_DIR" && ./mvnw -q -DskipTests dependency:go-offline ) || \
  echo "⚠️  Dependency pre-warm skipped (network or wrapper not ready yet)"

echo "✅ Phase 3 toolchain ready (gum + Java 21). flagd / lgtm / loadgen run as sibling devcontainer services."
