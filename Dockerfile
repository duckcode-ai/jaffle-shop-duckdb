# ZLens demo: the Jaffle Shop sample with ZLens, ready to open.
#
#   docker run --rm -p 127.0.0.1:3474:3474 -p 127.0.0.1:54545:54545 -p 127.0.0.1:1455:1455 ghcr.io/duckcode-ai/zlens-demo
#
# 54545 and 1455 are where "Sign in with Claude" and "Sign in with ChatGPT"
# return the browser after sign-in; without them, use an API key instead.
#
# The build runs ./setup.sh, so the image already holds the DuckDB database,
# the dbt manifest, ZLens and the DuckDB driver. Starting the container only
# starts the workbench. The GitHub Codespaces dev container uses this image too.
FROM node:24-bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-venv python3-pip git ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
# setup.sh installs this @zlens/cli version when set (the image workflow passes the latest).
ARG ZLENS_VERSION
RUN ./setup.sh && rm -rf /root/.npm /root/.cache

# The sample is fully set up: record Guided Setup as reviewed (docker/mark-setup-done.sh).
RUN sh docker/mark-setup-done.sh

COPY docker/zlens-demo.sh /usr/local/bin/zlens-demo
RUN chmod +x /usr/local/bin/zlens-demo

ENV ZLENS_PORT=3474
EXPOSE 3474
# CMD, not ENTRYPOINT: the dev container replaces it with its own command.
CMD ["zlens-demo"]
