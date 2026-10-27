# Jaffle Shop — dbt + ZLens

The sample project for [ZLens](https://github.com/duckcode-ai-labs/zlens):
the dbt Jaffle Shop on DuckDB, with a ready-made ZLens workspace on top. You
can try domain modeling, skills, certified saved queries, an App, lineage and
Ask on your laptop, without a warehouse account.

dbt stays the source of truth for models, columns, tests and MetricFlow
metrics. ZLens adds the business layer that people and AI agents use to ask,
reuse and trace analysis. Saved queries (called blocks in files and on the
command line) are written in DQL, the ZLens query language.

> [!IMPORTANT]
> This folder **is already a ZLens workspace** (`dql.config.json` is at the
> root). Do not run `npx create-zlens-app` here: it makes a second, empty
> workspace in `dql/` without the domain, blocks, App and notebook below.
> Install ZLens into this folder with `npm install` instead.

## Try it without installing anything

**In your browser (no install):**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/duckcode-ai/jaffle-shop-duckdb?quickstart=1)

Click the button and choose **Create codespace**. In about a minute ZLens opens
in a panel inside the codespace, and the terminal prints a link (Cmd/Ctrl+click)
that opens it in its own tab, with the certified saved queries, the App, lineage
and notebooks below ready to explore. Nothing opened? Click **Ports** at the
bottom, then the globe next to **ZLens (3474)**. It runs on GitHub's free Codespaces hours for
your account; stop or delete the codespace from
[github.com/codespaces](https://github.com/codespaces) when you're done.

**With Docker (one command):**

```bash
docker run --rm -p 127.0.0.1:3474:3474 -p 127.0.0.1:54545:54545 -p 127.0.0.1:1455:1455 ghcr.io/duckcode-ai/zlens-demo
```

Open the link it prints (`http://localhost:3474/…#dql_token=…`). Ctrl+C stops it;
nothing you change is kept after it stops. Ports 54545 and 1455 let **Sign in with
Claude** and **Sign in with ChatGPT** finish: those sign-ins return your browser to
`localhost` on those ports.

Either way, **Ask** needs an AI model: add one in **Settings → AI provider**. In a
codespace, use an **API key** for now: **Sign in with Claude/ChatGPT** returns your
browser to `localhost` on your own computer, which can't reach the codespace (the
next ZLens release lets you paste that address instead).
Everything else works without one. To use your own data, or keep your work,
install the sample below.

## What you will explore

The use case is **Growth & Beverage Insights**:

- Which months drive revenue and order volume?
- Which products generate beverage revenue?
- Which customers bought the widest range of beverage products?
- How do you reuse the same certified answer in a notebook, an App and Ask?

The workspace has one `commerce` domain, two model areas, two domain skills,
four certified saved queries, a starter notebook and the **Jaffle Growth
Review** App.

## Before you start

- Python 3.9 to 3.14 for dbt (`python3 --version`). `./setup.sh` picks a
  supported one for you.
- Node.js 20, 22 or 24, with 24 LTS recommended (`node -v`). Node 25 and 26
  are not supported yet: ZLens's DuckDB driver has no prebuilt binary for them.
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
npm run sync
npm run notebook
```

- `npm install` installs the ZLens CLI (`@zlens/cli`) into this folder. No
  global install is needed; `npx zlens …` runs it.
- `npm run sync` imports the dbt project. Its last line starts with
  `✓ dbt sync complete`.
- `npm run notebook` prints `Notebook ready: http://127.0.0.1:3474` and opens
  your browser. Leave it running; press `Ctrl+C` to stop it. The first time,
  it installs the DuckDB driver into `.dql/connectors` by itself
  (`Installing the DuckDB driver…`, then `DuckDB driver ready`); you do not
  install it by hand.

**Shortcut:** `./setup.sh` runs steps 1 and 2 (except `npm run notebook`) in
one go. It picks a supported Python for you and is safe to rerun. Then run
`npm run notebook`.

## 3. Finish Guided Setup

The first time, ZLens opens **Guided Setup** (**Welcome to ZLens**, four
steps):

1. **Where does your data model live?** This folder already has a ZLens
   workspace on the dbt project, so **Open an existing ZLens project** is
   selected (its card names the dbt project in this folder and the connection
   `jaffle_shop_dev` (duckdb)). Click **Continue to credentials**.
2. **Check the connection.** The sample's DuckDB connection is already set
   up: you see **DuckDB · configured** and **Test passed**. You already ran
   `npm run sync`, so you don't need **Refresh dbt data**; it reads the dbt
   project again after you change it. Extra warehouse schemas are under
   **Advanced** ("Optional: add warehouse schemas dbt doesn't cover"); the
   sample needs none. Click **Continue to optional AI**.
