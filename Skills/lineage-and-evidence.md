---
name: "Lineage And Evidence"
description: "Require source evidence and lineage paths for trusted concepts, contracts, DQL, and apps."
use_when:
  - "lineage and evidence"
layers:
  - "conceptual"
  - "logical"
  - "physical"
agent_modes:
  - "lineage_evidence_reviewer"
  - "lineage_explainer"
  - "governance_reviewer"
tags:
  - "enterprise"
  - "modeling"
priority: 10
enabled: true
owner: "senthi@acme.test"
---

# Lineage And Evidence

## Objective
Require source evidence and lineage paths for trusted concepts, contracts, DQL, and apps.

## Instructions
- Apply this standard when drafting or reviewing modeling, contract, DQL, documentation, or app-ready changes.
- Ground recommendations in existing project metadata, repo files, dbt assets, contracts, and lineage evidence.

## Must
- Keep changes small, reviewable, and linked to source evidence.
- Preserve human-authored names, descriptions, owners, and policies unless the user explicitly changes them.

## Must Not
- Do not invent owners, tables, columns, metrics, contracts, certification state, or Git paths.
- Do not silently certify, merge, delete, or overwrite production artifacts.

## Output Expectations
- Return rationale, evidence used, validation impact, open questions, and the next review action.

## Review Gates
- Owner, domain, source evidence, validation status, and review route must be clear before promotion.
