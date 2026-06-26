# DataLex — Jaffle Shop commerce contract layer

This is the **DataLex** layer of the example: an AI-first, Git-reviewed business
contract layer that sits above the dbt + DuckDB project. dbt models the data;
DataLex adds the conceptual/logical/physical **models**, **glossary**,
**relationships**, and certified **contracts** that downstream tools (DQL, AI
agents) can trust.

Open it with the DataLex UI:

```bash
# from the repo root
./start.sh                       # DataLex on http://localhost:3030
# or directly:
datalex serve --project-dir DataLex
```

## What's here

```
DataLex/
  datalex.yaml                 # project manifest (globs for each artifact type)
  domains/
    commerce.yaml              # the commerce subject area
  commerce/
    conceptual/                # business entities (customer, order, ...)
    logical/                   # attributes, types, keys, relationships
    physical/                  # DuckDB dev.* tables (postgres dialect)
    relationships/             # how entities relate
    glossary/                  # governed business terms (revenue, AOV, LTV, ...)
    contracts/                 # certified business contracts (feed the manifest)
    proposals/                 # draft AI proposals awaiting review
  datalex-manifest.json        # build output (gitignored) — the DQL/agent handoff
```

Three modeling layers for six entities (`customer`, `order`, `order_item`,
`product`, `supply`, `location`):

| Layer | Question it answers | Example field |
| --- | --- | --- |
| **Conceptual** | What business things exist? | `order` *places* `customer` |
| **Logical** | What attributes/keys/types? | `order.order_total : money` |
| **Physical** | Where does it live? | `dev.orders.order_total : decimal(16,2)` |

## Contracts and governance

Only **certified** contracts enter `datalex-manifest.json`. This pack ships:

| Contract | Status | In manifest? |
| --- | --- | --- |
| `commerce.Orders.revenue` | certified | ✅ |
| `commerce.Customers.lifetime_value` | certified | ✅ |
| `commerce.Orders.food_drink_split` | reviewed | ❌ (not yet certified) |

Two example **proposals** sit in `commerce/proposals/` as drafts the way an AI
agent would leave them — a `revenue_by_location` metric and a `new_customer_rate`
glossary term — awaiting human review before promotion.

## Commands

```bash
datalex datalex validate DataLex          # schema + semantic validation
datalex datalex info DataLex              # summary (entities by layer, terms, ...)
datalex datalex manifest build DataLex    # build datalex-manifest.json
```

`setup.sh` runs `validate` and `manifest build` automatically.

## AI generation

Generating *new* contracts/proposals from dbt evidence requires an AI provider.
The `datalex-cli[serve,duckdb,draft,draft-openai]` install (from
[`requirements.txt`](../requirements.txt)) bundles the **Claude (anthropic)** and
**OpenAI** SDKs; **Ollama** works locally with no extra package. Provide a key in
the UI's **AI Setup** panel, or export one before launching:

```bash
export ANTHROPIC_API_KEY=sk-ant-...      # Claude (default provider)
# or OPENAI_API_KEY=sk-...               # OpenAI
datalex draft --dbt .. --domain commerce # CLI generation against the dbt project
```

> Gemini (`draft-gemini`) is intentionally not installed: its `google-generativeai`
> dependency pulls a `protobuf` version that conflicts with dbt. Use Claude,
> OpenAI, or Ollama.
