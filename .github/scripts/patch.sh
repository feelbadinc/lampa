#!/bin/bash

set -euo pipefail

MANIFEST="_source/src/core/manifest.js"
PLUGINS="_source/src/core/plugins.js"

if [ ! -f "$MANIFEST" ]; then
  echo "manifest.js not found, skipping patch"
else
  export MANIFEST
  node -e "
    const fs = require('fs');
    const manifest = process.env.MANIFEST;
    fs.writeFileSync(manifest, fs.readFileSync(manifest, 'utf8').replace(
      /('github_lampa',\s*\{)\s*get:\s*\(\)\s*=>[\s\S]*?(?=,?\s*(set:|}\s*\)))/,
      \"\$1 get: () => './'\"
    ));
  "
  echo "Patched manifest.js"
fi

disable_blacklist=$(jq -r '.disable_features.blacklist // false' \
  "$GITHUB_WORKSPACE/settings.json" 2>/dev/null || echo "false")

if [ "$disable_blacklist" = "true" ]; then
  if [ ! -f "$PLUGINS" ]; then
    echo "plugins.js not found, skipping patch"
  else
    sed -i '/black_list\.push(/d' "$PLUGINS"
    echo "Patched plugins.js"
  fi
fi
