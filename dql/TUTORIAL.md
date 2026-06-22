# Jaffle Shop DQL Tutorial

This folder is the DQL half of the Jaffle Shop Growth Command Center tutorial.
The full end-to-end story starts one directory up in [`../TUTORIAL.md`](../TUTORIAL.md):
dbt evidence -> DataLex proposal pack -> certified DataLex manifest -> DQL
contract-bound blocks -> App -> governed agent answers.

## What DQL Adds

DataLex certifies the business definitions. DQL makes those definitions useful
for stakeholders:

- 10 certified `.dql` blocks across revenue, customers, and products.
- Every certified block has a `datalex_contract = "...@1"` binding.
- Two business views: `Customer 360` and `Jaffle Growth Pulse`.
- One certified app: `Jaffle Growth Command Center`.
- One notebook for research and stakeholder walkthroughs.
- Lineage from DuckDB tables through blocks, charts, business views, and app.

## Run the DQL Side

From the repo root:

```bash
datalex datalex manifest build DataLex --out "$(pwd)/DataLex/datalex-manifest.json"
cd dql
npm install
npx dql validate
npx dql app build
npx dql verify
npm run notebook
```

Open <http://127.0.0.1:3474> and use the Paper theme.

If you are running DataLex from a local source checkout, replace `datalex` with
the path to that checkout's executable.

## Chapter 1. Contract-Bound Blocks

Open `blocks/revenue/revenue_by_month.dql`.

AI-first: ask DQL to explain why this block answers "How is revenue trending?"
It should cite the SQL, `llmContext`, business terms, and
`revenue.Order.monthly_revenue@1`.

Manual review:

- `status = "certified"`
- `datalex_contract = "revenue.Order.monthly_revenue@1"`
- SQL reads `dev.orders`
- output grain is one row per calendar month
- tests assert at least one row

Validation:

```bash
npx dql validate --format json
```

Expected result: zero diagnostics.

## Chapter 2. Growth Command Center App

Open `apps/jaffle-analytics/dashboards/overview.dqld`.

AI-first: ask DQL to generate an app plan from certified blocks only.

Manual review:

- KPI row: revenue, orders, AOV, customers
- Trend: monthly revenue
- Customer view: new vs returning by lifetime spend
- Product view: food vs drink and top products
- Table: top customers

Build:

```bash
npx dql app build
```

Expected result: 1 app, 1 dashboard, no unresolved references.

## Chapter 3. Notebook Research to Draft Block

Use the notebook for questions that are not certified yet, such as "which
weekday sells most?"

AI-first: let the notebook generate review-required SQL.

Manual path:

1. Inspect the SQL and source columns.
2. Save a draft block.
3. Add owner, description, tests, `llmContext`, terms, and a DataLex contract.
4. Run validation.
5. Set `status = "certified"` only after review.

The key teaching point: exploration is allowed, but it is not served as a
certified stakeholder answer until review.

## Chapter 4. Governed Agentic Analytics

Covered questions should resolve to certified blocks:

```bash
npx dql agent reindex
npx dql agent ask "what is total revenue?"
```

Uncovered drilldowns should remain review-required until promoted:

```bash
npx dql agent ask "which weekday is strongest?"
```

The agent flow is intentionally graduated: certified blocks first, metadata
routing second, review-required drafts last.

## Chapter 5. Trust Failure and Fix

Break one contract id, for example:

```dql
datalex_contract = "revenue.Order.not_a_contract@1"
```

Run:

```bash
npx dql validate
```

DQL should fail the binding check. Restore the correct id and rerun validation.
This is the governance lesson: bad business-definition references fail before
stakeholders or AI agents use the answer.

## Chapter 6. CI Gate

Run the full DQL gate after DataLex manifest build:

```bash
npx dql validate
npx dql app build
npx dql verify
```

Expected result: validation diagnostics are clean, app build succeeds, and
verify returns `{"ok":true}`.
