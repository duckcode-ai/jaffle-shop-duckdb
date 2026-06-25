# Jaffle Shop DuckDB + DataLex + DQL — one-image demo.
#
# Bundles both runtimes the stack needs (Python for dbt + DataLex, Node for
# DQL) so the whole flow runs with a single `docker compose up`. The image
# reuses ./setup.sh, so it follows the exact same ordered steps as a local
# install: dbt build -> DataLex manifest -> DQL gate.

FROM python:3.13-slim

# Node 20 (DQL needs Node 20-22) plus git and build tooling for any wheels.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl git ca-certificates build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Run the full ordered setup at build time: venv + latest dbt-duckdb and
# datalex-cli, seed + build the models, build the DataLex manifest, then
# install the latest dql-cli and run the DQL gate.
RUN ./setup.sh

# Bind the DQL notebook server to all interfaces so it is reachable from the
# host. The CLI reads DQL_HOST (defaults to 127.0.0.1, which is unreachable
# from outside a container).
ENV DQL_HOST=0.0.0.0

# 3474: DQL notebook + Growth Command Center App. 8080: optional dbt docs serve.
EXPOSE 3474 8080

WORKDIR /app/dql
CMD ["npm", "run", "notebook"]
