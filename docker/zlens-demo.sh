#!/bin/sh
# Start the ZLens workbench for the Jaffle Shop demo inside a container and
# print the one link to open on your computer.
set -eu
cd /app

port="${ZLENS_PORT:-3474}"
# Inside a container ZLens listens on all interfaces, so it needs a token;
# make one when none is given. The link below carries it.
if [ -z "${ZLENS_SERVER_TOKEN:-}" ]; then
  ZLENS_SERVER_TOKEN="$(node -e "process.stdout.write(require('crypto').randomBytes(24).toString('hex'))")"
  export ZLENS_SERVER_TOKEN
fi
export ZLENS_ALLOWED_ORIGINS="${ZLENS_ALLOWED_ORIGINS:-http://127.0.0.1:${port},http://localhost:${port}}"

echo "Starting ZLens (Jaffle Shop demo)…"
npx zlens notebook . --host 0.0.0.0 --port "$port" --no-open > /tmp/zlens.log 2>&1 &
pid=$!
trap 'kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; exit 0' INT TERM

i=0
until curl -fs -o /dev/null "http://127.0.0.1:${port}/"; do
  if ! kill -0 "$pid" 2>/dev/null; then
    cat /tmp/zlens.log
    echo "ZLens stopped before it was ready (log above)." >&2
    exit 1
  fi
  i=$((i + 1))
  [ "$i" -gt 120 ] && { cat /tmp/zlens.log; echo "ZLens did not start within 2 minutes." >&2; exit 1; }
  sleep 1
done

# Everything is already set up in this image: mark Guided Setup as reviewed
# so the link opens straight onto the sample.
curl -fs -X POST -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${ZLENS_SERVER_TOKEN}" -d '{}' \
  "http://127.0.0.1:${port}/api/onboarding/acknowledge" > /dev/null || true

cat <<MSG

  ZLens is ready. Open this link in your browser:

    http://localhost:${port}/?app=jaffle-growth&page=overview#dql_token=${ZLENS_SERVER_TOKEN}

  It opens the Jaffle Shop sample: certified saved queries, an App, lineage
  and notebooks. Ask needs an AI model: add one in Settings → AI provider.
  "Sign in with Claude/ChatGPT" needs -p 127.0.0.1:54545:54545 -p 127.0.0.1:1455:1455
  on the docker run command; otherwise use an API key.
  Using another host port? Pass -e ZLENS_PORT=<port> and map <port>:<port>.
  Press Ctrl+C to stop. Nothing you change is kept after the container stops.

MSG
# Show ZLens's log from here on (its startup lines name addresses inside the
# container, which don't work from your computer).
tail -n 0 -f /tmp/zlens.log &
wait "$pid"
