# ZLens demo: the Jaffle Shop sample with ZLens, ready to open.
#
#   docker run --rm -p 127.0.0.1:3474:3474 ghcr.io/duckcode-ai/zlens-demo
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
RUN ./setup.sh && rm -rf /root/.npm /root/.cache

# The sample is fully set up: record Guided Setup as reviewed (docker/mark-setup-done.sh).
RUN sh docker/mark-setup-done.sh

COPY docker/zlens-demo.sh /usr/local/bin/zlens-demo
RUN chmod +x /usr/local/bin/zlens-demo

ENV ZLENS_PORT=3474
EXPOSE 3474
# CMD, not ENTRYPOINT: the dev container replaces it with its own command.
CMD ["zlens-demo"]
