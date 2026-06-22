# Chapter 11 — Governed Agentic Analytics

[← Previous: Notebook Research](10-notebook-research-to-certified-block.md) | [Next: Trust Failure and Fix →](12-trust-failure-and-fix.md)

## Story Context

**AI should answer from certified blocks when possible and admit when a question
is not covered.** That is the difference between governed agentic analytics and
ordinary text-to-SQL.

## Business Value

Stakeholders can trust covered answers because they cite certified assets. New
analysis can still happen, but it is clearly labeled review-required.

## AI-First Workflow

Reindex and ask both a covered and uncovered question:

```bash
cd dql
npx dql agent reindex
npx dql agent ask "what is total revenue?"
npx dql agent ask "which weekday is strongest?"
```

The first question should resolve to a certified block. The second should stay
outside the certified surface until reviewed.

## Manual Review Path

For uncovered questions:

- inspect the generated or missing answer
- decide whether it deserves promotion
- create or update a DataLex contract
- save a DQL draft block
- add tests and context
- certify only after review

## Files to Inspect

- `dql/blocks/revenue/total_revenue.dql`
- `dql/dql-manifest.json`
- `dql/.dql/` local graph artifacts, when generated

## Checkpoint

Covered questions cite certified blocks. Uncovered questions remain
review-required.

![Certified and review-required agent answers](../../assets/tutorials/jaffle/dql/05-agent-answer-paper.png)

**Business proof:** AI answers covered questions from certified assets and
labels new analysis as review-required.

[← Previous: Notebook Research](10-notebook-research-to-certified-block.md) | [Next: Trust Failure and Fix →](12-trust-failure-and-fix.md)
