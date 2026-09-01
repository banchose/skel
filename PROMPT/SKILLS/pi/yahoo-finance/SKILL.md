---
name: yahoo-finance
description: Gotchas and worked examples for the yahoo-finance MCP server — quotes, charts, fundamentals, symbol resolution for commodities/indices/FX/crypto, futures front-month caveat, and the output-guard limit that silently drops `content` above ~14KB. Use when asked for the price of a stock, commodity (oil, gold, gas), index, currency pair, or crypto, or for historical prices, fundamentals, or market comparisons.
---

# yahoo-finance MCP

4 tools, all prefixed `yahoo-finance_`. All read-only, unauthenticated, no billing risk.
Data is **delayed ~10 minutes** (`exchangeDataDelayedBy: 10`) — say so when quoting a price.

## Tool routing

| Question | Tool |
|---|---|
| "price of X right now" | `get_quote` — takes **`symbols` (array)**, even for one |
| "price history / trend / chart" | `get_chart` — takes **`symbol` (string)** |
| P/E, margins, dividend, holders, financials | `quote_summary` + `modules` |
| "what's the ticker for…" | `search` — but see the warning below |

Param names are inconsistent across these tools: `get_quote` wants `symbols: string[]`,
the other three want `symbol: string`. There is no `get_ticker_info` — that's the Python
yfinance API, not this server. Guessing it wastes two round trips.

## Resolve the symbol from this table, not with `search`

`search` ranks badly for commodities. `query: 'natural gas futures'` returns E-mini contracts,
Stuttgart leveraged indices, and Korean inverse ETFs — but **not** `NG=F`. Use the table first;
fall back to `search` only for company names you can't guess (then filter `quoteType: 'EQUITY'`).

```
Commodities (=F)        Indices (^)           Crypto (-USD)
  WTI crude    CL=F       S&P 500   ^GSPC       BTC-USD
  Brent crude  BZ=F       Nasdaq    ^IXIC       ETH-USD
  Natural gas  NG=F       Dow       ^DJI
  Gold         GC=F       VIX       ^VIX      FX (=X)
  Silver       SI=F       Russell   ^RUT        EURUSD=X
  Copper       HG=F       FTSE      ^FTSE       USDJPY=X
  Corn         ZC=F       Nikkei    ^N225       GBPUSD=X
  Wheat        ZW=F       DAX       ^GDAXI
  Gasoline     RB=F
```

Foreign listings take an exchange suffix: `.TO` Toronto, `.L` London, `.T` Tokyo,
`.HK` Hong Kong, `.DE` Frankfurt, `.PA` Paris, `.AX` Australia. e.g. `SHOP.TO`, `BP.L`.

## Generic requests → quote the standard pair/set, don't pick one

"What's the price of oil?" has no single answer — there are two global benchmarks and they
diverge. Quote **both**; the spread between them is information. Same logic for a few other
vague asks. Don't ask a clarifying question for these — just return the set.

| User says | Quote these | Why |
|---|---|---|
| oil, crude, "oil price" | `CL=F` + `BZ=F` | WTI (US) and Brent (global) benchmarks; Brent normally trades at a premium |
| "the market", stocks, indices | `^GSPC` + `^IXIC` + `^DJI` | S&P is the answer, but all three is what people mean |
| gold / silver / precious metals | `GC=F` (+ `SI=F` if "metals" plural) | single benchmark, no ambiguity |
| crypto | `BTC-USD` + `ETH-USD` | |
| "the dollar" | `EURUSD=X` + `USDJPY=X` (or `DX-Y.NYB` index) | no single "dollar price" — it's a pair |

**"Gas" is genuinely ambiguous — ask.** US "gas" usually means gasoline (`RB=F`), elsewhere and
in energy contexts it means natural gas (`NG=F`). These are unrelated contracts at wildly
different price scales; guessing wrong is a silent, confident error.

### Output format for a benchmark pair

One `get_quote` call with both symbols, rendered as a table. Label each futures row with its
contract month — **on every row**, not just the first:

```
| | Price | Change | Day range |
|---|---|---|---|
| WTI (CL=F, Oct 26)   | $90.79 | +0.57 (+0.63%) | 90.57–91.00 |
| Brent (BZ=F, Nov 26) | $95.25 | +0.60 (+0.63%) | 95.20–95.48 |
```

**Get the month from `underlyingSymbol`, not `shortName`.** `shortName` is truncated at 31 chars,
so `BZ=F` returns `"Brent Crude Oil Last Day Financ"` — no month at all, while `CL=F` gives
`"Crude Oil Oct 26"`. Decode the month code instead (verified on CL/BZ/NG/GC):

