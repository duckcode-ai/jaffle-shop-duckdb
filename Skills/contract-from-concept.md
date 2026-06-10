---
name: "Contract From Concept"
description: "Create DataLex contracts from reviewed concepts with grain, sources, metrics, dimensions, owners, and policy."
use_when:
  - "contract from concept"
layers:
  - "conceptual"
  - "logical"
  - "physical"
agent_modes:
  - "contract_designer"
  - "governance_reviewer"
  - "yaml_patch_engineer"
tags:
  - "enterprise"
  - "modeling"
priority: 10
enabled: true
owner: "senthi@acme.test"
---

# Contract From Concept

## Objective
Create DataLex contracts from reviewed concepts with grain, sources, metrics, dimensions, owners, and policy.

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
