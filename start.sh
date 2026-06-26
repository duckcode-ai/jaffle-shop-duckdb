#!/usr/bin/env bash
# Launch the two local UIs for the Jaffle Shop + DataLex + DQL example:
#   - DataLex (contract layer)   http://localhost:3030
#   - DQL notebook (analytics)   http://127.0.0.1:3474
#
# Both run in the background. Logs go to logs/, PIDs to .run/. Stop with ./stop.sh.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

DATALEX_PORT="${DATALEX_PORT:-3030}"
DQL_PORT="${DQL_PORT:-3474}"
RUN_DIR="$ROOT_DIR/.run"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$RUN_DIR" "$LOG_DIR"

if [ ! -x ".venv/bin/datalex" ]; then
  echo "DataLex is not installed. Run ./setup.sh first." >&2
  exit 1
fi
if [ ! -x "dql/node_modules/.bin/dql" ]; then
  echo "DQL is not installed. Run ./setup.sh first." >&2
  exit 1
fi

open_url() {
  # Best-effort browser open; never fail the script if no opener exists.
  local url="$1"
  if command -v open >/dev/null 2>&1; then open "$url" >/dev/null 2>&1 || true
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$url" >/dev/null 2>&1 || true
  fi
}

wait_for_port() {
  local url="$1" name="$2" tries=60
  for _ in $(seq 1 "$tries"); do
    if curl -s -o /dev/null "$url"; then return 0; fi
    sleep 1
  done
  echo "  (warning) ${name} did not respond at ${url} within ${tries}s; check its log." >&2
  return 1
}

# The launched commands (datalex -> node, npm -> dql -> node) spawn child
# servers, so killing only the recorded pid leaves the real listener alive.
# Kill the whole process subtree, children first.
kill_tree() {
  local pid="$1" child
  for child in $(pgrep -P "$pid" 2>/dev/null); do
    kill_tree "$child"
  done
  kill "$pid" 2>/dev/null || true
}

stop_if_running() {
  local pidfile="$1"
  if [ -f "$pidfile" ]; then
    local pid; pid="$(cat "$pidfile" 2>/dev/null || true)"
    if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then kill_tree "$pid"; fi
    rm -f "$pidfile"
  fi
}

# Avoid stacking duplicate servers on repeated runs.
stop_if_running "$RUN_DIR/datalex.pid"
stop_if_running "$RUN_DIR/dql-notebook.pid"

echo "Starting DataLex (contract layer) on port ${DATALEX_PORT}..."
# Point DataLex at the committed DataLex/ commerce project so the UI opens with
# the certified contracts, domains, and conceptual/logical/physical models.
nohup .venv/bin/datalex serve --project-dir "$ROOT_DIR/DataLex" --port "$DATALEX_PORT" --no-browser \
  > "$LOG_DIR/datalex.log" 2>&1 &
echo $! > "$RUN_DIR/datalex.pid"

echo "Starting DQL notebook (analytics layer) on port ${DQL_PORT}..."
# npm runs the script with cwd=dql/, so `dql notebook` uses the dql workspace.
DQL_PORT="$DQL_PORT" nohup npm --prefix dql run notebook \
  > "$LOG_DIR/dql-notebook.log" 2>&1 &
echo $! > "$RUN_DIR/dql-notebook.pid"

echo
echo "Waiting for servers to come up..."
wait_for_port "http://localhost:${DATALEX_PORT}" "DataLex" || true
wait_for_port "http://127.0.0.1:${DQL_PORT}" "DQL notebook" || true

open_url "http://localhost:${DATALEX_PORT}"
open_url "http://127.0.0.1:${DQL_PORT}"

cat <<EOF

Both UIs are running in the background:

  DataLex (contract layer):  http://localhost:${DATALEX_PORT}
  DQL notebook (analytics):  http://127.0.0.1:${DQL_PORT}

Logs:
  logs/datalex.log
  logs/dql-notebook.log

Stop both servers with:
  ./stop.sh
EOF