```js
const CODES = {F:'Jan',G:'Feb',H:'Mar',J:'Apr',K:'May',M:'Jun',
               N:'Jul',Q:'Aug',U:'Sep',V:'Oct',X:'Nov',Z:'Dec'};
const contract = u => {
  const m = /^[A-Z]+([FGHJKMNQUVXZ])(\d{2})\./.exec(u || '');   // 'BZX26.NYM' → 'Nov 26'
  return m ? `${CODES[m[1]]} ${m[2]}` : null;
};
```

Note WTI and Brent front months are usually **different** (Oct vs Nov above) because Brent
expires later in the cycle — another reason to label both rows.

Then one or two lines of context, not more: position vs the 50-/200-day averages, the 52-week
range, and the year-over-year move. Close with the as-of time and delay.

```js
const r = await tools.call('yahoo-finance_get_quote', { symbols: ['CL=F','BZ=F'] });
emit(JSON.parse(r.data.content[0].text).map(q => ({
  bench: q.shortName,
  sym: q.symbol,
  month: contract(q.underlyingSymbol),      // NOT from shortName — see above
  price: q.regularMarketPrice,
  chg: q.regularMarketChange,
  pct: +q.regularMarketChangePercent.toFixed(2),
  day: `${q.regularMarketDayLow}–${q.regularMarketDayHigh}`,
  vs50d: +(((q.regularMarketPrice / q.fiftyDayAverage) - 1) * 100).toFixed(1),
  range52: `${q.fiftyTwoWeekLow}–${q.fiftyTwoWeekHigh}`,
  yoyPct: +q.fiftyTwoWeekChangePercent.toFixed(1),
  asOf: q.regularMarketTime,
})));
```

Two symbols is ~4.6 KB — safely inline, no chunking needed.

## Futures return the front-month contract, not spot

`CL=F` resolves to a dated contract — check `underlyingSymbol` (`CLV26.NYM` → Oct 2026) and
`expireDate`. For "the price of oil" that's the right answer, but:

- **Name the contract month** when reporting, so the number is reproducible. Decode it from
  `underlyingSymbol`; `shortName` is truncated at 31 chars and omits the month on longer names
  like `BZ=F`. See the decoder under "Generic requests" above.
- `expireDate` tells you how close the rollover is; near expiry, volume migrates to the next
  contract and `regularMarketVolume` on the front month looks anomalously thin.
- Don't call it "spot." Front-month futures ≠ spot, and in steep contango/backwardation the gap is real.

## Project the fields you need — responses are fat

`get_quote` returns ~90 fields per symbol, **~3.4 KB each** for equities. Reading that into
context to quote one number is waste — and past ~4 symbols it doesn't just bloat, it **breaks**
(see "Omitted results"). Use `mcpScript` to project:

```js
const r = await tools.call('yahoo-finance_get_quote', { symbols: ['CL=F','BZ=F'] });
const rows = JSON.parse(r.data.content[0].text);   // content[0].text is a JSON STRING
emit(rows.map(q => ({
  symbol:  q.symbol,
  name:    q.shortName,
  price:   q.regularMarketPrice,
  change:  q.regularMarketChange,
  pct:     q.regularMarketChangePercent,
  prevCls: q.regularMarketPreviousClose,
  range52: `${q.fiftyTwoWeekLow}–${q.fiftyTwoWeekHigh}`,
  asOf:    q.regularMarketTime,
})));
```

Payload shape below the size limit is the same for all four tools: `data.content[0].text` is a
JSON **string** — parse it before indexing. `get_quote` parses to an **array** (order matches
`symbols`). Above the limit the shape changes — see "Omitted results" below, and never write
`data.content[0]` without guarding for it.

### The fields worth pulling from `get_quote`

`regularMarketPrice` `regularMarketChange` `regularMarketChangePercent`
`regularMarketPreviousClose` `regularMarketOpen` `regularMarketDayHigh/Low`
`regularMarketVolume` `fiftyTwoWeekLow/High` `fiftyDayAverage` `twoHundredDayAverage`
`fiftyTwoWeekChangePercent` `currency` `marketState` `regularMarketTime`
Futures only: `openInterest` `expireDate` `underlyingSymbol`

`fiftyDayAverage` / `twoHundredDayAverage` are free trend context — comparing spot to both is
a one-line way to say whether a move is extended or normal.

## get_chart

`period1` is typed as bare `string`; **`'YYYY-MM-DD'` works** (verified). `period2` defaults to now.
Response is compact — `{meta, quotes}`, ~2.9 KB for a week of daily bars.

```js
const c = await tools.call('yahoo-finance_get_chart',
  { symbol: 'CL=F', period1: '2026-08-01', interval: '1d' });
const { meta, quotes } = JSON.parse(c.data.content[0].text);
// quotes[]: { date, open, high, low, close, adjclose, volume }
emit({ bars: quotes.length,
       first: quotes[0].close,
       last:  quotes.at(-1).close,
       pct:   ((quotes.at(-1).close / quotes[0].close - 1) * 100).toFixed(2) });
```

- Intraday intervals (`1m`–`90m`) only cover recent history; Yahoo caps `1m` at ~7 days.
  For anything older than a month use `1d` or coarser.
