# Chapter 12 — Trust Failure and Fix

[← Previous: Governed Agentic Analytics](11-governed-agentic-analytics.md) | [Next: CI and OSS Adoption →](13-ci-and-oss-adoption.md)

## Story Context

**Governance matters most when something is wrong.** A bad contract reference
should fail before a stakeholder sees the number or an AI agent uses the block.

## Business Value

Trust gates reduce silent drift. If a certified block points to the wrong
business definition, validation should make that visible.

## AI-First Workflow

Ask the agent to explain a failing contract reference and suggest the nearest
valid contract id. AI can help debug, but it should not silently repair trust
metadata without review.

## Manual Review Path

Temporarily break a contract id:

```dql
datalex_contract = "revenue.Order.not_a_contract@1"
```

Run validation, confirm the failure, restore the correct id, and rerun
validation.

## Files to Inspect

- `dql/blocks/revenue/total_revenue.dql`
- `DataLex/datalex-manifest.json`
- `dql/dql.config.json`

## Checkpoint

The failure is visible at validation time, before the App or MCP serves the
answer.

![Trust failure and fix](../../assets/tutorials/jaffle/dql/06-trust-failure-paper.png)

**Business proof:** bad contract references fail before stakeholders or AI
agents can consume the answer.

[← Previous: Governed Agentic Analytics](11-governed-agentic-analytics.md) | [Next: CI and OSS Adoption →](13-ci-and-oss-adoption.md)
