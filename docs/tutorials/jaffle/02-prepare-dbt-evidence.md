# Chapter 2 — Prepare dbt Evidence

[← Previous: Growth Problem](01-growth-problem.md) | [Next: Generate Proposal Pack →](03-generate-proposal-pack.md)

## Story Context

**dbt owns the transformation truth.** DataLex should certify meaning from the
existing transformation graph, not from disconnected prompts.

For Jaffle Shop, the important marts are the models that explain growth:
`orders`, `customers`, `order_items`, `products`, and `locations`.

## Business Value

When dbt evidence is fresh, AI can draft from facts: model names, columns,
tests, semantic metrics, and relationships. That makes the first proposal pack
much closer to reviewable work.

## AI-First Workflow

Ask DataLex to scan `target/manifest.json` and identify:

- revenue models and measures
- customer-level grain and identifiers
- product and item-level revenue paths
- tests that support certification
- gaps that still need human ownership

## Manual Review Path

Run the local dbt setup:

```bash
./setup.sh
```

Then confirm these generated artifacts exist:

- `target/manifest.json`
- `target/catalog.json`
- `target/semantic_manifest.json`
- `jaffle_shop.duckdb`

Inspect dbt YAML before trusting any proposal. The tutorial works because the
dbt project has real marts, descriptions, and tests.

## Files to Inspect

- `dbt_project.yml`
- `profiles.yml`
- `models/marts/orders.yml`
- `models/marts/customers.yml`
- `target/manifest.json`
- `target/catalog.json`

## Checkpoint

`target/manifest.json` exists, DuckDB has built marts in the `dev` schema, and
the readiness view can explain what is covered versus missing.

![DataLex readiness summary](../../assets/tutorials/jaffle/datalex/02-readiness-paper.png)

**Business proof:** readiness shows which dbt assets can support trusted
contracts and which gaps still need review.

[← Previous: Growth Problem](01-growth-problem.md) | [Next: Generate Proposal Pack →](03-generate-proposal-pack.md)
