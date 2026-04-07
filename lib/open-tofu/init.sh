#!/usr/bin/env bash
set -e

echo "✨ Installing Open Tofu"

curl -LO "https://github.com/opentofu/opentofu/releases/download/v1.11.2/tofu_1.11.2_linux_amd64.zip"
unzip "tofu_1.11.2_linux_amd64.zip" tofu
chmod +x tofu
sudo mv tofu /usr/local/bin/tofu
rm -f "tofu_1.11.2_linux_amd64.zip"
tofu version

echo "✅ Open Tofu is ready"