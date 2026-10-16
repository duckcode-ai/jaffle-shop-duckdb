# Jaffle Shop — dbt + ZLens

The sample project for [ZLens](https://github.com/duckcode-ai-labs/zlens):
the dbt Jaffle Shop on DuckDB, with a ready-made ZLens workspace on top. You
can try domain modeling, skills, certified blocks, an App, lineage and Ask on
your laptop, without a warehouse account.

dbt stays the source of truth for models, columns, tests and MetricFlow
metrics. ZLens adds the business layer that people and AI agents use to ask,
reuse and trace analysis. Blocks are written in DQL, the ZLens query language.

> [!IMPORTANT]
> This folder **is already a ZLens workspace** (`dql.config.json` is at the
> root). Do not run `npx create-zlens-app` here: it makes a second, empty
> workspace in `dql/` without the domain, blocks, App and notebook below.
> Install ZLens into this folder with `npm install` instead.

## What you will explore

The use case is **Growth & Beverage Insights**:

- Which months drive revenue and order volume?
- Which products generate beverage revenue?
- Which customers bought the widest range of beverage products?
- How do you reuse the same certified answer in a notebook, an App and Ask?

The workspace has one `commerce` domain, two model areas, two domain skills,
four certified blocks, a starter notebook and the **Jaffle Growth Review** App.

## Before you start

- Python 3.9 to 3.13 for dbt (`python3 --version`). Python 3.14 also works
  with the current dbt-duckdb release.
- Node.js 20 or newer (`node -v`)
- git

## 1. Build the dbt project

```bash
git clone https://github.com/duckcode-ai/jaffle-shop-duckdb.git
cd jaffle-shop-duckdb
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/dbt deps --profiles-dir .
.venv/bin/dbt seed --profiles-dir .
.venv/bin/dbt build --profiles-dir . --exclude resource_type:seed
```

You now have `jaffle_shop.duckdb` and `target/manifest.json` in the folder.

## 2. Install ZLens and open the workbench

Still in `jaffle-shop-duckdb`:

```bash
npm install
npm install --prefix .dql/connectors duckdb
npm run sync
npm run notebook
```

- `npm install` installs the ZLens CLI (`@zlens/cli`) into this folder. No
  global install is needed; `npx zlens …` runs it.
- The second command installs the DuckDB driver ZLens queries with.
- `npm run sync` imports the dbt project. Its last line starts with
  `✓ dbt sync complete`.
- `npm run notebook` prints `Notebook ready: http://127.0.0.1:3474` and opens
  your browser. Leave it running; press `Ctrl+C` to stop it.

**Shortcut:** `./setup.sh` runs steps 1 and 2 (except `npm run notebook`) in
one go. It picks a supported Python for you and is safe to rerun. Then run
`npm run notebook`.

## 3. Finish Guided Setup

The first time, ZLens opens **Guided Setup**:

1. **Connect your dbt project.** You see **dbt project ready** and the path
   `.` (this folder). Click **Preview**, then **Apply project**, then
   **Continue to database**.
2. **Connect your database.** The sample's DuckDB connection is already set
   up: you see **DuckDB · configured** and **Test passed**. Click
   **Continue to optional AI**.
3. **Set up an AI provider.** Optional. Only **Ask** needs a model; see
   [Set up an AI provider](https://duckcode-ai-labs.github.io/zlens/get-started/ai-provider/).
   Click **Continue to finish**.
4. Click **Finish setup**.

## 4. Take the tour

1. **Apps → Jaffle Growth Review → View.** The header reads
   **All 4 tiles certified**: monthly revenue, top beverage products, top
   beverage customers and customer profiles, each labelled **Certified**.
2. **Lineage.** Pick the `monthly_revenue` block. The graph runs from the dbt
   sources and models through the block to its dashboard and the App.
3. **Notebooks.** Open **welcome** (under **Domains → commerce**) and click
   **Run all**, or click **New Notebook** and run the query
   from the [ZLens quickstart](https://duckcode-ai-labs.github.io/zlens/get-started/):

   ```sql
   select customer_name, count_lifetime_orders, lifetime_spend
   from dev.customers
   order by lifetime_spend desc
   limit 10
   ```

4. **Domains → Commerce.** The **Model** tab shows the dbt-backed model areas
   `Revenue performance` and `Customer value`; **Skills** shows the beverage
   and customer-analysis guidance Ask uses.
5. **Blocks.** Open `monthly_revenue`, `beverage_revenue_by_product`,
   `top_beverage_customers` or `customer_profile`.
6. **Ask** (needs an AI provider). Try:

   ```text
   How has revenue changed by month?
   Which beverage products generate the most revenue?
   Who are the top customers by beverage revenue and product variety?
   ```

## Lineage and certification from the terminal

DuckDB lets only one process write to `jaffle_shop.duckdb`, and the running
workbench holds it. Stop `npm run notebook` (`Ctrl+C`) before you run
`zlens certify` or `dbt build` in a terminal; `zlens lineage` works either way.

```bash
npx zlens lineage                          # summary: blocks, terms, charts, Apps
npx zlens lineage monthly_revenue          # one block, upstream and downstream
npx zlens lineage "Jaffle Growth Review"   # one App
npx zlens certify domains/commerce/blocks/monthly_revenue.dql   # check the rules, writes nothing
```

To change a certified block, save your edit as a draft in
`domains/commerce/blocks/_drafts/<block>.dql` with `status = "draft"`, then:

```bash
npx zlens certify --from-draft domains/commerce/blocks/_drafts/<block>.dql --force
```

ZLens runs the certification rules (owner, compile, run, tests) and only when
they pass replaces the certified block and writes who certified it to
`semantic-layer/blocks/commerce/<block>.yaml`. In the workbench, **Certify** in
Block Studio does the same.

## Project map

```text
models/                              dbt models and tests (source of truth)
dql.config.json                      ZLens workspace config and DuckDB connection
domains/commerce/domain.dql          business domain
domains/commerce/modeling/areas/     dbt-backed model areas
domains/commerce/skills/             domain guidance for Ask
domains/commerce/blocks/             certified blocks, written in DQL
semantic-layer/blocks/               certification receipts
skills/                              project-wide SQL guidance
apps/jaffle-growth/                  the Jaffle Growth Review App
notebooks/welcome.dqlnb              starter notebook
```

## Extend it

1. Add or change a dbt model under `models/`. Stop the workbench, then
   rebuild dbt and re-import:

   ```bash
   .venv/bin/dbt build --profiles-dir .
   npm run sync
   ```

2. In **Domains**, add a model area that explains the business question and
   points to the dbt models it needs.
3. Add a domain skill for vocabulary or analysis rules.
4. Save a repeated answer as a block (a draft), then certify it. Check the
   workspace with:

   ```bash
   npm run validate
   npm run compile
   ```

## Useful commands

| Command | Runs |
|---|---|
| `npm run notebook` | `zlens notebook` — the workbench at <http://127.0.0.1:3474> |
| `npm run sync` | `zlens sync dbt` — import the dbt project and refresh the index |
| `npm run compile` | `zlens compile` — write `dql-manifest.json` |
| `npm run lineage` | `zlens lineage` |
| `npm run validate` | `zlens validate` and `zlens model validate` |
| `npm run doctor` | `zlens doctor` — check Node, the CLI, dbt artifacts and DuckDB |
| `npm run app:build` | `zlens app build` |

`./start.sh` starts the workbench too (`ZLENS_PORT=3480 ./start.sh` for another
port).

## Troubleshooting

- **`pip install` or dbt fails on your Python.** Use Python 3.9 to 3.13
  (3.14 works with current dbt). Remove `.venv` and create it with a supported
  version, for example `python3.13 -m venv .venv`, or run
  `PYTHON=python3.13 ./setup.sh`.
- **`Could not set lock on file ".../jaffle_shop.duckdb"`.** Another process
  has the database open, usually the running workbench. Stop it with `Ctrl+C`,
  run your command, then start `npm run notebook` again.
- **You have a `dql/` folder.** An older quickstart ran `create-zlens-app`
  here. Delete `dql/` and run `npm run notebook` in this folder.
- **`dql` command or `@duckcodeailabs/dql-cli`.** That is the pre-ZLens CLI.
  Remove `node_modules/` and run `npm install`; the command is now `zlens`.
- **Port 3474 is in use.** Stop the other workbench, or run
  `npx zlens notebook . --port 3480`.
- **`npm run doctor`** names anything missing, such as the DuckDB driver or
  the dbt manifest.

## Local files

`jaffle_shop.duckdb`, `target/`, `dbt_packages/`, `node_modules/`, `.venv/`,
`dql-manifest.json` and the runtime folders under `.dql/` are local and ignored
by git. The checked-in source is the dbt project plus the ZLens workspace;
there is no second semantic copy to keep in sync.
