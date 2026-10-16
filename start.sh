#!/usr/bin/env bash
# Start the ZLens workbench for this sample (same as `npm run notebook`).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ ! -x "node_modules/.bin/zlens" ] || [ ! -f "jaffle_shop.duckdb" ] || [ ! -f "target/manifest.json" ]; then
  echo "Run ./setup.sh first (or the steps in README.md)." >&2
  exit 1
fi

exec npx zlens notebook . --port "${ZLENS_PORT:-3474}"
