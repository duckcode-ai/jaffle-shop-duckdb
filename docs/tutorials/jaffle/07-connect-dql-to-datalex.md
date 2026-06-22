# Chapter 7 — Connect DQL to DataLex

[← Previous: Publish Manifest](06-publish-manifest.md) | [Next: Certified DQL Blocks →](08-certified-dql-blocks.md)

## Story Context

**DQL should execute trusted answers only when they bind to certified business
meaning.** A block can run SQL, but a certified block should also point to the
DataLex contract it implements.

## Business Value

This creates a practical trust boundary. If a contract id is wrong or missing,
the failure happens during validation instead of inside an executive dashboard
or AI answer.

## AI-First Workflow

Ask DQL to map certified blocks to contract ids. For example:

```text
revenue_by_month -> revenue.Order.monthly_revenue@1
```

AI can suggest mappings, but the reviewer confirms whether the SQL output
actually matches the contract signature.

## Manual Review Path

Check `dql/dql.config.json`:

```json
"datalex": {
  "manifestPath": "../DataLex/datalex-manifest.json"
}
```

Then open certified blocks and confirm each one includes a valid
`datalex_contract` reference.

## Files to Inspect

- `dql/dql.config.json`
- `DataLex/datalex-manifest.json`
- `dql/blocks/revenue/revenue_by_month.dql`
- `dql/blocks/revenue/total_revenue.dql`

## Checkpoint

Run:

```bash
cd dql
npx dql validate --format json
```

Expected result: zero diagnostics.

![Contract-bound DQL block](../../assets/tutorials/jaffle/dql/01-contract-bound-block-paper.png)

**Business proof:** a certified DQL block names the exact DataLex contract it
implements.

[← Previous: Publish Manifest](06-publish-manifest.md) | [Next: Certified DQL Blocks →](08-certified-dql-blocks.md)
