# Build your first DQL block (hands-on)

This branch ships a working DQL workspace: **10 certified blocks** across three
domains and a **Jaffle Analytics** App with an executive dashboard. Use them as
a reference, then build one more block yourself and watch it flow through
certification, the dashboard, lineage, and the agent.

> Time: ~15 minutes. From this `dql/` folder: `npm install` then
> `npm run notebook` (opens <http://127.0.0.1:3474>).

The dbt warehouse is already built (`../jaffle_shop.duckdb`) and synced. If you
rebuild dbt, re-run `npm run sync` to refresh the imported DAG.

---

## What's already here

| Domain | Blocks |
|---|---|
| **revenue** | `total_revenue`, `total_orders`, `avg_order_value`, `revenue_by_month`, `revenue_by_location`, `food_vs_drink_revenue` |
| **customers** | `total_customers`, `new_vs_returning_customers`, `top_customers` |
| **products** | `top_products` |

Open **Blocks** in the left rail to inspect them, **Apps → Jaffle Analytics**
to see them composed into the executive dashboard, and **Lineage** for the full
graph from `raw_orders` through the dbt models to every block.

---

## Step 1 — Create a block

You'll add **revenue by weekday** — a real question ("which day sells most?")
that isn't in the set yet.

In the notebook UI: **Blocks → + New → SQL Block**, name it
`revenue_by_weekday`, domain `revenue`. Or create the file directly at
`blocks/revenue/revenue_by_weekday.dql`:

```dql
// dql-format: 1

block "revenue_by_weekday" {
  domain      = "revenue"
  type        = "custom"
  status      = "draft"
  owner       = "you@your-company.com"
  description = "Revenue by day of week, to spot weekly seasonality."
  tags        = ["revenue", "seasonality"]
  llmContext  = "Revenue grouped by day of week from the dbt orders mart, to reveal which weekdays drive the most sales."
  examples = [
    { question = "Which day of the week makes the most revenue?" }
  ]
  query = """
    SELECT dayname(ordered_at) AS weekday, SUM(order_total) AS revenue
    FROM dev.orders
    GROUP BY 1
    ORDER BY revenue DESC
  """
  visualization {
    chart = "bar"
    x     = "weekday"
    y     = "revenue"
  }
  tests {
    assert row_count >= 1
  }
}
```

> **Two syntax rules worth knowing now:** a block may use **one** triple-quoted
> (`"""…"""`) string — reserve it for `query` and keep `llmContext` on a single
> line. And `assert` takes a bare column name (`assert row_count >= 1`), not a
> function call.

---

## Step 2 — Run and certify it

```bash
npx dql certify blocks/revenue/revenue_by_weekday.dql
```

You should see the metadata checks pass and the assertion run against the real
warehouse:

```
  Block: "revenue_by_weekday"
  Status: ✓ CERTIFIABLE
  Tests (1 assertions):
    ✓ assert row_count >= 1 (actual: 7)
```

Set `status = "certified"` in the file (the certify gate is what earns it).
Certification is a **local trust label**: required metadata present, query
runs, tests pass.

> **DuckDB is single-writer.** If `certify` reports a "Conflicting lock" error,
> the notebook server is holding `jaffle_shop.duckdb`. Stop it (Ctrl-C the
> `npm run notebook` process) and re-run `certify`, or certify before starting
> the notebook.

---

## Step 3 — Add it to the dashboard

Open `apps/jaffle-analytics/dashboards/overview.dqld` and add a tile to the
`items` array (pick a free row, e.g. `y: 14`):

```json
{
  "i": "weekday",
  "x": 0, "y": 14, "w": 6, "h": 4,
  "title": "Revenue by weekday",
  "block": { "blockId": "revenue_by_weekday" },
  "viz": { "type": "bar", "options": { "x": "weekday", "y": "revenue" } }
}
```

Rebuild and confirm the reference resolved:

```bash
npx dql app build
```

`Built 1 app(s), 1 dashboard(s)` with no unresolved-ref warning means the tile
is wired. Reopen **Apps → Jaffle Analytics** — your chart renders live.

---

## Step 4 — Compile, then see it in lineage

```bash
npx dql compile
npx dql lineage --block revenue_by_weekday
```

The block now traces back through `dev.orders` → the dbt `orders` model → its
staging models → `raw_orders`. Everything from a dashboard tile to the source
table is one connected graph.

---

## Step 5 — Ask the agent (optional)

If you've configured an LLM provider (Settings, or an `ANTHROPIC_API_KEY` /
`OPENAI_API_KEY` env var, or local Ollama):

```bash
npx dql agent reindex
npx dql agent ask "which weekday makes the most revenue?"
```

It should answer **from your certified block** and cite it — not improvise
SQL. Ask something no block covers and the answer is flagged *Uncertified* and
saved as a draft under `blocks/_drafts/`, ready for you to review and certify.
That's the loop: trusted answers compound.

---

## Where to go next

- More ideas on this dataset: orders per day, repeat-purchase rate, revenue by
  customer cohort, average items per order.
- A **semantic block** on the dbt MetricFlow metrics this project ships
  (`npm run sync` imported 19 of them) — see the
  [DQL docs](https://github.com/duckcode-ai/dql/blob/main/docs/tutorials/02-authoring-blocks.md).
- Do this same flow on **your own dbt repo**: `npx create-dql-app@latest dql`
  inside it, point `dql.config.json` at your warehouse, `npm run sync`, and
  you're here.
