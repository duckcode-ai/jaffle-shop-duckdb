#!/usr/bin/env bash
# One-command setup for the Jaffle Shop + DataLex + DQL example.
#
# Installs and wires all three layers of the DuckCode analytics stack:
#   1. dbt + DuckDB  - transformation layer (builds jaffle_shop.duckdb)
#   2. DataLex       - contract layer       (PyPI: datalex-cli[serve,duckdb])
#   3. DQL           - analytics layer       (npm: @duckcodeailabs/dql-cli)
#
# By default it finishes by launching both local UIs. Skip the launch with
#   ./setup.sh --no-launch        (or LAUNCH=0 ./setup.sh)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

DB_PATH="${DBT_DUCKDB_PATH:-jaffle_shop.duckdb}"
PYTHON_BIN="${PYTHON:-python3}"
LAUNCH="${LAUNCH:-1}"
for arg in "$@"; do
  case "$arg" in
    --no-launch) LAUNCH=0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

section() { printf '\n========== %s ==========\n' "$1"; }

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
section "Checking prerequisites"

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
Python ${PYTHON_VERSION} is not supported by this setup.

Use Python 3.9 through 3.13. If your default python3 is newer, run:
  PYTHON=python3.13 ./setup.sh

Or install Python 3.13 first, for example:
  brew install python@3.13
EOF
  exit 1
fi
echo "Python ${PYTHON_VERSION}: ok"

if ! command -v node >/dev/null 2>&1; then
  cat >&2 <<EOF
Node.js is required for the DQL layer but was not found on PATH.

Install Node 20 or 22 LTS (https://nodejs.org), then re-run ./setup.sh.
EOF
  exit 1
fi

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" != "20" ] && [ "$NODE_MAJOR" != "22" ]; then
  echo "Warning: Node $(node -v) detected. DQL supports Node 20 or 22 LTS." >&2
  echo "         Node 23/24 can break native local drivers. Continuing anyway..." >&2
else
  echo "Node $(node -v): ok"
fi

# ---------------------------------------------------------------------------
# Layer 1 + 2: Python deps (dbt-duckdb + DataLex) in a local virtualenv
# ---------------------------------------------------------------------------
section "Installing Python dependencies (dbt-duckdb + DataLex)"
echo "Creating local Python virtual environment..."
"$PYTHON_BIN" -m venv .venv

.venv/bin/python -m pip install --upgrade pip --progress-bar off
.venv/bin/python -m pip install -r requirements.txt --progress-bar off

# ---------------------------------------------------------------------------
# Layer 1: build the dbt + DuckDB project
# ---------------------------------------------------------------------------
section "Building the dbt + DuckDB project"
echo "Installing dbt packages..."
.venv/bin/dbt deps --profiles-dir .

echo "Loading seed data into local DuckDB..."
.venv/bin/dbt seed --full-refresh --profiles-dir .

echo "Building and testing dbt models..."
.venv/bin/dbt build --profiles-dir . --exclude resource_type:seed

echo "Generating dbt docs and lineage artifacts..."
.venv/bin/dbt docs generate --profiles-dir .

# ---------------------------------------------------------------------------
# Layer 2: DataLex (contract layer) — installed above via requirements.txt
# ---------------------------------------------------------------------------
section "Building DataLex (contract layer)"
.venv/bin/datalex --version
echo "Validating the DataLex commerce project..."
.venv/bin/datalex datalex validate DataLex
echo "Building the certified-contract manifest (datalex-manifest.json)..."
.venv/bin/datalex datalex manifest build DataLex
echo "AI providers installed: Claude (anthropic) + OpenAI. To generate new"
echo "proposals/contracts, set an API key in the DataLex AI Setup panel, or export"
echo "ANTHROPIC_API_KEY / OPENAI_API_KEY before launching. Ollama also works locally."

# ---------------------------------------------------------------------------
# Layer 3: DQL (analytics layer)
# ---------------------------------------------------------------------------
section "Installing DQL (analytics layer)"
(
  cd dql
  echo "Installing the DQL CLI and notebook..."
  npm install --no-fund --no-audit

  echo "Installing the DuckDB connector (project-local)..."
  npm install --prefix .dql/connectors duckdb --no-fund --no-audit

  echo "Compiling the DQL project manifest..."
  npm run compile

  echo "Running DQL doctor..."
  npm run doctor
)

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
section "Setup complete"
cat <<EOF
Local database: ${DB_PATH}
  Raw seed schema: raw
  Model schema:    dev
  Docs artifacts:  target/manifest.json and target/catalog.json

Three layers are installed:
  1. dbt + DuckDB  - jaffle_shop.duckdb built
  2. DataLex       - $(.venv/bin/datalex --version 2>/dev/null)
  3. DQL           - $(cd dql && node -p "require('./package.json').devDependencies['@duckcodeailabs/dql-cli']")
EOF

if [ "$LAUNCH" = "1" ]; then
  section "Launching the local UIs"
  exec ./start.sh
else
  cat <<EOF

Launch the local UIs when you are ready:
  ./start.sh     # DataLex http://localhost:3030  +  DQL http://127.0.0.1:3474
  ./stop.sh      # stop both servers
EOF
fi