- Use `adjclose` for multi-year equity returns (splits/dividends); `close` is fine for futures and FX.
- `events: 'div,split'` adds corporate actions. `includePrePost: true` for extended hours.

## quote_summary

Pass only the modules you need — omitting `modules` pulls a large default set. Two modules on
`XOM` is ~2.4 KB; the response is keyed by module name.

| Question | Modules |
|---|---|
| Valuation, P/E, yield, market cap | `summaryDetail`, `defaultKeyStatistics` |
| Margins, cash, debt, ROE, growth | `financialData` |
| Income / balance / cash flow | `incomeStatementHistory`, `balanceSheetHistory`, `cashflowStatementHistory` (+ `…Quarterly`) |
| Analyst targets, up/downgrades | `recommendationTrend`, `earningsTrend`, `upgradeDowngradeHistory` |
| Ownership | `institutionOwnership`, `insiderHolders`, `majorHoldersBreakdown` |
| Sector, description, HQ | `assetProfile` (or lighter `summaryProfile`) |
| Next earnings date | `calendarEvents` |
| ETF holdings / performance | `topHoldings`, `fundPerformance`, `fundProfile` |

Equity-only modules return empty or error on futures, FX, and indices — don't ask `CL=F` for
`financialData`.

## Omitted results: chunk `get_quote` to ≤3 equities per call

The harness output guard replaces oversized MCP results with a summary envelope. When that
happens `r.ok` is still `true`, but `r.data` has **no `content`** — it has:

```
omitted, reason, isError, contentBlocks, contentSummary, rawResultBytes, fullResultPath
```

So `r.data.content[0].text` throws `TypeError: Cannot read properties of undefined (reading '0')`
— a confusing type error, not a size error. Measured `get_quote` payloads (equities):

| symbols | payload | result |
|---|---|---|
| 1 | 3.5 KB | inline |
| 3 | 10.1 KB | inline |
| 4 | 13.7 KB | inline |
| 5 | 19.2 KB raw | **omitted** |

The limit sits between those last two. Field count varies by instrument — equities carry
`marketCap` and analyst fields, so 5 equities spill while 5 futures/FX/crypto (12.2 KB) do not.
**Don't count on symbol count alone; chunk at 3 and you're always safe.**

`mcpScript` has **no `fs` and no `require`**, so it cannot read `fullResultPath` itself. Recovering
in-script is impossible — prevent the spill instead of handling it.

## Worked example: multi-symbol comparison table

Chunked, projected, sorted, guarded — the pattern for "how are energy stocks doing" or
"compare these." Verified across 8 symbols.

```js
const syms = ['XOM','CVX','COP','SLB','OXY','PSX','MPC','VLO'];
const CHUNK = 3;                                  // stay under the output guard
const out = [];
for (let i = 0; i < syms.length; i += CHUNK) {
  const r = await tools.call('yahoo-finance_get_quote', { symbols: syms.slice(i, i + CHUNK) });
  if (r.data.omitted) { emit({ fatal: 'omitted', bytes: r.data.rawResultBytes }); break; }
  for (const q of JSON.parse(r.data.content[0].text)) {
    out.push({
      sym: q.symbol,
      price: q.regularMarketPrice,
      pct: +q.regularMarketChangePercent.toFixed(2),
      vs50d: +(((q.regularMarketPrice / q.fiftyDayAverage) - 1) * 100).toFixed(1),
      mktCapB: q.marketCap ? +(q.marketCap / 1e9).toFixed(1) : null,
    });
  }
}
out.sort((a, b) => b.pct - a.pct);
emit({ count: out.length, rows: out });
```

Fan out across *tools* in one script too — e.g. `get_quote` for the price plus `get_chart` for
a 30-day trend, or a `quote_summary` per symbol in a loop. That's the `mcpScript` sweet spot;
a single lookup should use the `mcp` tool instead.

### If a result did spill

Read the file with bash — the spill file holds the **full MCP envelope**, so it needs a
*double* parse (`.content[0].text` is itself a JSON string):

```bash
jq -r '.content[0].text' /tmp/pi-mcp-output-*/mcp-result-*.txt \
  | jq -r 'map({s:.symbol, p:.regularMarketPrice, pct:.regularMarketChangePercent})'
```

Do not re-issue the call hoping for a smaller response — chunk it instead.

## Reporting conventions

- State the as-of time and the ~10-min delay. `regularMarketTime` is UTC ISO; the exchange's
  local zone is in `exchangeTimezoneName` / `exchangeTimezoneShortName`.
- `marketState` (`REGULAR`, `CLOSED`, `PRE`, `POST`) — if `CLOSED`, the "price" is the last close.
- Check `currency` before comparing across exchanges; `.T` and `.L` quotes are not USD
  (and London prices are often **pence**, not pounds).
- For futures, name the contract month (see above).
