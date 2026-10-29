#!/usr/bin/env bash
# One-command setup for the Jaffle Shop ZLens sample.
#
# It runs the same steps as the README, in order:
#   1. a Python virtual environment with dbt-duckdb
#   2. dbt deps, seed and build  -> jaffle_shop.duckdb + target/manifest.json
#   3. npm install (the ZLens CLI, @zlens/cli) and the DuckDB driver
#   4. zlens sync dbt, model validate and app build
# It is safe to rerun.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

PYTHON_BIN="${PYTHON:-python3}"
# Leave empty to use the version in package.json; set to try another release,
# for example ZLENS_VERSION=latest ./setup.sh
ZLENS_VERSION="${ZLENS_VERSION:-}"

export DBT_SEND_ANONYMOUS_USAGE_STATS="${DBT_SEND_ANONYMOUS_USAGE_STATS:-false}"

python_supported() {
  "$1" - <<'PY' 2>/dev/null
import sys
print(int((3, 9) <= sys.version_info[:2] < (3, 15)))
PY
}

# dbt-duckdb runs on Python 3.9-3.14 (3.14 tested with dbt-core 1.12). When
# python3 is outside that range and no interpreter was chosen, use an installed
# supported one.
if [ -z "${PYTHON:-}" ] && { ! command -v "$PYTHON_BIN" >/dev/null 2>&1 || [ "$(python_supported "$PYTHON_BIN")" != "1" ]; }; then
  for candidate in python3.14 python3.13 python3.12 python3.11 python3.10 python3.9; do
    if command -v "$candidate" >/dev/null 2>&1; then
      PYTHON_BIN="$candidate"
      break
    fi
  done
fi

require_command() {
  local command="$1" hint="$2"
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing required command: $command" >&2
    echo "$hint" >&2
    exit 1
  fi
}

require_command "$PYTHON_BIN" "Install Python 3.9–3.13 (3.14 also works), or run PYTHON=python3.13 ./setup.sh"
require_command node "Install Node.js 20 or newer from https://nodejs.org/"
require_command npm "Install npm with Node.js 20 or newer from https://nodejs.org/"

if [ "$(python_supported "$PYTHON_BIN")" != "1" ]; then
  echo "$("$PYTHON_BIN" --version 2>&1) is not supported by dbt-duckdb. Use Python 3.9–3.14, for example PYTHON=python3.13 ./setup.sh" >&2
  exit 1
fi

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
if [ "$NODE_MAJOR" -lt 20 ]; then
  echo "Node ${NODE_MAJOR}.x is not supported. Use Node.js 20 or newer." >&2
  exit 1
fi

# A virtual environment left behind by an unsupported Python cannot run dbt.
if [ -x ".venv/bin/python" ] && [ "$(python_supported .venv/bin/python)" != "1" ]; then
  echo "Recreating .venv with $PYTHON_BIN (the existing one uses an unsupported Python)…"
  rm -rf .venv
fi

echo "[1/4] Creating the Python environment with dbt-duckdb…"
if [ ! -x ".venv/bin/python" ]; then
  "$PYTHON_BIN" -m venv .venv
fi
.venv/bin/python -m pip install --quiet --upgrade pip --progress-bar off
.venv/bin/python -m pip install --quiet -r requirements.txt --progress-bar off

# dbt builds the database with DuckDB 1.4, which every ZLens release reads
# (current ZLens reads up to DuckDB 1.5). An older setup may have installed
# DuckDB 2.0 into .venv, and a file written by 2.0 cannot be opened by 1.4
# ("version number 999 ... created with an newer version of DuckDB").
DUCKDB_PIN='duckdb>=1.4,<1.5'
if ! .venv/bin/python -c 'import sys, duckdb; sys.exit(0 if duckdb.__version__.startswith("1.4.") else 1)' 2>/dev/null; then
  echo "Reinstalling DuckDB 1.4 in .venv (the version ZLens reads)…"
  .venv/bin/python -m pip install --quiet --force-reinstall "$DUCKDB_PIN" --progress-bar off
fi
echo "Using DuckDB $(.venv/bin/python -c 'import duckdb; print(duckdb.__version__)') for dbt."

# Set aside a database written by a newer DuckDB; dbt rebuilds it below.
DB_FILE="${DBT_DUCKDB_PATH:-jaffle_shop.duckdb}"
if [ -f "$DB_FILE" ]; then
  db_status="$(.venv/bin/python - "$DB_FILE" <<'PY' 2>/dev/null || true
import sys, duckdb
try:
    duckdb.connect(sys.argv[1], read_only=True).close()
    print("ok")
except Exception as err:
    print("newer" if "newer version of DuckDB" in str(err) else "other")
PY
)"
  if [ "$db_status" = "newer" ]; then
    OLD_DB="${DB_FILE%.duckdb}.from-newer-duckdb.duckdb"
    echo "$DB_FILE was written by a newer DuckDB that ZLens cannot read. Moving it to $OLD_DB and rebuilding it with DuckDB 1.4…"
    mv -f "$DB_FILE" "$OLD_DB"
    if [ -f "$DB_FILE.wal" ]; then mv -f "$DB_FILE.wal" "$OLD_DB.wal"; fi
  fi
fi

echo "[2/4] Building the Jaffle Shop dbt project (DuckDB)…"
.venv/bin/dbt deps --profiles-dir .
.venv/bin/dbt seed --full-refresh --profiles-dir .
.venv/bin/dbt build --profiles-dir . --exclude resource_type:seed
.venv/bin/dbt docs generate --profiles-dir .

echo "[3/4] Installing ZLens and the DuckDB driver…"
npm install --no-package-lock --no-audit --no-fund
if [ -n "$ZLENS_VERSION" ]; then
  npm install --no-save --no-package-lock --no-audit --no-fund "@zlens/cli@${ZLENS_VERSION}"
fi
# ZLens's DuckDB driver, on the DuckDB 1.5 line (npm's latest is 2.0, whose
# files 1.x cannot read). No install script runs and nothing is compiled.
npm install --prefix .dql/connectors --no-package-lock --no-audit --no-fund '@duckdb/node-api@^1.5.6-r.1'

echo "[4/4] Importing the dbt project into ZLens…"
npx zlens --version
npx zlens sync dbt .
npx zlens model validate .
npx zlens app build .
npx zlens doctor . || echo "zlens doctor reported a problem above; the sample may still run. See README.md → Troubleshooting."

cat <<'EOF'

Setup complete.

  DuckDB database: jaffle_shop.duckdb
  dbt manifest:    target/manifest.json
  ZLens manifest:  dql-manifest.json

Next:
  npm run notebook

The workbench opens at http://127.0.0.1:3474. Start with:
  • Apps → Jaffle Growth Review
  • Lineage → monthly_revenue
  • Notebooks → welcome → Run all

See README.md for the guided tour.
EOF
