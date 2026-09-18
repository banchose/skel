---
name: fastmail
description: Gotchas and worked examples for the Fastmail MCP server (api.fastmail.com/mcp) — email search with Gmail-style qualifiers, threads, contacts, calendar events, notes, plus the query-syntax traps that hard-error instead of returning nothing. Use when asked to search, read, or summarize the user's Fastmail mail, find a contact, check their calendar, or read their notes.
---

# Fastmail MCP

Hosted server at `https://api.fastmail.com/mcp`. Tools are prefixed `fastmail_`.
Read tools return JSON in `data.content[0].text` — a **string**, parse it before indexing.

In `mcpScript`, the tool path is the **flat prefixed name** (`fastmail_search_email`).
`tools.call('fastmail/search_email', …)` returns `tool_not_found`.

## Auth: static API token, not OAuth

The endpoint is a plain bearer resource (`www-authenticate: Bearer … scope="https://www.fastmail.com/dev/mcp"`).
Fastmail supports an API token *instead of* the OAuth consent flow, so `mcp.json` just needs a header:

```json
"fastmail": {
  "url": "https://api.fastmail.com/mcp",
  "type": "http",
  "headers": { "Authorization": "Bearer ${FASTMAIL_API_TOKEN}" }
}
```

Token: Fastmail → Settings → Privacy & Security → Manage API tokens. Env var must be set in the
process that *starts* pi (`docker run -e …`); exporting it in a later shell is invisible to a
running session.

**Don't try pi's OAuth flow in a container.** `pi-mcp-adapter` stores OAuth and bearer credentials
only in the OS credential store via `@napi-rs/keyring`. With no D-Bus/gnome-keyring, `auth-start`
fails with a misleading `OAuth startup cleanup failed` (the real cause is the store being
unreadable *and* undeletable). The static header sidesteps keyring entirely.

**Tool list depends on token scopes.** A read-only token exposes 15 tools; `send_email`,
`draft_email`, `update_email`, `update_event`, `set_memo`, `add_to_note`, `delete_*` only appear
when the token carries write/send scopes. If a write tool is "missing", the scope is missing —
don't work around it, say so.

## Tool routing

| Ask | Tool |
|---|---|
| "any mail from X / about Y", "recent email" | `search_email` (omit `query` for most-recent) |
| "what did that thread say" | `read_thread` (`threadId`) — quoted chains stripped |
| full body of one message | `read_email` (`id`, `includeQuotedText` for the raw quoted form) |
| someone's address / phone | `search_contacts` (personal address book only) |
| "what's on my calendar" | `search_events` — **needs** `after`/`before`/`query` |
| which calendars exist | `list_calendars` |
| folders/labels and unread counts | `list_labels` |
| "which addresses can I send from" | `list_identities` |
| notes | `search_notes` → `read_note` |

`read_email_view`, `read_compose_event`, `read_confirm_delete_*` are MCP-UI widgets, not data
tools. Don't call them to fetch content.

## Query language: it hard-errors, it doesn't degrade

Bad syntax returns `ok: false` / `tool_error`, **not** an empty result set — so a failed search is
never a "no mail found" answer. Verified error strings: `Unknown qualifier: …`,
`Expected value after subject: at position 8`, `No mailbox matching "X" — use list_labels`,
`No contact matches "X"`.

Verified qualifiers: `from to cc bcc with subject body text in before after is has`.

| Works | Fails |
|---|---|
| `from:help@paddle.com` (full address) | `from:paddle.com` — bare domain is read as a *contact name* → `No contact matches` |
| `-from:help@paddle.com`, `receipt -subscription` (negation) | `from:Gail`, `from:"Gail Fairbairn"` unless that name is in the address book |
| `subject:"Your receipt"` (quoted phrase) | `subject:(fastmail OR welcome)` — no parens after a qualifier |
| `fastmail OR receipt`, `(receipt)` on bare terms | |
| `to:me` / `from:me` → verified identities | |
| `in:archive` **and** `in:Archive` (role, name, or id) | `in:NoSuchLabel` |
| `after:1y` `after:7d` `after:today` (relative) | those same forms in `search_events` — see below |
| `after:2020-01-01 before:2030-01-01` | |
| `has:attachment`, `is:unread`, `is:starred` | |

