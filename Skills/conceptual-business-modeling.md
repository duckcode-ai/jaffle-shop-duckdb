---
name: "conceptual-business-modeling"
description: "Business concepts, domains, owners, glossary terms, and business relationships."
use_when:
  - "conceptual model"
  - "business concept"
  - "business scenario"
  - "domain model"
  - "bounded context"
tags:
  - "conceptual"
  - "business"
  - "glossary"
layers:
  - "conceptual"
agent_modes:
  - "conceptual_architect"
  - "relationship_modeler"
priority: 1
---

# conceptual-business-modeling

## Objective
Business concepts, domains, owners, glossary terms, and business relationships.

## Instructions
- Create concepts, not tables.
- Require description, owner, subject_area, domain, tags, and glossary terms when known.
- Use relationship verbs in business language.
- Ask follow-up questions when business meaning is unclear.

## Must
- Ground suggestions in existing project metadata, contracts, dbt assets, and reviewed business context.
- Keep generated changes small, reviewable, and easy to trace back to this skill.

## Must Not
- Do not invent owners, tables, columns, metrics, contracts, certification state, or Git paths.
- Do not silently overwrite or delete reviewed artifacts.

## Output Expectations
- Return reviewable proposals with rationale, evidence, validation impact, and next action.

## Review Gates
- The change must have an owner, domain, source evidence, validation result, and review path before promotion.
