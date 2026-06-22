# Jaffle Shop DuckDB + DataLex + DQL

This is a local DuckDB version of the dbt Jaffle Shop sample project, with a
[DataLex](https://github.com/duckcode-ai/DataLex) contract pack and a
[DQL](https://github.com/duckcode-ai/dql) governed-analytics layer built on
top. dbt models the data; DataLex certifies business meaning from dbt evidence;
DQL turns those certified contracts into reusable blocks, notebooks, an App,
and AI answers that can cite their trust boundary.

> **Two-minute tour.** After `./setup.sh` (below):
> ```bash
> datalex datalex manifest build DataLex --out "$(pwd)/DataLex/datalex-manifest.json"
> cd dql && npm install && npx dql validate && npx dql app build && npm run notebook
> ```
> Then open the left rail:
> - **Blocks** — 10 certified analytics blocks, each bound to a DataLex contract
> - **Apps → Jaffle Growth Command Center** — executive revenue, customer, and product views
> - **Lineage** — `raw → dbt models → DataLex contracts → certified blocks → App`
>
> The full AI-first tutorial, screenshots, and captions are in
> [`TUTORIAL.md`](./TUTORIAL.md).

If you are running DataLex from a local source checkout, replace `datalex` with
the path to that checkout's executable.

## Prerequisites

- Python 3.9 through 3.13
- Git
- Optional: [Task](https://taskfile.dev/) if you want to use `Taskfile.yml`

## Quick Start

Clone the repo and run the setup script:

```bash
git clone <your-repo-url> jaffle-shop-duckdb
cd jaffle-shop-duckdb
./setup.sh
```

If your machine's default `python3` is Python 3.14 or newer, choose a supported
Python explicitly:

```bash
PYTHON=python3.13 ./setup.sh
```

The setup script creates a virtual environment, installs `dbt-duckdb`, installs
dbt packages, loads the seed data into DuckDB, builds and tests the models, and
generates docs and lineage artifacts.

By default it writes to `jaffle_shop.duckdb`. To use a different local database
path:

```bash
DBT_DUCKDB_PATH=./my_jaffle_shop.duckdb ./setup.sh
```

If you prefer to run the steps manually:

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
dbt deps --profiles-dir .
dbt seed --full-refresh --profiles-dir .
dbt build --profiles-dir . --exclude resource_type:seed
dbt docs generate --profiles-dir .
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
- `DataLex`: AI-reviewed and human-certified business contracts, glossary, proposals, and manifest
- `dql`: certified DQL blocks, business views, notebook, and Growth Command Center App
- `docs/assets/tutorials/jaffle`: Paper-theme tutorial screenshots

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
