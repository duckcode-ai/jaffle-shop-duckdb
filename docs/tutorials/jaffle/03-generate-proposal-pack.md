# Chapter 3 — Generate the Growth Proposal Pack

[← Previous: Prepare dbt Evidence](02-prepare-dbt-evidence.md) | [Next: Review AI Proposals →](04-review-ai-proposals.md)

## Story Context

**The data team needs a focused certification pack, not a folder full of random
AI suggestions.** For Jaffle Shop, the first pack should cover revenue,
customers, and products because those are the executive growth questions.

## Business Value

AI helps compress discovery time. Instead of manually reading every dbt model
and guessing which contracts to write first, DataLex proposes a small set of
business-ready candidates grounded in the dbt evidence.

## AI-First Workflow

Generate focused proposal packs for:

- revenue performance
- customer value and mix
- product revenue and category mix

The tutorial stores reviewed proposal files at:

- `DataLex/revenue/proposals/growth_revenue_pack.yaml`
- `DataLex/customers/proposals/growth_customer_pack.yaml`
- `DataLex/products/proposals/growth_product_pack.yaml`

## Manual Review Path

Open each proposal and review:

- source models and columns
- proposed contract ids
- business assumptions
- confidence level
- open questions
- whether the proposal is narrow enough to certify

Keep proposals as **reviewed draft evidence**. Certification happens in the
contract files, not in the proposal file.

## Files to Inspect

- `DataLex/revenue/proposals/growth_revenue_pack.yaml`
- `DataLex/customers/proposals/growth_customer_pack.yaml`
- `DataLex/products/proposals/growth_product_pack.yaml`

## Checkpoint

Proposal files are `status: reviewed`, and each one explains why a contract is
worth creating.

![Growth proposal pack](../../assets/tutorials/jaffle/datalex/03-proposal-pack-paper.png)

**Business proof:** AI groups revenue, customer, and product evidence into
reviewable proposal packs instead of scattered suggestions.

[← Previous: Prepare dbt Evidence](02-prepare-dbt-evidence.md) | [Next: Review AI Proposals →](04-review-ai-proposals.md)
