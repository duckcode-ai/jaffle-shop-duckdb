#!/bin/sh
# Start ZLens in GitHub Codespaces. It listens on localhost (no token needed:
# GitHub keeps the forwarded port private to you) and accepts this codespace's
# forwarded address. The built sample lives in /app (from the demo image).
set -eu
port=3474
if curl -fs -o /dev/null "http://127.0.0.1:${port}/"; then
  exit 0
fi
if [ -n "${CODESPACE_NAME:-}" ]; then
  ZLENS_ALLOWED_ORIGINS="https://${CODESPACE_NAME}-${port}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
  export ZLENS_ALLOWED_ORIGINS
fi
cd /app
nohup npx zlens notebook . --port "$port" --no-open > /tmp/zlens.log 2>&1 &
echo "ZLens is starting on port ${port}; it opens in a new tab when ready (log: /tmp/zlens.log)."

# Everything is already set up in the image: once ZLens answers, mark Guided
# Setup as reviewed so the tab opens straight onto the sample.
i=0
until curl -fs -o /dev/null "http://127.0.0.1:${port}/"; do
  i=$((i + 1)); [ "$i" -gt 120 ] && exit 0
  sleep 1
done
curl -fs -X POST -H 'Content-Type: application/json' -d '{}' \
  "http://127.0.0.1:${port}/api/onboarding/acknowledge" > /dev/null || true
