---
name: huggingface-mcp
description: Gotchas for the Hugging Face MCP server (huggingface.co/mcp) — hf_fs virtual filesystem for models, datasets, Spaces, papers, docs; trending listings; MCP Spaces discovery; the read_* skill loaders. Use when searching or reading Hub models/datasets/Spaces/papers, searching HF docs, finding MCP-compatible Spaces, or loading an HF skill.
---

# Hugging Face MCP

Configured in `~/.pi/agent/mcp.json` as `https://huggingface.co/mcp` with `Authorization: Bearer ${HF_TOKEN}`.
Anonymous works for public reads; the token adds gated/private access and the account-scoped tools.
Read-only unless the token has write perms **and** the extra tool groups are enabled at
https://huggingface.co/settings/mcp (Contribute Repos, Sandboxes, Jobs) — otherwise `hf_fs_write`,
jobs and sandbox tools simply do not appear in the tool list.

Prefer this server over scraping huggingface.co: trending, leaderboards and daily papers are live here.

## Tool map (151 tools, all prefixed `huggingface_`)

- `hf_fs` — **the** tool. Virtual filesystem + all discovery. Almost everything goes here.
- `hf_whoami` — account, token role, scoped permissions.
- `hub_repo_search` / `hub_repo_details` — flat JSON-ish search across `model|dataset|space` by
  author/filters/sort; use when you want repo metadata without hf:// paths.
- `read_hf_cli`, `read_hf_mem` — reference for the local `hf` CLI and memory estimation.
- The other ~145 `read_*` tools are **not API calls** — they load HF skill/reference documents
  (training, Spaces, ZeroGPU, Gradio, sentence-transformers, SageMaker, transformers.js, …).

## Three gotchas that cost calls

1. **`read_*` returns a bare string**, not `content[0].text`. `r.data` *is* the markdown.
   Everything else returns `data.content[0].text` (markdown tables, not JSON).
2. **One `hf_fs` call, many operations.** Args are tokenized one-per-array-item:
   `{operations:[{cmd:'search',args:['hf://models','qwen quantization','--limit','5']}]}`.
   Flag and value are separate strings. Up to 30 ops per call, order preserved — batch instead of looping.
3. **`search` requires a query** for papers and docs (and in practice everywhere):
   `search hf://papers` → `HF_FS_INVALID_ARGUMENT`. Errors dump the full grammar, so read them.

## hf_fs grammar

```
ls     URI [--recursive] [--glob GLOB] [--type TYPE] [--sort SORT] [--limit N]
cat    URI [--offset N] [--max-bytes N]
attach URI [--max-bytes N]          # one .jpg/.jpeg/.png/.webp, returned as image content
stat   URI
find   URI [--name GLOB] [--path GLOB] [--type TYPE] [--limit N]
search URI QUERY [--type TYPE] [--sort SORT] [--tag TAG] [--kind mcp] [--limit N]
```
`SORT = createdAt|downloads|likes|lastModified|likes30d|trendingScore|mainSize|id|trending|upvotes`

Roots: `hf://models|datasets|spaces|buckets|collections|papers|docs`. `hf://README.md` is the
authoritative in-band manual (`cat` it, it's 7KB — use `--offset 6000` for the rest).

Rules of thumb: `search` = global discovery, `find` = recursive within a known scope, `ls` = known
directory, `stat` = unknown type or binary metadata, `cat` = confirmed UTF-8 text. Global recursive
crawling is deliberately impossible. Never invent repo paths — reuse the returned `uri` verbatim
(or `target_uri` for a link).

## Recipes

```
ls hf://models/trending                      # also datasets/spaces; hard cap 20
ls hf://papers/trending --limit 100          # papers/daily/latest for today's Daily Papers
search hf://models "qwen3 gguf" --sort downloads --limit 20
search hf://spaces "transcribe audio" --kind mcp     # MCP-capable Spaces only
search hf://docs/peft "LoRA adapters"        # docs search default limit 5, max 25
ls hf://docs                                 # products, then versioned paths from the manifest
cat hf://models/OWNER/NAME/README.md
cat hf://papers/2502.16161/paper.md          # metadata.json for authors/links
find hf://spaces/OWNER/NAME --name app.py --type file
```

## Limits worth remembering

`cat` 20,000 bytes default / 80,000 max — long READMEs need paged `--offset`.
`search` 100/1,000; `ls`/`find` 1,000/10,000; trending model/dataset/space listings fixed at 20.
`attach` 8 MiB per call total; in a batch, overflow attachments fail with
`HF_FS_ATTACHMENT_BUDGET_EXCEEDED` — split them across calls.
Doc manifests cached 10 min.

## Browser URLs from hf:// URIs

`hf://models/OWNER/NAME/PATH` → `https://huggingface.co/OWNER/NAME/resolve/main/PATH`
(insert `/datasets` or `/spaces` for those roots; `buckets` uses `/buckets/OWNER/NAME/resolve/PATH`).
URL-encode each segment. Always include Hub links in answers.
