# Jaffle Shop — DQL Workspace

A [DQL](https://github.com/duckcode-ai/dql) analytics layer on top of the
Jaffle Shop dbt project and the sibling `../DataLex` contract pack. dbt owns
the transformations; DataLex certifies business definitions; DQL serves those
definitions as **certified analytics blocks**, a **Growth Command Center App**,
notebooks, lineage, and governed agent answers.

## Run it

From the repo root, build the DataLex manifest first:

```bash
/Users/Kranthi_1/DataLex/datalex datalex manifest build DataLex --out "$(pwd)/DataLex/datalex-manifest.json"
cd dql
```

Then run the DQL gate and notebook:

```bash
npm install
npx dql validate
npx dql app build
npx dql verify
npm run notebook     # http://127.0.0.1:3474
```

The default connection points at the dbt-built `../jaffle_shop.duckdb`, and the
dbt DAG is already synced. If you rebuild dbt, run `npm run sync` to refresh.

Open the left rail:
- **Blocks** — 10 certified blocks, each with a `datalex_contract`
- **Apps → Jaffle Growth Command Center** — executive revenue, customer, and product views
- **Lineage** — `raw → dbt models → DataLex contracts → certified blocks → App`

## What's inside

| Domain | Blocks |
|---|---|
| **revenue** | `total_revenue`, `total_orders`, `avg_order_value`, `revenue_by_month`, `revenue_by_location`, `food_vs_drink_revenue` |
| **customers** | `total_customers`, `new_vs_returning_customers`, `top_customers` |
| **products** | `top_products` |

```
blocks/        certified .dql blocks, by domain
apps/          the Growth Command Center App + dashboard page
notebooks/     a welcome notebook exploring the marts
dql.config.json  connection + dbt + DataLex manifest wiring
```

## Tutorial

Follow [`TUTORIAL.md`](./TUTORIAL.md) for the DQL side and
[`../TUTORIAL.md`](../TUTORIAL.md) for the full AI-first DataLex + DQL story.
