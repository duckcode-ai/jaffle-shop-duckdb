# Jaffle Shop + DQL — guided tour

This workspace is a complete DQL governed-analytics layer on top of the Jaffle
Shop dbt project: **10 certified blocks**, a **Jaffle Analytics** App with an
executive dashboard, a notebook, and full lineage. This guide takes you on a
tour of what's built, then walks you through adding your own block, then points
at where to go next.

> Setup (once): from this `dql/` folder run `npm install`, then
> `npm run notebook` (opens <http://127.0.0.1:3474>). The dbt warehouse is
> already built (`../jaffle_shop.duckdb`) and synced; if you rebuild dbt, run
> `npm run sync` to refresh.

---

# Part 1 — Take the tour (~5 minutes)

## 1. The certified blocks

Click **Blocks** in the left rail. There are 10 certified blocks across three
domains — each one a single `.dql` file holding SQL, an owner, a description,
agent context, and tests:

| Domain | Blocks |
|---|---|
| **revenue** | `total_revenue`, `total_orders`, `avg_order_value`, `revenue_by_month`, `revenue_by_location`, `food_vs_drink_revenue` |
| **customers** | `total_customers`, `new_vs_returning_customers`, `top_customers` |
| **products** | `top_products` |

Open `revenue_by_month` and hit **Run** — it queries the dbt `orders` mart live.
Notice the green **certified** badge: it passed the local certification gate
(metadata present, query runs, tests pass).

## 2. The executive App

Click **Apps → Jaffle Analytics → Executive Overview**. This is the consumption
surface a stakeholder would open — a dashboard composed entirely of certified
blocks:

- a KPI row — **revenue $671.4K · orders 61,948 · avg order $10.84 · 935 customers**
- revenue by month, food vs. drink, revenue by location, top products,
  new-vs-returning customers, and a top-customers table

Every tile shows the `block:` it's backed by — the dashboard never holds its own
SQL. Toggle **View / Build** (top right): Build lets you drag, resize, and add
tiles; View is the clean consumer mode.

## 3. The lineage

Click **Lineage**. The graph connects everything: `raw` sources → dbt staging
models → dbt marts → certified blocks → the App. This is the picture of *where
every number comes from* — 32 nodes from source table to dashboard tile.

## 4. Ask the agent (optional)

If you've set an LLM provider (Settings, or an `ANTHROPIC_API_KEY` /
`OPENAI_API_KEY` env var, or local [Ollama](https://ollama.com)):

```bash
npx dql agent reindex
npx dql agent ask "what is our total revenue?"
```

It answers **from the certified block** and cites it — not improvised SQL. Ask
something no block covers and the proposal is flagged *Uncertified* and saved as
a draft for review. That's the governed-answer loop.

---

# Part 2 — Build your own block (~15 minutes)

You'll add **revenue by weekday** — a real question ("which day sells most?")
that isn't in the set yet.

## Step 1 — Create the block

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

> **Two syntax rules:** a block uses **one** triple-quoted (`"""…"""`) string —
> reserve it for `query` and keep `llmContext` on a single line. And `assert`
> takes a bare column name (`assert row_count >= 1`), not a function call.

## Step 2 — Certify it

```bash
npx dql certify blocks/revenue/revenue_by_weekday.dql
```

```
  Block: "revenue_by_weekday"
  Status: ✓ CERTIFIABLE
  Tests (1 assertions):
    ✓ assert row_count >= 1 (actual: 7)
```

Set `status = "certified"` in the file. Certification is a **local trust
label**: required metadata present, query runs, tests pass.

> **DuckDB is single-writer.** If `certify` reports a "Conflicting lock" error,
> the notebook server is holding `jaffle_shop.duckdb` — stop it (Ctrl-C
> `npm run notebook`) and re-run, or certify before starting the notebook.

## Step 3 — Add it to the dashboard

Open `apps/jaffle-analytics/dashboards/overview.dqld` and add a tile to `items`
(pick a free row, e.g. `y: 14`):

```json
{
  "i": "weekday",
  "x": 0, "y": 14, "w": 6, "h": 4,
  "title": "Revenue by weekday",
  "block": { "blockId": "revenue_by_weekday" },
  "viz": { "type": "bar", "options": { "x": "weekday", "y": "revenue" } }
}
```

```bash
npx dql app build
```

`Built 1 app(s), 1 dashboard(s)` with no unresolved-ref warning means it's
wired. Reopen the App — your chart renders live.

## Step 4 — Compile and trace lineage

```bash
npx dql compile
npx dql lineage --block revenue_by_weekday
```

It now traces `dev.orders` → dbt `orders` → staging → `raw_orders`. From
dashboard tile to source table, one connected graph.

## Step 5 — Ask the agent about it

```bash
npx dql agent reindex
npx dql agent ask "which weekday makes the most revenue?"
```

Answered from your new certified block.

---

# Part 3 — Go further

Readymade next steps to round out the example — each is a small, self-contained
addition:

1. **Attach a notebook to the App.** In the App's **Build** panel, add the
   `welcome` notebook as an analysis page — stakeholders get the dashboard plus
   a narrative, read-only.

2. **Author a semantic block.** This dbt project ships MetricFlow metrics
   (`npm run sync` imported 19). Create a semantic block off one of them instead
   of writing raw SQL — see the
   [authoring guide](https://github.com/duckcode-ai/dql/blob/main/docs/tutorials/02-authoring-blocks.md).

3. **Add a second dashboard page.** Create
   `apps/jaffle-analytics/dashboards/customers.dqld` focused on the customers
   domain (`total_customers`, `new_vs_returning_customers`, `top_customers`),
   then `npx dql app build`. The App now has two pages.

4. **Wire the MCP server to your editor.** Let Claude Code or Cursor answer from
   these certified blocks:
   ```bash
   claude mcp add dql -- npx @duckcodeailabs/dql-cli mcp
   ```
   Ask it a revenue question — it answers from the blocks and cites them.

5. **Gate it in CI.** Add `npx dql verify` to a GitHub Action so the manifest
   stays reproducible — see the
   [CI tutorial](https://github.com/duckcode-ai/dql/blob/main/docs/tutorials/05-ci-and-verify.md).

When you're ready, run this same flow on **your own dbt repo**:
`npx create-dql-app@latest dql` inside it, point `dql.config.json` at your
warehouse, `npm run sync`, and you're here.
