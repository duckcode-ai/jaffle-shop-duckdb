# Jaffle Shop — dbt + DQL

A small, local-first example for turning a dbt project into a governed DQL
workspace. It uses DuckDB, so you can explore real dbt models, domain modeling,
skills, reusable blocks, an app, and Ask AI without a cloud warehouse.

This is a **DQL-only** example. dbt remains the source of truth for models,
columns, tests, and MetricFlow metrics; DQL adds the business-facing layer that
people and agents use to ask, explain, reuse, and trace analysis.

## What you will explore

The included use case is **Growth & Beverage Insights**:

- Which months drive revenue and order volume?
- Which products generate beverage revenue?
- Which customers bought the widest range of beverage products?
- How can an analyst reuse the same governed answer in a notebook or app?

The project has one `commerce` domain, two focused model areas, two scoped
skills, four certified blocks, a starter notebook, and a Growth dashboard.

## Prerequisites

- Python 3.9–3.13
- Node.js 20–22 (includes npm)
- Git

## 1. Set up the example

```bash
git clone https://github.com/duckcode-ai/jaffle-shop-duckdb.git
cd jaffle-shop-duckdb
./setup.sh
```

The script is safe to rerun. It creates a local virtual environment, builds the
dbt DuckDB database, installs DQL `1.7.1`, compiles the DQL workspace, validates
the dbt-first model areas, and builds the starter app.

If your default Python is unsupported, choose one explicitly:

```bash
PYTHON=python3.13 ./setup.sh
```

To try a different DQL release, pass it explicitly:

```bash
DQL_VERSION=latest ./setup.sh
```

## 2. Open DQL

```bash
npm run notebook
```

Open <http://127.0.0.1:3474>. The notebook is local; press `Ctrl+C` to stop it.

## 3. Follow the product flow

1. **Domains → Commerce → Model** — inspect the dbt-backed model areas:
   `Revenue performance` and `Customer value`.
2. **Domains → Commerce → Skills** — see the beverage and customer-analysis
   instructions that guide retrieval only when relevant.
3. **Blocks** — open `monthly_revenue`, `beverage_revenue_by_product`,
   `top_beverage_customers`, or `customer_profile`.
4. **Apps → Jaffle Growth Review** — reuse the same blocks in one stakeholder
   view.
5. **Ask** — try the questions below. DQL searches certified blocks first,
   then the commerce model and dbt metadata when a block is not enough.

Suggested questions:

```text
How has revenue changed by month?
Which beverage products generate the most revenue?
Who are the top customers by beverage revenue and product variety?
Give me the profile for Matthew Meyer.
```

## Project map

```text
models/                              dbt models and tests (source of truth)
domains/commerce/domain.dql          business domain
domains/commerce/modeling/areas/     focused dbt-backed model areas
domains/commerce/skills/             domain guidance for Ask AI
domains/commerce/blocks/             reusable certified answers
skills/                              project-wide SQL guidance
apps/jaffle-growth/                  governed growth dashboard
notebooks/welcome.dqlnb              starter research notebook
```

## Extend it in four small steps

1. Add or improve a dbt model under `models/`, then rebuild dbt:

   ```bash
   .venv/bin/dbt build --profiles-dir .
   .venv/bin/dbt docs generate --profiles-dir .
   ```

2. In **Domains**, add a model area that explains the business question and
   points to the dbt models it needs.
3. Add a domain skill for vocabulary or analysis rules; keep it scoped to the
   model area when it is not broadly applicable.
4. Save a repeated answer as a draft block, review it, then certify it. Run:

   ```bash
   npm run compile
   npm run validate
   ```

## Useful commands

```bash
# Rebuild the local dbt database and docs
.venv/bin/dbt build --profiles-dir .
.venv/bin/dbt docs generate --profiles-dir .

# Refresh DQL after source changes
npm run compile
npm run validate
npm run app:build

# Check local prerequisites and DQL/dbt wiring
npm run doctor

# Start the notebook without an npm wrapper
./start.sh
```

## Local files

`jaffle_shop.duckdb`, `target/`, `node_modules/`, `.venv/`, and `.dql/` are
local runtime artifacts and are ignored by Git. The checked-in source is the
dbt project plus the DQL domain workspace; there is no second semantic copy to
keep in sync.
