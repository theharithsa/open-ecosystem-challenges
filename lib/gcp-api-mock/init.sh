#!/usr/bin/env bash
set -e

echo "✨ Starting the GCP API Mock"
docker run -d -p 30104:8080 ghcr.io/katharinasick/gcp-api-mock:v1.1.4

# Set environment variable to redirect GCS backend requests to the mock
echo 'export STORAGE_EMULATOR_HOST="http://localhost:30104"' >> ~/.bashrc
echo 'export STORAGE_EMULATOR_HOST="http://localhost:30104"' >> ~/.zshrc
export STORAGE_EMULATOR_HOST="http://localhost:30104"

echo "✅ GCP API Mock is ready"