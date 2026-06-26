#!/usr/bin/env bash
# Stop the background DataLex and DQL notebook servers started by ./start.sh.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_DIR="$ROOT_DIR/.run"
DATALEX_PORT="${DATALEX_PORT:-3030}"
DQL_PORT="${DQL_PORT:-3474}"

# The launched commands spawn child servers (datalex -> node, npm -> dql ->
# node), so kill the whole process subtree, children first.
kill_tree() {
  local pid="$1" child
  for child in $(pgrep -P "$pid" 2>/dev/null); do
    kill_tree "$child"
  done
  kill "$pid" 2>/dev/null || true
}

stop_one() {
  local name="$1" pidfile="$2"
  if [ ! -f "$pidfile" ]; then
    echo "${name}: not running (no pid file)."
    return 0
  fi
  local pid; pid="$(cat "$pidfile" 2>/dev/null || true)"
  if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
    kill_tree "$pid"
    echo "${name}: stopped (pid ${pid})."
  else
    echo "${name}: not running."
  fi
  rm -f "$pidfile"
}

# Fallback: free the port even if pid tracking missed a re-parented child.
free_port() {
  local name="$1" port="$2"
  if command -v lsof >/dev/null 2>&1; then
    local pids; pids="$(lsof -ti "tcp:${port}" 2>/dev/null || true)"
    if [ -n "${pids:-}" ]; then
      echo "${pids}" | xargs kill 2>/dev/null || true
      sleep 1
      pids="$(lsof -ti "tcp:${port}" 2>/dev/null || true)"
      if [ -n "${pids:-}" ]; then echo "${pids}" | xargs kill -9 2>/dev/null || true; fi
      echo "${name}: freed port ${port}."
    fi
  fi
}

stop_one "DataLex" "$RUN_DIR/datalex.pid"
stop_one "DQL notebook" "$RUN_DIR/dql-notebook.pid"
free_port "DataLex" "$DATALEX_PORT"
free_port "DQL notebook" "$DQL_PORT"
