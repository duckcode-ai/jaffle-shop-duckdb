#!/bin/sh
# Build step: the sample is fully set up, so record Guided Setup as reviewed for
# the installed ZLens version. The workbench then opens straight onto the sample.
set -eu
cd /app
npx zlens notebook . --port 3474 --no-open > /tmp/zlens-build.log 2>&1 &
pid=$!
i=0
until curl -fs -o /dev/null http://127.0.0.1:3474/; do
  i=$((i + 1))
  if [ "$i" -gt 120 ] || ! kill -0 "$pid" 2>/dev/null; then
    cat /tmp/zlens-build.log
    echo "ZLens did not start during the image build." >&2
    exit 1
  fi
  sleep 1
done
curl -fs -X POST -H 'Content-Type: application/json' -d '{}' http://127.0.0.1:3474/api/onboarding/acknowledge > /dev/null
curl -fs http://127.0.0.1:3474/api/onboarding/launch | grep -q '"shouldOpen":false'
kill "$pid"
wait "$pid" 2>/dev/null || true
rm -f /tmp/zlens-build.log
echo "Guided Setup recorded as reviewed."
