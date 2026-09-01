---
name: polymarket
description: Read Polymarket prediction-market data with curl — market discovery and search, live prices and order books, price history, plus the public activity surface (PnL leaderboard, per-market whale holders, any wallet's full trade history and open positions). All reads are unauthenticated. Use when asked about prediction markets, betting odds on an event, implied probabilities, what traders are betting on, smart-money positioning, or Polymarket specifically.
compatibility: Requires bash, curl, and jq (python3 works too). No API key, no account, no wallet. Read-only — this skill never places an order.
---

# Polymarket

**Every read below is free and unauthenticated.** No key, no signup, no wallet, no rate-limit headers observed. Verified live.

The EIP-712 / L1-signature / HMAC-L2 ladder in Polymarket's docs is **only** for placing orders and reading *your own* account. It needs a Polygon private key. You never touch it to analyze markets. If a task seems to need it, stop and ask — that path moves real money.

## Four hosts

| Host | Gives you |
|---|---|
| `gamma-api.polymarket.com` | Market/event discovery, metadata, search |
| `clob.polymarket.com` | Prices, order books, price history |
| `data-api.polymarket.com` | Activity: leaderboard, holders, per-wallet trades and positions |
| `relayer-v2.polymarket.com` | Gasless tx submission — trading only, ignore for reads |

## Identifiers — get these right or nothing works

Three different ids, easy to confuse:

- **`conditionId`** (`0x…`) — the market. Used by `data-api` (`?market=`).
- **`clobTokenIds`** — one token per outcome (Yes/No). Used by `clob` (`?token_id=`) **and** by `prices-history` (`?market=` there wants a *token* id, not a conditionId — the param name lies).
- **`id`** / **`slug`** — Gamma's own numeric id and URL slug. `events[0].id` is the event id, used by `live-volume?id=`.

**Gotcha: `clobTokenIds`, `outcomes`, and `outcomePrices` are JSON strings nested inside the JSON**, not arrays. You must parse twice:

```bash
curl -sG "https://gamma-api.polymarket.com/markets" --data-urlencode "closed=false" --data-urlencode "limit=1" \
| jq -r '.[0].clobTokenIds | fromjson | .[0]'     # fromjson is required
```

## Discovery

```bash
# What's actually being traded right now — the useful default sort
curl -sG "https://gamma-api.polymarket.com/markets" \
  --data-urlencode "closed=false" --data-urlencode "order=volume24hr" \
  --data-urlencode "ascending=false" --data-urlencode "limit=20" \
| jq -r '.[] | [(.volume24hr|tonumber|round), .question, .outcomePrices] | @tsv'

curl -s "https://gamma-api.polymarket.com/public-search?q=fed%20rate"   # -> {events, pagination}
curl -s "https://gamma-api.polymarket.com/events/slug/<slug>"
curl -s "https://gamma-api.polymarket.com/markets/keyset?tag_id=745&closed=false&limit=20"  # keyset -> after_cursor
curl -s "https://gamma-api.polymarket.com/tags/slug/nba"                 # tag_id for a topic
```

Without `order=`, you get arbitrary near-dead markets. Always sort by `volume24hr` unless you have a reason not to. Gamma has **no sparse-fieldset param** — you always receive ~90 fields per market, so project with `jq` or you'll drown.

## Prices

```bash
curl -s "https://clob.polymarket.com/midpoint?token_id=$TOKEN"          # {"mid":"0.0465"} — 17 bytes
curl -s "https://clob.polymarket.com/price?token_id=$TOKEN&side=BUY"
curl -s "https://clob.polymarket.com/book?token_id=$TOKEN"              # full bids+asks
curl -s "https://clob.polymarket.com/spread?token_id=$TOKEN"
curl -s "https://clob.polymarket.com/last-trade-price?token_id=$TOKEN"
curl -s "https://clob.polymarket.com/prices-history?market=$TOKEN&interval=1d&fidelity=60"
curl -s "https://clob.polymarket.com/prices-history?market=$TOKEN&startTs=…&endTs=…&fidelity=60"
```

Plural forms (`/books`, `/midpoints`, `/prices`, `/spreads`, `/last-trades-prices`) take a POST batch — use them instead of looping when you need many tokens.

**Price *is* implied probability.** `0.605` = 60.5% implied. Report it as a percentage; don't make the user do it. The two outcomes sum to ~1.00; the gap is the spread.

## Activity — the genuinely interesting part

```bash
curl -s "https://data-api.polymarket.com/v1/leaderboard?limit=10"          # top traders by PnL
curl -s "https://data-api.polymarket.com/holders?market=$CONDITION_ID&limit=10"   # whales in one market
curl -s "https://data-api.polymarket.com/trades?market=$CONDITION_ID&limit=50"    # matched-trade tape
curl -s "https://data-api.polymarket.com/trades?limit=50"                  # global firehose
curl -s "https://data-api.polymarket.com/activity?user=$WALLET&limit=20"   # one wallet's full history
curl -s "https://data-api.polymarket.com/positions?user=$WALLET"           # open book
curl -s "https://data-api.polymarket.com/closed-positions?user=$WALLET"
curl -s "https://data-api.polymarket.com/value?user=$WALLET"               # [{user, value}]
curl -s "https://data-api.polymarket.com/oi?market=$CONDITION_ID"          # open interest
curl -s "https://data-api.polymarket.com/live-volume?id=$EVENT_ID"
```

**`period=` on `/v1/leaderboard` is silently ignored.** `1d`, `1w`, `1m`, `all`, and `garbage` all return byte-identical payloads (verified). The docs advertise `period`; the API does not honor it. Treat the leaderboard as one undocumented window and **never label it "24-hour" or "all-time"** — say "current leaderboard".

`holders` returns `[{token, holders:[…]}]` — nested one level deeper than you expect, and keyed per outcome token, so top holders of Yes and No come back separately.

`/oi` (open interest) is the honest size number; `volume` includes churn. When they disagree, cite open interest.

## Why this API is unusual

It's a public order book **with social identity attached**. The leaderboard gives PnL-ranked traders by name; `/activity` gives any wallet's complete history; `/holders` gives whales with their usernames, bios, and avatars. Traditional venues anonymize prints. Here they don't.

So the high-value query is rarely "what's the price". It's **cross-referencing the leaderboard against `/holders` on a market**: are the consistently profitable wallets on one side? That signal doesn't exist on a regulated exchange.

Corollary worth telling a user who asks about trading there: their own positions and PnL are equally public to everyone running the same queries.

## Real-time, when polling isn't enough

Public, no auth: `wss://ws-subscriptions-clob.polymarket.com/ws/market` (book, `price_change`, `best_bid_ask`, `last_trade_price`, `tick_size_change`, `new_market`, `market_resolved`), `wss://ws-live-data.polymarket.com` (RTDS topics: `market`, `comments`, `crypto_prices`, `equity_prices`, `sports`), `wss://sports-api.polymarket.com/ws`.

Auth required only on the **user** channel (`/ws/user`) — your own orders. Skip it.

## Presenting the answer

Be curt. A question about one market gets a few lines:

1. **The question, verbatim** — Polymarket resolution criteria are narrower than the headline suggests. "Fed decrease 25bps *after the September 2026 meeting*" is not "will rates fall".
2. **Implied probability as a percent**, with the raw price in parens.
3. **Size** — 24h volume or open interest. A 90% probability on $4k of volume is noise; on $2M it's a real market.
4. **Movement** — `oneDayPriceChange` / `oneHourPriceChange` come free in the Gamma market object. Use them instead of a second call.

Add a short **Worth noting:** only when the data earns it — leaderboard wallets concentrated on one side, open interest far below volume, a spread wide enough that the midpoint is fiction, or a resolution date that makes the number misleading.

Never present a Polymarket price as a forecast from Polymarket. It's what strangers are betting, and thin markets are wrong constantly.

## Etiquette

Cache and batch. Two calls answer most questions (one Gamma sorted list, one `midpoint` or `holders`). Don't loop per-token when a plural batch endpoint exists. No documented rate limits were found, and the hosts sit behind Cloudflare — assume limits exist and don't discover them the hard way.