3. **Set up an AI provider.** Optional. Without one, the setup, notebook,
   saved queries, the App, lineage and modeling in this tour all work. The AI
   features need a model: **Ask**, **Ask about this App**, the App's AI
   copilot, **Edit with AI** on tiles, Notebook AI, and describing an App in
   your own words. Without a provider ZLens hides them or says they need one.
   See [Set up an AI provider](https://duckcode-ai-labs.github.io/zlens/get-started/ai-provider/).
   Click **Skip AI for now**.
4. **Where do you want to start?** Click **Finish setup · Build an App**: it
   opens **Apps** with the new App form (see step 5 of the tour).

## 4. Take the tour

1. **Apps → Jaffle Growth Review → View.** The header reads
   **All tiles certified**: monthly revenue, top beverage products, top
   beverage customers and customer profiles, each labelled **Certified**.
2. **Lineage.** Pick the `monthly_revenue` saved query. The graph runs from
   the dbt sources and models through the saved query to its dashboard and
   the App.
3. **Notebooks.** Open **welcome** (under **Domains → commerce**) and click
   **Run all**, or click **New Notebook** and run the query
   from the [ZLens quickstart](https://duckcode-ai-labs.github.io/zlens/get-started/):

   ```sql
   select customer_name, count_lifetime_orders, lifetime_spend
   from dev.customers
   order by lifetime_spend desc
   limit 10
   ```

4. **Modeling**, then **Domain: Commerce.** **Map** draws the domain's
   dbt-backed models and joins; **Skills** shows the beverage and
   customer-analysis guidance Ask uses (`beverage-analysis`,
   `customer-profile`); **Saved queries** lists the four certified ones.
5. **Build your own App with Quick start** (no AI needed). In **Apps**, click
   **Build new App**, keep **Quick start** and click **Choose data**. On
   **Data for this App**, click **Add to App** on **Monthly Revenue**, then
   **Next: choose tiles**. ZLens proposes a total and a trend, such as
   **Total Gross Revenue** and **Gross Revenue by month**; click **Build App**
   and the tiles run on live data. A new App stays visible only to you until
   you click **Publish**.
6. **Saved queries.** Open `monthly_revenue`, `beverage_revenue_by_product`,
   `top_beverage_customers` or `customer_profile`.
7. **Ask** (needs an AI provider). Try:

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

To change a certified saved query (a block file), save your edit as a draft in
`domains/commerce/blocks/_drafts/<block>.dql` with `status = "draft"`, then:

```bash
npx zlens certify --from-draft domains/commerce/blocks/_drafts/<block>.dql --force
```

ZLens runs the certification rules (owner, compile, run, tests) and only when
they pass replaces the certified block and writes who certified it to
`semantic-layer/blocks/commerce/<block>.yaml`. In the workbench, **Certify**
on a saved query does the same.

## Project map

```text
models/                              dbt models and tests (source of truth)
dql.config.json                      ZLens workspace config and DuckDB connection
domains/commerce/domain.dql          business domain
domains/commerce/modeling/areas/     dbt-backed model areas
domains/commerce/skills/             domain guidance for Ask
domains/commerce/blocks/             certified saved queries (blocks), written in DQL
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
4. Save a repeated answer as a saved query (a draft), then certify it. Check the
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

- **`ZLens's DuckDB driver has no prebuilt binary for Node 26 yet`.** You are
  on Node 25 or 26. Switch to Node 24 LTS or 22 (`nvm install 24`, or
  `fnm use 24`), then run `npm run notebook` again: the driver installs on its
  own.
- **`Trying to read a database file with version number 999, but we can only
  read versions between 64 and 67. The database file was created with an
  newer version of DuckDB.`** (in the Setup "Test" button, Settings or
  `npm run doctor`). `jaffle_shop.duckdb` was built by Python DuckDB 2.0, and
  ZLens reads files from DuckDB 1.4. `requirements.txt` now pins
  `duckdb>=1.4,<1.5`; rerun `./setup.sh`, which reinstalls DuckDB 1.4 in
  `.venv`, moves the unreadable file to `jaffle_shop.from-newer-duckdb.duckdb`
  and rebuilds it. By hand: stop the workbench, then
  `.venv/bin/pip install 'duckdb>=1.4,<1.5'`, delete `jaffle_shop.duckdb` and
  run `dbt seed` and `dbt build` again (step 1).
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
