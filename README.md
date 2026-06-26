# Jaffle Shop DuckDB + DQL

This is a local DuckDB version of the dbt Jaffle Shop sample project, with a
[DQL](https://github.com/duckcode-ai/dql) **governed-analytics layer** built on
top. dbt models the data; DQL turns the answers into certified, reusable,
git-tracked blocks — with an App dashboard, notebooks, and full lineage.

> **🟢 Two-minute tour.** One command installs all three layers and opens both
> local UIs:
> ```bash
> ./setup.sh
> ```
> When it finishes it launches:
> - **DataLex** (contract layer) — http://localhost:3030
> - **DQL notebook** (analytics layer) — http://127.0.0.1:3474
>
> In the **DQL notebook**'s left rail:
> - **Blocks** — 10 certified analytics blocks (revenue, customers, products)
> - **Apps → Jaffle Analytics** — an executive dashboard (revenue $671.4K,
>   orders 61,948, AOV $10.84, customers 935, plus charts)
> - **Lineage** — `raw → dbt models → certified blocks → App`
>
> In **DataLex** you'll find the commerce contract layer: conceptual / logical /
> physical models for 6 entities, a governed glossary, and certified contracts
> (`commerce.Orders.revenue`, `commerce.Customers.lifetime_value`) — see
> [`DataLex/README.md`](./DataLex/README.md).
>
> Stop the servers with `./stop.sh`; relaunch later with `./start.sh`.
> The full guided tour and a hands-on "build your own block" walkthrough are in
> [`dql/TUTORIAL.md`](./dql/TUTORIAL.md).

## The three layers

This example wires together the full DuckCode analytics stack:

| Layer | Tool | Installed by `setup.sh` | UI |
| --- | --- | --- | --- |
| Transformation | **dbt + DuckDB** | `dbt-duckdb` (PyPI) → builds `jaffle_shop.duckdb` | dbt docs |
| Contracts | **DataLex** | `datalex-cli[serve,duckdb,draft,draft-openai]` (PyPI) | http://localhost:3030 |
| Analytics | **DQL** | `@duckcodeailabs/dql-cli` (npm) | http://127.0.0.1:3474 |

## Prerequisites

- Python 3.9 through 3.13
- Node.js 20 or 22 LTS (for the DQL layer; avoid Node 23/24)
- Git
- Optional: [Task](https://taskfile.dev/) if you want to use `Taskfile.yml`

## Quick Start

Clone the repo and run the one setup command:

```bash
git clone <your-repo-url> jaffle-shop-duckdb
cd jaffle-shop-duckdb
./setup.sh
```

`setup.sh` installs and wires all three layers, then launches both local UIs:

1. Creates a Python virtualenv and installs `dbt-duckdb` **and** `datalex-cli`.
2. Loads seed data into DuckDB, builds and tests the dbt models, and generates
   docs/lineage artifacts.
3. Installs the DQL CLI, the project-local DuckDB connector, and compiles the
   DQL manifest.
4. Launches **DataLex** (http://localhost:3030) and the **DQL notebook**
   (http://127.0.0.1:3474).

To install and build everything but **not** launch the UIs (for example in CI):

```bash
./setup.sh --no-launch
```

Then start and stop the UIs on demand:

```bash
./start.sh   # launch DataLex + DQL notebook
./stop.sh    # stop both
```

If your machine's default `python3` is Python 3.14 or newer, choose a supported
Python explicitly:

```bash
PYTHON=python3.13 ./setup.sh
```

By default it writes to `jaffle_shop.duckdb`. To use a different local database
path:

```bash
DBT_DUCKDB_PATH=./my_jaffle_shop.duckdb ./setup.sh
```

If you prefer to run the steps manually:

```bash
# 1. dbt + DuckDB (and DataLex, both Python) into a local virtualenv
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
dbt deps --profiles-dir .
dbt seed --full-refresh --profiles-dir .
dbt build --profiles-dir . --exclude resource_type:seed
dbt docs generate --profiles-dir .

# 2. DataLex contract layer (validate models + build the certified manifest)
datalex datalex validate DataLex
datalex datalex manifest build DataLex

# 3. DQL analytics layer (Node)
cd dql
npm install
npm install --prefix .dql/connectors duckdb   # DuckDB connector
npm run compile
npm run doctor
cd ..

# 4. Launch the UIs
datalex serve --project-dir DataLex            # http://localhost:3030
npm --prefix dql run notebook                  # http://127.0.0.1:3474
```

The build creates a local `jaffle_shop.duckdb` database file in the project
root. Seed tables are loaded into the `raw` schema and models are built into
the `dev` schema. `dbt docs generate` writes `target/manifest.json` and
`target/catalog.json`, which dbt uses for docs and lineage.

## Using Task

If you have Task installed, run:

```bash
task setup
```

To run the full verification, including docs and lineage artifacts:

```bash
task verify
```

## Profile

The repo includes a local `profiles.yml`:

```yaml
jaffle_shop:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: "{{ env_var('DBT_DUCKDB_PATH', 'jaffle_shop.duckdb') }}"
      schema: dev
      threads: 4
```

Because this profile has no secrets, it is committed to the repo. Use
`--profiles-dir .` when running dbt commands so dbt reads this local profile.

## Common Commands

Install package dependencies:

```bash
dbt deps --profiles-dir .
```

Load only the seed data:

```bash
dbt seed --full-refresh --profiles-dir .
```

Build and test everything:

```bash
dbt seed --full-refresh --profiles-dir .
dbt build --profiles-dir . --exclude resource_type:seed
```

Generate docs and lineage artifacts:

```bash
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

Open the database in DuckDB:

```bash
duckdb jaffle_shop.duckdb
```

Then query the built models:

```sql
select * from dev.orders limit 10;
select * from dev.customers limit 10;
```

Clean generated local artifacts:

```bash
rm -rf target dbt_packages logs jaffle_shop.duckdb jaffle_shop.duckdb.wal
```

Or with Task:

```bash
task clean
```

## Larger Synthetic Data

The default seed files under `seeds/jaffle-data` are enough to run the project.
To generate a larger local dataset with `jafgen`:

```bash
source .venv/bin/activate
jafgen 6
rm -rf seeds/jaffle-data
mv jaffle-data seeds
dbt seed --full-refresh --profiles-dir .
dbt build --profiles-dir . --exclude resource_type:seed
```

With Task:

```bash
task gen YEARS=6
task build
```

## Project Layout

- `profiles.yml`: local DuckDB dbt profile
- `dbt_project.yml`: dbt project settings
- `seeds/jaffle-data`: CSV source data loaded into DuckDB
- `models/staging`: staging models over the raw source tables
- `models/marts`: final mart models
- `macros`: project macros

## Notes

- `jaffle_shop.duckdb` and DuckDB WAL files are ignored by git.
- `target/manifest.json` and `target/catalog.json` are generated artifacts.
  Recreate them with `dbt docs generate --profiles-dir .`.
- Run `dbt seed --full-refresh --profiles-dir .` before `dbt build` on a fresh
  DuckDB file. The staging models read seed-backed data through `source()`, and
  dbt does not infer that source-to-seed dependency automatically.
- Use `--exclude resource_type:seed` on the build after seeding so dbt does not
  append the seed rows a second time.
- Seed loading is enabled by default for local development.
