# Jaffle Shop — DQL workspace

A [DQL](https://github.com/duckcode-ai/dql) analytics layer on top of the
Jaffle Shop dbt project. dbt owns the models; DQL adds **certified analytics
blocks**, an **App** with an executive dashboard, and end-to-end **lineage**
from raw sources through the dbt DAG to every answer.

## Run it

```bash
npm install
npm run notebook     # http://127.0.0.1:3474
```

The default connection points at the dbt-built `../jaffle_shop.duckdb`, and the
dbt DAG is already synced. If you rebuild dbt, run `npm run sync` to refresh.

Open the left rail:
- **Blocks** — 10 certified blocks (revenue, customers, products)
- **Apps → Jaffle Analytics** — the executive dashboard (revenue, orders, AOV,
  customers, locations, product mix, top customers)
- **Lineage** — `raw → dbt models → certified blocks → App`

## What's inside

| Domain | Blocks |
|---|---|
| **revenue** | `total_revenue`, `total_orders`, `avg_order_value`, `revenue_by_month`, `revenue_by_location`, `food_vs_drink_revenue` |
| **customers** | `total_customers`, `new_vs_returning_customers`, `top_customers` |
| **products** | `top_products` |

```
blocks/        certified .dql blocks, by domain
apps/          the Jaffle Analytics App + dashboard page
notebooks/     a welcome notebook exploring the marts
dql.config.json  connection + dbt wiring
```

## Build your own block

Follow [`TUTORIAL.md`](./TUTORIAL.md) — a ~15-minute hands-on: create a block,
certify it against the real warehouse, add it to the dashboard, trace its
lineage, and ask the agent. It's the same flow you'd run on **your own dbt
repo**: `npx create-dql-app@latest dql` inside it, point the config at your
warehouse, `npm run sync`.
