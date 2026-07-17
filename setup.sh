#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

PYTHON_BIN="${PYTHON:-python3}"
DQL_VERSION="${DQL_VERSION:-1.7.1}"
DB_PATH="${DBT_DUCKDB_PATH:-jaffle_shop.duckdb}"

# macOS can point python3 at a newer release before dbt supports it. When the
# user did not explicitly choose an interpreter, prefer an installed supported
# version automatically.
if [ -z "${PYTHON:-}" ] && command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  DEFAULT_PYTHON_SUPPORTED="$($PYTHON_BIN - <<'PY'
import sys
print(int((3, 9) <= sys.version_info[:2] < (3, 14)))
PY
)"
  if [ "$DEFAULT_PYTHON_SUPPORTED" != "1" ]; then
    for candidate in python3.13 python3.12 python3.11 python3.10 python3.9; do
      if command -v "$candidate" >/dev/null 2>&1; then
        PYTHON_BIN="$candidate"
        break
      fi
    done
  fi
fi

require_command() {
  local command="$1" hint="$2"
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing required command: $command" >&2
    echo "$hint" >&2
    exit 1
  fi
}

require_command "$PYTHON_BIN" "Install Python 3.9–3.13, or run PYTHON=python3.13 ./setup.sh"
require_command node "Install Node.js 20–22 from https://nodejs.org/"
require_command npm "Install npm with Node.js 20–22 from https://nodejs.org/"

PYTHON_VERSION="$($PYTHON_BIN - <<'PY'
import sys
print(f"{sys.version_info.major}.{sys.version_info.minor}")
PY
)"

PYTHON_SUPPORTED="$($PYTHON_BIN - <<'PY'
import sys
print(int((3, 9) <= sys.version_info[:2] < (3, 14)))
PY
)"

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
if [ "$PYTHON_SUPPORTED" != "1" ]; then
  echo "Python ${PYTHON_VERSION} is not supported. Use Python 3.9–3.13." >&2
  exit 1
fi
if [ "$NODE_MAJOR" -lt 20 ] || [ "$NODE_MAJOR" -gt 22 ]; then
  echo "Node ${NODE_MAJOR}.x is not supported. Use Node 20–22." >&2
  exit 1
fi

echo "[1/5] Creating the local Python environment…"
if [ ! -x ".venv/bin/python" ]; then
  "$PYTHON_BIN" -m venv .venv
fi

echo "[2/5] Installing dbt-DuckDB…"
.venv/bin/python -m pip install --upgrade pip --progress-bar off
.venv/bin/python -m pip install -r requirements.txt --progress-bar off

echo "[3/5] Building the Jaffle Shop dbt project…"
.venv/bin/dbt deps --profiles-dir .
.venv/bin/dbt seed --full-refresh --profiles-dir .
.venv/bin/dbt build --profiles-dir . --exclude resource_type:seed
.venv/bin/dbt docs generate --profiles-dir .

echo "[4/5] Installing DQL ${DQL_VERSION}…"
npm install --no-package-lock --no-audit --no-fund
if [ "$DQL_VERSION" != "1.7.1" ]; then
  npm install --no-save --no-package-lock --no-audit --no-fund "@duckcodeailabs/dql-cli@${DQL_VERSION}"
fi
# DQL keeps optional native database drivers outside the published CLI. This
# local connector gives the notebook, blocks, and Ask AI a real DuckDB runtime.
npm install --prefix .dql/connectors --no-package-lock --no-audit --no-fund "duckdb@^1.1.0"

echo "[5/5] Compiling the DQL domain workspace…"
npx dql doctor .
npx dql compile .
    npx dql model validate .
npx dql app build .

cat <<EOF

Setup complete.

  DuckDB database: ${DB_PATH}
  dbt manifest:    target/manifest.json
  DQL manifest:    dql-manifest.json

Next:
  npm run notebook

Then open http://127.0.0.1:3474 and start with:
  • Domains → Commerce → Model
  • Blocks → Top beverage customers
  • Ask → "Who are the top customers by beverage revenue?"

See README.md for the guided workflow.
EOF
