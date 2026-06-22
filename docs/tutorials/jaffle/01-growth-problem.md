# Chapter 1 — Jaffle Shop Growth Problem

[← Tutorial overview](README.md) | [Next: Prepare dbt Evidence →](02-prepare-dbt-evidence.md)

## Story Context

**Jaffle Shop leadership has a simple business question that usually becomes a
messy analytics problem:** why is revenue moving, which products are driving
growth, and which customers matter most?

The data team already has dbt models. The problem is not a lack of SQL. The
problem is trust: different people can ask the same question and get different
answers if definitions are not governed.

## Business Value

**The goal is one trusted Growth Command Center.** Executives should not need to
know which table, notebook, or SQL draft produced a number. They should see a
clear answer with lineage back to reviewed business meaning.

## AI-First Workflow

Ask DataLex to summarize the dbt project from evidence:

- likely business domains
- high-value marts
- semantic metrics and tests
- missing ownership or contract gaps
- candidate questions that deserve certification

AI is useful here because it can quickly connect dbt metadata to business
language. It is not trusted yet; it is drafting a map for review.

## Manual Review Path

Inspect the marts that make the growth story real:

- `models/marts/orders.yml`
- `models/marts/customers.yml`
- `models/marts/order_items.yml`

Confirm that the story comes from orders, customers, products, and item-level
revenue rather than invented concepts.

## Files to Inspect

- `models/marts/orders.yml`
- `models/marts/customers.yml`
- `models/marts/order_items.yml`
- `target/manifest.json`

## Checkpoint

The user should understand the main governance rule:

**DataLex starts from dbt evidence. It does not create business meaning from a
blank canvas.**

![DataLex connected dbt evidence](../../assets/tutorials/jaffle/datalex/01-dbt-evidence-paper.png)

**Business proof:** DataLex reads the real dbt project before AI proposes
business meaning.

[← Tutorial overview](README.md) | [Next: Prepare dbt Evidence →](02-prepare-dbt-evidence.md)
