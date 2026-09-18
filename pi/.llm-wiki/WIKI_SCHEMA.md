# LLM Wiki Schema

## Ownership Rules

| Path | Owner | Rule |
|------|-------|------|
| raw/** | extension | immutable after capture |
| wiki/** | model + user | editable knowledge pages |
| meta/events.jsonl | extension tools | append-only authoritative state |
| meta/* except events.jsonl | extension | generated projections |
| . | human + explicit request | operating rules |

Back up `meta/events.jsonl` to preserve activity history. Generated logs cannot reconstruct it.

## Source Packet Format

```
raw/sources/SRC-YYYY-MM-DD-NNN/
  manifest.json
  original/
  extracted.md
  attachments/
```

## Page Types

- **source** — what this specific source says
- **entity** — people, orgs, tools, products
- **concept** — ideas, patterns, frameworks
- **synthesis** — cross-source theses and tensions
- **analysis** — durable filed answers from queries
- **requirement** — atomic requirements with status, priority, and traceability

## Linking Style

- New internal links: [label](/folder/page.md)
- Legacy readable links: [[folder/page]]
- Source citation: [source](/sources/SRC-YYYY-MM-DD-NNN.md)
