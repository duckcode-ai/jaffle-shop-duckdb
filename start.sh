#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ ! -x "node_modules/.bin/dql" ] || [ ! -f "target/manifest.json" ]; then
  echo "Run ./setup.sh first." >&2
  exit 1
fi

exec npx dql notebook . --port "${DQL_PORT:-3474}"
