# Chapter 8 — Generate Certified DQL Blocks

[← Previous: Connect DQL to DataLex](07-connect-dql-to-datalex.md) | [Next: Growth Command Center App →](09-growth-command-center-app.md)

## Story Context

**Repeated stakeholder questions should become reusable answer units.** Jaffle
Shop should not rebuild the same revenue, order, customer, and product queries
in every notebook or dashboard.

## Business Value

DQL blocks package SQL with owner, status, tests, terms, chart intent, and AI
context. That makes the answer reusable, reviewable, and traceable.

## AI-First Workflow

Generate or refine blocks for:

- total revenue
- monthly revenue
- average order value
- order count
- customer count
- customer value
- product mix
- location performance

AI can draft SQL and metadata, but a human reviews every certified block.

## Manual Review Path

For each block, inspect:

- SQL source models
- `status`
- `datalex_contract`
- `terms`
- tests
- `llmContext`
- chart intent

Keep `status = "certified"` only when the block output matches the DataLex
contract and the SQL is clear enough to maintain.

## Files to Inspect

- `dql/blocks/revenue/`
- `dql/blocks/customers/`
- `dql/blocks/products/`
- `dql/terms/`
- `dql/domains/`

## Checkpoint

`npx dql compile` emits a manifest with 10 certified blocks and contract-bound
lineage.

![DQL block validation results](../../assets/tutorials/jaffle/dql/02-block-validation-paper.png)

**Business proof:** governed definitions still execute against the local DuckDB
data and return inspectable results.

[← Previous: Connect DQL to DataLex](07-connect-dql-to-datalex.md) | [Next: Growth Command Center App →](09-growth-command-center-app.md)
