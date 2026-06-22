# Chapter 4 — Review AI Proposals

[← Previous: Generate Proposal Pack](03-generate-proposal-pack.md) | [Next: Certify Contracts →](05-certify-contracts.md)

## Story Context

**AI is fast, but speed is not trust.** A proposal becomes useful only when a
human can explain the grain, source model, output fields, assumptions, and risk.

## Business Value

Review makes generated content accountable. It turns a plausible AI draft into
analytics work that can be edited, discussed, and committed.

## AI-First Workflow

Ask AI to explain each proposed contract in business language:

- What question does this answer?
- What is the grain?
- Which dbt model supports it?
- What measures and dimensions are approved?
- What assumptions could make the answer wrong?
- What still needs human confirmation?

## Manual Review Path

Edit the contract YAML before certification:

- owner
- source model
- grain
- signature inputs and outputs
- assumptions
- review cadence
- status

The reviewer should be able to explain the contract without showing SQL first.

## Files to Inspect

- `DataLex/revenue/contracts/total_revenue.contract.yaml`
- `DataLex/revenue/contracts/monthly_revenue.contract.yaml`
- `DataLex/customers/contracts/top_customers_by_lifetime_spend.contract.yaml`
- `DataLex/products/contracts/top_products_by_revenue.contract.yaml`

## Checkpoint

Every reviewed contract has enough context for a future analyst to understand
what it means and why it exists.

![Proposal review](../../assets/tutorials/jaffle/datalex/04-proposal-review-paper.png)

**Business proof:** confidence, assumptions, source models, and changed files
are visible before certification.

[← Previous: Generate Proposal Pack](03-generate-proposal-pack.md) | [Next: Certify Contracts →](05-certify-contracts.md)
