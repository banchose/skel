---
name: wolfram-alpha
description: Computed answers from Wolfram|Alpha via its LLM API — math (solve, integrate, simplify), unit and currency conversion, physical/chemical constants and properties, dates, geography, statistics, ranked factual lists. Use when the user asks for a calculation, a conversion, a scientific constant or property, or a fact Wolfram can compute rather than look up.
compatibility: Requires bash, curl >= 7.76, and WOLFRAM_APP_ID (free non-commercial AppID from https://developer.wolframalpha.com/). One HTTP call per query.
---

# Wolfram|Alpha

```bash
./wolfram-alpha.sh "density of gold"                 # default maxchars 6800
./wolfram-alpha.sh "integrate x^2 sin x" 1500        # shorter response
./wolfram-alpha.sh "mercury" 6800 assumption='*C.mercury-_*Planet-'   # any extra param=value
```

Exit 0 = answer on stdout. Exit 1 = HTTP error; the body (including Wolfram's suggestions) is still printed. Exit 2 = usage.

## Endpoint

`GET https://www.wolframalpha.com/api/v1/llm-api` — `input` required, `maxchars` (default 6800), plus Full-Results params: `assumption`, `units`, `currency`, `location`, `latlong`, `timezone`, `countrycode`, `languagecode`, `scantimeout`. AppID goes in `appid=` or as `Authorization: Bearer`. The script uses Bearer so the key isn't in the URL.

Response is **plain text**, sections separated by blank lines: `Query:`, `Input interpretation:`, `Result:`, then topic pods (`Unit conversions:`, `Comparisons…`), `image: URL` lines, and a closing website link.

## Errors (verified live)

| HTTP | meaning | body |
|---|---|---|
| 501 | input not understood | `Wolfram|Alpha could not understand: …` often followed by **`Things to try instead:` / `You could instead try:`** with concrete alternate queries — use them |
| 401 | bad Bearer token | `Invalid appid` |
| 403 | bad/missing `appid=` param | `Invalid appid` / `Appid missing` |
| 400 | no `input` param | — |

There is no "empty success"; a failed interpretation is always a 501.

## Writing good queries (from Wolfram's own prompt guidance)

- **Keyword form, not questions.** "France population", not "how many people live in France".
- **English only.** Translate first, answer in the user's language.
- Single-letter variables (`x`, `n_1`). Exponents as `6*10^14`, never `6e14`.
- Named constants by name (`speed of light`), not numeric substitutes. Space between compound units (`Ω m`).
- Equations with units: solve the unit-free version, then reattach.
- One property per call. Don't ask for "mass, radius and density of Mars" — three calls.
- **Wrong interpretation?** Check `Input interpretation:`. If Wolfram lists Assumptions, re-send the *exact same* `input` with `assumption=<value>` rather than rewording. Only rephrase when no assumption is offered.

## `maxchars`

Drops whole pods from the end, not mid-sentence — `Result:` survives, `Comparisons`/`Images` go first. 500 is enough for a single number; keep 6800 for lists and tables. Raise it only if `Result:` itself is missing.

## Answering the user

- Read `Input interpretation:` first — it says what Wolfram actually computed. If it doesn't match the question, don't present the result; fix the query.
- `Result:` is the answer. Pull the number and unit; mention the other unit conversions only when the user's unit differs.
- Tables come as `a | b | c` rows. Short → keep as a table; long → summarize.
- Images are `image: https://…` URLs; render as `![…](url)` only if the user can see images.
- Cite as Wolfram|Alpha. It may have data newer than your training — don't override it with your own recollection.
- Not for: live stock quotes, weather, opinions, anything needing a paragraph of prose. Other skills cover finance/weather.
