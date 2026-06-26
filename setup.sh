#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"
DB_PATH="${DBT_DUCKDB_PATH:-jaffle_shop.duckdb}"
PYTHON_BIN="${PYTHON:-python3}"

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "${PYTHON_BIN} is required but was not found on PATH." >&2
  exit 1
fi

PYTHON_VERSION="$("$PYTHON_BIN" - <<'PY'
import sys
print(f"{sys.version_info.major}.{sys.version_info.minor}")
PY
)"

PYTHON_SUPPORTED="$("$PYTHON_BIN" - <<'PY'
import sys
print(int((3, 9) <= sys.version_info[:2] < (3, 14)))
PY
)"

if [ "$PYTHON_SUPPORTED" != "1" ]; then
  cat >&2 <<EOF
Python ${PYTHON_VERSION} is not supported by this dbt-DuckDB setup.

Use Python 3.9 through 3.13. If your default python3 is newer, run:
  PYTHON=python3.13 ./setup.sh

Or install Python 3.13 first, for example:
  brew install python@3.13
EOF
  exit 1
fi

echo "Creating local Python virtual environment..."
"$PYTHON_BIN" -m venv .venv

echo "Installing Python dependencies..."
.venv/bin/python -m pip install --upgrade pip --progress-bar off
.venv/bin/python -m pip install -r requirements.txt --progress-bar off

# Always land on the newest published DataLex CLI, even when re-running over an
# existing .venv (a plain -r install does not upgrade a requirement already met).
echo "Ensuring the latest DataLex CLI (with serve + DuckDB + AI providers)..."
.venv/bin/python -m pip install --upgrade \
  'datalex-cli[serve,duckdb,draft,draft-openai]' --progress-bar off

echo "Installing dbt packages..."
.venv/bin/dbt deps --profiles-dir .

echo "Loading seed data into local DuckDB..."
.venv/bin/dbt seed --full-refresh --profiles-dir .

echo "Building and testing dbt models..."
.venv/bin/dbt build --profiles-dir . --exclude resource_type:seed

echo "Generating dbt docs and lineage artifacts..."
.venv/bin/dbt docs generate --profiles-dir .

# DataLex layer. datalex-cli is installed from requirements.txt into the same
# venv, so the manifest is always built with the latest DataLex CLI.
echo "Validating the DataLex contract pack (models, terms, contracts)..."
.venv/bin/datalex datalex validate DataLex
echo "Building the DataLex manifest..."
.venv/bin/datalex datalex manifest build DataLex --out "$ROOT_DIR/DataLex/datalex-manifest.json"

# DQL layer. This needs Node 20-22. It is optional: if Node is not present we
# print the manual steps instead of failing the whole setup.
DQL_READY=0
if [ "${SKIP_DQL:-0}" = "1" ]; then
  echo "Skipping the DQL layer (SKIP_DQL=1)."
elif command -v npm >/dev/null 2>&1; then
  NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
  if [ "$NODE_MAJOR" -ge 20 ] && [ "$NODE_MAJOR" -lt 23 ]; then
    echo "Setting up the DQL layer (installing the latest dql-cli)..."
    # --no-save keeps package.json pinned to "latest"; the explicit @latest
    # install forces an upgrade even when node_modules already has an older one.
    ( cd "$ROOT_DIR/dql" \
        && npm install --no-audit --no-fund \
        && npm install @duckcodeailabs/dql-cli@latest --no-save --no-audit --no-fund \
        && npx dql validate \
        && npx dql app build )
    DQL_READY=1
  else
    echo "Found Node ${NODE_MAJOR}.x, but DQL needs Node 20-22. Skipping the DQL layer."
  fi
else
  echo "Node/npm not found, skipping the DQL layer."
fi

cat <<'EOF'

Setup complete.
EOF

cat <<EOF
Local database: ${DB_PATH}
Raw seed schema: raw
Model schema: dev
Docs artifacts: target/manifest.json and target/catalog.json
DataLex manifest: DataLex/datalex-manifest.json
EOF

if [ "$DQL_READY" = "1" ]; then
  cat <<EOF

DQL is ready. Launch the notebook + Growth Command Center App:
  cd dql && npm run notebook     # http://127.0.0.1:3474

Or serve dbt docs and lineage:
  source .venv/bin/activate && dbt docs serve --profiles-dir .
EOF
else
  cat <<EOF

To finish the DQL layer (needs Node 20-22):
  cd dql && npm install && npx dql validate && npx dql app build && npm run notebook

Or serve dbt docs and lineage:
  source .venv/bin/activate && dbt docs serve --profiles-dir .
EOF
fi

cat <<EOF

This setup already pulled the latest DataLex + DQL. To refresh them later
without a full re-run (or with: task upgrade):
  .venv/bin/python -m pip install -U 'datalex-cli[serve,duckdb,draft,draft-openai]'
  cd dql && npm install @duckcodeailabs/dql-cli@latest --no-save

DataLex AI generation (proposals/contracts from dbt evidence) needs an API key.
Set one in the DataLex AI Setup panel, or export ANTHROPIC_API_KEY / OPENAI_API_KEY
before running 'datalex serve' or 'datalex draft'. Ollama also works locally.
EOF
