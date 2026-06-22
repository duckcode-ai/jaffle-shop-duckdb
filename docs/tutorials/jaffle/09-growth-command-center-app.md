# Chapter 9 — Build the Growth Command Center App

[← Previous: Certified DQL Blocks](08-certified-dql-blocks.md) | [Next: Notebook Research →](10-notebook-research-to-certified-block.md)

## Story Context

**Executives need one clean surface, not scattered SQL.** The Growth Command
Center should answer the first-order questions about revenue, customers, and
products without making leaders inspect implementation details.

## Business Value

The App gives stakeholders a focused experience while analytics keeps the
source of truth in Git-backed DQL files.

## AI-First Workflow

Ask DQL to generate an App plan from certified blocks only:

- KPI row for revenue, orders, AOV, and customers
- monthly revenue trend
- customer mix by value
- revenue by location
- food vs drink mix
- top products and customers

## Manual Review Path

Review:

- `dql/apps/jaffle-analytics/dql.app.json`
- `dql/apps/jaffle-analytics/dashboards/overview.dqld`

Every tile should point to a certified block. Avoid inline SQL in the App
surface because that bypasses the governed block layer.

## Files to Inspect

- `dql/apps/jaffle-analytics/dql.app.json`
- `dql/apps/jaffle-analytics/dashboards/overview.dqld`
- `dql/business-views/jaffle_growth_pulse.dql`

## Checkpoint

Run:

```bash
cd dql
npx dql app build
```

Expected result: 1 app, 1 dashboard, no unresolved references.

![Jaffle Growth Command Center App](../../assets/tutorials/jaffle/dql/03-growth-app-paper.png)

**Business proof:** stakeholders get one executive surface while analytics keeps
ownership in certified files.

[← Previous: Certified DQL Blocks](08-certified-dql-blocks.md) | [Next: Notebook Research →](10-notebook-research-to-certified-block.md)
