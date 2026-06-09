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

echo "Installing dbt packages..."
.venv/bin/dbt deps --profiles-dir .

echo "Loading seed data into local DuckDB..."
.venv/bin/dbt seed --full-refresh --profiles-dir .

echo "Building and testing dbt models..."
.venv/bin/dbt build --profiles-dir . --exclude resource_type:seed

echo "Generating dbt docs and lineage artifacts..."
.venv/bin/dbt docs generate --profiles-dir .

cat <<'EOF'

Setup complete.
EOF

cat <<EOF
Local database: ${DB_PATH}
Raw seed schema: raw
Model schema: dev
Docs artifacts: target/manifest.json and target/catalog.json

Next commands:
  source .venv/bin/activate
  dbt docs serve --profiles-dir .
EOF
