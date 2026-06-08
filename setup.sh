#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"
DB_PATH="${DBT_DUCKDB_PATH:-jaffle_shop.duckdb}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required but was not found on PATH." >&2
  exit 1
fi

echo "Creating local Python virtual environment..."
python3 -m venv .venv

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