**`query: ''` is not the same as omitting `query`.** Empty string matched 0 of 5 events in a range
that returns 5 with `query` absent. Omit the key; never pass a falsy placeholder.

`limit` defaults to 10, max 50. Over-50 is accepted silently, so don't rely on it clamping.

## Two mailbox modes — check which you got

Every email summary carries **either** `folder` (folders mode, single `{id,name,path,role}`)
**or** `labels` (labels mode, array of the same). It's an account setting, not a per-call flag.
Read `e.labels ?? [e.folder]` rather than assuming; a hardcoded `e.folder.name` throws on a
labels-mode account.

## Dates: `search_email` and `search_events` use different grammars

- `search_email`: Gmail relative tokens — `7d` `1w` `3m` `1y` `today` `yesterday` `tomorrow`, or `YYYY-MM-DD`.
- `search_events`: ISO 8601 **or English** relative — `'2 weeks ago'`, `'2 weeks from now'`.
  `before: '7d'` errors: `Cannot parse date-time: 7d`.

Carrying `7d` from a mail search into an event search is the easiest mistake here.

## Response shapes (verified)

```
search_email     → { results: [...], hasMore, nextCursor }
search_contacts  → { results: [...], hasMore, nextCursor }
search_notes     → bare array            ← no results/hasMore wrapper
search_events    → bare array
read_thread      → bare array of emails, ascending by receivedAt
list_labels / list_calendars / list_identities → bare array
```

Paging: pass `cursor: nextCursor` **with the same `query`**. Reusing a cursor under a different
query returns empty rather than erroring — silently wrong, so keep the pair together.

Events have **no `end` field**: `start` is a *floating* local time (`2014-08-04T00:00:00`, no
offset), plus ISO-8601 `duration` (`P2D`) and `isAllDay`. `timeZone` is often `''`. Compute the
end yourself. `calendarIds` is a `{id: true}` map — join against `list_calendars` to name it.

## Size: cap `limit` around 15

The harness output guard replaces oversized results with an envelope where `data.content` is
**absent** (`omitted`, `rawResultBytes`, `fullResultPath` instead), so `data.content[0].text`
throws a confusing `TypeError`. Measured: `search_email` ≈ **680 B per email summary**
(5 results = 3.4 KB), so `limit: 50` ≈ 34 KB will spill past the ~14 KB guard. `limit: 15` is safe.
`read_thread` ≈ 620 B per message — long threads can spill too; prefer `read_email` on the one
message you need.

Refine the query (`from:` / `after:` / `in:`) instead of paging deeply or raising `limit`.

## Worked example: recent mail digest

```js
const r = await tools.call('fastmail_search_email', { query: 'after:7d', limit: 15 });
if (r.data.omitted) { emit({ fatal: 'omitted', bytes: r.data.rawResultBytes }); }
else {
  const { results, hasMore } = JSON.parse(r.data.content[0].text);
  emit({ hasMore, mail: results.map(e => ({
    from: e.from?.[0]?.email,
    subject: e.subject,
    at: e.receivedAt,
    where: (e.labels ?? [e.folder]).map(l => l?.path).join(','),   // mode-agnostic
    unread: !e.isRead,
    id: e.id, thread: e.threadId,
  })) });
}
```

Then `fastmail_read_thread` with a `threadId` for anything that needs detail — one call per
thread, not a loop over every hit.

## Reporting conventions

- Privacy: summarize, don't dump bodies. Pull the whole body only when asked about that message.
- `receivedAt` is UTC ISO; use the `time` MCP server for "today" rather than assuming the clock.
- Quote the identity you'd send from (`list_identities`) before drafting anything.
- On a `tool_error`, report the server's message verbatim — its text names the fix (`use list_labels`, `search_contacts first`).
