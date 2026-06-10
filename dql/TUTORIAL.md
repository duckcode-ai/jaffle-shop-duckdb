# Build your first DQL block (hands-on)

This branch already has a working DQL workspace: two certified blocks
(`revenue_by_month`, `new_vs_returning_customers`) and a **Jaffle Analytics**
App. Use them as a reference, then build a third block yourself and watch it
flow through certification, the dashboard, lineage, and the agent.

> Time: ~15 minutes. You'll need the workspace running — from this `dql/`
> folder: `npm install` then `npm run notebook` (opens
> <http://127.0.0.1:3474>).

The dbt warehouse is already built (`../jaffle_shop.duckdb`) and synced. If you
ever rebuild dbt, re-run `npm run sync` to refresh the imported DAG.

---

## What's already here

| Block | Domain | Reads from |
|---|---|---|
| `revenue_by_month` | revenue | `dev.orders` |
| `new_vs_returning_customers` | customers | `dev.customers` |

Open **Blocks** in the left rail to inspect them, and **Apps → Jaffle
Analytics** to see them composed into a dashboard. **Lineage** shows the full
path from `raw_orders` through the dbt models to each block.

---

## Step 1 — Create a block

You'll build **average order value** (AOV), a single-number KPI.

In the notebook UI: **Blocks → + New → SQL Block**. Name it
`avg_order_value`, domain `revenue`. Or just create the file directly at
`blocks/revenue/avg_order_value.dql`:

```dql
// dql-format: 1

block "avg_order_value" {
  domain      = "revenue"
  type        = "custom"
  status      = "draft"
  owner       = "you@your-company.com"
  description = "Average order value in dollars, across all orders."
  tags        = ["revenue", "kpi"]
  llmContext  = "Single-value KPI: the average order_total across all orders in the dbt orders mart. Use for 'what is our average order value / AOV' questions."
  examples = [
    { question = "What is our average order value?" }
  ]
  query = """
    SELECT ROUND(AVG(order_total), 2) AS avg_order_value
    FROM dev.orders
  """
  visualization {
    chart = "single_value"
  }
  tests {
    assert row_count == 1
  }
}
```

> **Two syntax rules worth knowing now:** a block may use **one** triple-quoted
> (`"""…"""`) string — reserve it for `query` and keep `llmContext` on a single
> line. And `assert` takes a bare column name (`assert row_count == 1`), not a
> function call.

---

## Step 2 — Run and certify it

```bash
npx dql certify blocks/revenue/avg_order_value.dql
```

You should see the metadata checks pass and the assertion run against the real
warehouse:

```
  Block: "avg_order_value"
  Status: ✓ CERTIFIABLE
  Tests (1 assertions):
    ✓ assert row_count == 1 (actual: 1)
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
`items` array:

```json
{
  "i": "aov",
  "x": 0, "y": 4, "w": 4, "h": 2,
  "title": "Average order value",
  "block": { "blockId": "avg_order_value" },
  "viz": { "type": "single_value" }
}
```

Rebuild and confirm the reference resolved:

```bash
npx dql app build
```

`Built 1 app(s), 1 dashboard(s)` with no unresolved-ref warning means the tile
is wired. Reopen **Apps → Jaffle Analytics** — your KPI renders live.

---

## Step 4 — Compile, then see it in lineage

```bash
npx dql compile
npx dql lineage --block avg_order_value
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
npx dql agent ask "what is our average order value?"
```

It should answer **from your certified block** and cite it — not improvise
SQL. Ask something no block covers ("how many orders included food?") and the
answer is flagged *Uncertified* and saved as a draft under `blocks/_drafts/`,
ready for you to review and certify. That's the loop: trusted answers compound.

---

## Where to go next

- More block ideas on this dataset: orders per day, food-vs-drink mix, revenue
  by customer cohort, top customers by lifetime spend.
- A **semantic block** on the dbt MetricFlow metrics this project already ships
  (`npm run sync` imported 19 of them) — see the
  [DQL docs](https://github.com/duckcode-ai/dql/blob/main/docs/tutorials/02-authoring-blocks.md).
- Do this same flow on **your own dbt repo**: `npx create-dql-app@latest dql`
  inside it, point `dql.config.json` at your warehouse, `npm run sync`, and
  you're here.
