# Chapter 10 — Notebook Research to Certified Block

[← Previous: Growth Command Center App](09-growth-command-center-app.md) | [Next: Governed Agentic Analytics →](11-governed-agentic-analytics.md)

## Story Context

**Analysts still need room to explore.** Not every useful question is already a
certified block. The governance model should support exploration without
pretending that every draft is trusted.

## Business Value

Notebook research creates a safe path from new question to reviewed asset:
draft SQL, inspect results, save a draft block, add tests, bind a contract, then
certify.

## AI-First Workflow

Ask a new question, such as:

```text
Which weekday sells most?
```

or:

```text
Which products drive repeat customers?
```

The AI-generated SQL should be labeled review-required until it is promoted.

## Manual Review Path

Promote only after review:

1. Inspect SQL and source columns.
2. Save a draft block.
3. Add owner, description, tests, terms, and `llmContext`.
4. Add or bind the DataLex contract.
5. Run validation.
6. Certify only after the output is accepted.

## Files to Inspect

- `dql/notebooks/welcome.dqlnb`
- `dql/blocks/`
- `dql/terms/`
- `DataLex/*/contracts/`

## Checkpoint

The tutorial shows research as draft until a human promotes it.

![Notebook research flow](../../assets/tutorials/jaffle/dql/04-notebook-draft-paper.png)

**Business proof:** exploration is allowed, but it stays outside the certified
surface until reviewed.

[← Previous: Growth Command Center App](09-growth-command-center-app.md) | [Next: Governed Agentic Analytics →](11-governed-agentic-analytics.md)
