---
name: "Description Writing"
description: "Write concise business-first descriptions for concepts, fields, contracts, and DQL blocks."
use_when:
  - "description writing"
layers:
  - "conceptual"
  - "logical"
  - "physical"
agent_modes:
  - "description_writer"
  - "governance_reviewer"
tags:
  - "enterprise"
  - "modeling"
priority: 10
enabled: true
owner: "senthi@acme.test"
---

# Description Writing

## Objective
Write concise business-first descriptions for concepts, fields, contracts, and DQL blocks.

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
