# Scraping OpenWebUI Docs for Knowledge Base

## Goal
Download the OpenWebUI documentation site (https://docs.openwebui.com) as clean text files for import into an OpenWebUI Knowledge base.

## Due Diligence (Being Polite)

| Check | Result |
|-------|--------|
| **robots.txt** | Does not exist (returns 404) |
| **License/Copyright** | MIT licensed open source project |
| **Docs source repo** | ✅ Found at https://github.com/open-webui/docs |
| **Scraping needed?** | **No!** Raw Markdown source is publicly available |

## Solution: Clone the Docs Repo

```bash
cd ~/temp
git clone --depth 1 https://github.com/open-webui/docs.git openwebui-docs-site
cd openwebui-docs-site
```

## Conversion Script

Script location: `~/temp/openwebui-docs-site/convert_for_kb.py`

What it does:
- Strips MDX frontmatter (`---...---`)
- Removes import/export statements
- Cleans admonition wrappers (`:::info`, `:::note`, `:::warning`, `:::danger`, `:::caution`) while keeping content
- Generates nice titles from file paths
- Adds source URL to each file
- Outputs clean `.txt` files

## Results ✅

- **213 files created**, 0 skipped
- **1,905.2 KB total** (1.9 MB)
- **Output location:** `~/temp/openwebui-docs-site/kb_ready/`

### Files by Section

| Section | Description |
|---------|-------------|
| `Reference - *` | Env config (246.9 KB!), API endpoints, HTTPS (Nginx/Caddy/HAProxy), monitoring, network diagrams |
| `Features - *` | RAG, MCP, pipelines, plugins, channels, memory, auth, RBAC, chat features, web search providers, media generation |
| `Getting Started - *` | Docker, Kubernetes, Python installs, providers (Ollama, OpenAI, vLLM, etc.), settings |
| `Tutorials - *` | Backups, Redis, SSO (Okta, Azure AD, Entra), MCP Notion, Jupyter, monitoring |
| `Troubleshooting - *` | Audio, connections, performance, RAG, SSO, database migration |
| `Enterprise - *` | Architecture, security, integration, customization |
| Top-level | FAQ (32 KB), Features overview (49.7 KB), Intro, License, Roadmap, Security |

### Largest Files (most content)
- `Reference - Env Configuration.txt` — 246.9 KB
- `Features - Extensibility - Plugin - Tools - Development.txt` — 56.0 KB
- `Features.txt` — 49.7 KB
- `Tutorials - Tips - Sqlite Database.txt` — 43.3 KB
- `Features - Extensibility - Plugin - Functions - Filter.txt` — 39.7 KB
- `Troubleshooting - Manual Database Migration.txt` — 35.8 KB
- `Faq.txt` — 32.0 KB

## Next Steps

1. **Import to OpenWebUI Knowledge base** — drag and drop files from `kb_ready/` into the Knowledge section
2. **Consider splitting large files** — the Env Configuration file is 247 KB, might benefit from chunking
3. **Update later** — just `cd ~/temp/openwebui-docs-site && git pull && python3 convert_for_kb.py`

## Key Insight

Always check for a public source repo before scraping documentation sites. Docusaurus sites almost always have their Markdown source in Git — cleaner content, zero server load, easy to update with `git pull`.
