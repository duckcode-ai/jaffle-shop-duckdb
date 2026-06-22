# Chapter 13 — CI and OSS Adoption

[← Previous: Trust Failure and Fix](12-trust-failure-and-fix.md) | [Back to Tutorial Overview](README.md)

## Story Context

**Trust must survive pull requests, not just a local demo.** The final tutorial
step proves that a contributor can clone the repo, rebuild the evidence, and
verify the governed analytics layer.

## Business Value

CI keeps the DataLex + DQL workflow adoptable. Teams can review changes to dbt
models, DataLex contracts, DQL blocks, Apps, and lineage before merging.

## AI-First Workflow

Ask AI to generate a PR summary that explains:

- changed DataLex contracts
- changed DQL blocks
- app and dashboard impact
- lineage impact
- review-required work that should not be certified yet

The summary helps reviewers, but the checks below remain the source of truth.

## Manual Review Path

Run the full gate:

```bash
dbt build --profiles-dir . --exclude resource_type:seed
datalex datalex validate DataLex
datalex datalex manifest build DataLex --out "$(pwd)/DataLex/datalex-manifest.json"
cd dql
npx dql validate
npx dql app build
npx dql verify
```

If you are using a local DataLex source checkout, replace `datalex` with that
checkout's executable path.

## Files to Inspect

- `DataLex/datalex-manifest.json`
- `dql/dql-manifest.json`
- `dql/apps/jaffle-analytics/`
- changed contract, block, and dashboard files in Git

## Checkpoint

The repo can rebuild dbt evidence, publish the DataLex manifest, validate DQL,
build the App, and verify the manifest without manual cleanup.

## Adoption Rule

**Use this repo when users want the full example.** Keep the DataLex and DQL
repos product-focused so users can either follow this Jaffle Shop flow or bring
their own dbt repo.

[← Previous: Trust Failure and Fix](12-trust-failure-and-fix.md) | [Back to Tutorial Overview](README.md)
