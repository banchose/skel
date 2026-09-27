---
name: nfl
description: Live NFL scores and game detail from ESPN's free public API — scoreboard for the week, down & distance, win probability, box score, scoring plays, leaders, current drive, injuries. Use when asked for an NFL score, how a game is going, who's playing, "how are the Bills doing", or live game stats.
compatibility: Requires bash 5+, curl, jq. No API key. Uses ESPN's undocumented site API (site.api.espn.com), which could change without notice.
---

# NFL live scores

```bash
./nfl.sh                      # every game this week: live first, then upcoming, then finals   (1 call)
./nfl.sh bills                # one team's game in full detail (default team: $NFL_TEAM, else bills)   (2 calls)
./nfl.sh giants --plays 10    # more plays from the current/last drive
./nfl.sh --week 2             # a past/future week's scoreboard   (1 call)
./nfl.sh --date 20260927      # scoreboard for a date   (1 call)
./nfl.sh game NYG --json      # raw payloads (scoreboard event + summary) for anything not printed
```

TEAM matches abbreviation, nickname, or city (`BUF`, `bills`, `buffalo`). `nfl.sh TEAM` looks only at the **current week**. A bye week gives "no game this week".

## Be conservative with API calls

It's a free, unofficial endpoint. **Only call it when the answer needs fresh data.** Use the cheapest command that answers the question.

- **Reuse what's already in the conversation.** For follow-ups like "what does that mean?", "compare that to last week", or "why is the win % so high?", answer from the last fetch. Don't re-fetch.
- **Pick the cheapest command.** Just the score → `nfl.sh` (1 call). Detail on one game → `nfl.sh TEAM` (2 calls). Don't run both.
- **At most one fetch per user message.** Never poll, loop, `sleep`/`watch`, or re-run to "see if it changed" unless the user asks.
- **Some data never changes.** Finals, past weeks, and kickoff times: fetch once and remember them.
- **During a live game**, refreshing is fine when the user asks "what's happening now?". That's the one case where a new call is always justified.
- **User screenshots and pasted text are data too.** If they're newer than the last fetch, use them instead of calling.
- **If output looks off, don't re-run blindly.** Use `--json` once to inspect.

## What the output means

- **STATUS / SCORE:** Line-score rows follow ESPN's order (home first). Read the team labels.
- **SITUATION / LAST PLAY / WIN PROB:** These come from the *scoreboard* feed, which is fresher than the summary. Win probability is ESPN Analytics, for the home team / away team.
- **CURRENT DRIVE** plays come from the *summary* feed and can lag the SITUATION line by a play or two. When they disagree, trust SITUATION and the clock.
- **PREGAME LINE** is the closing spread (e.g. `BUF -7` = Bills favored by 7). Live odds aren't printed.
- Every run prints a `fetched HH:MM:SSZ` UTC timestamp. Mention how fresh the data is when it matters.
- Kickoff times are already in ET from ESPN.

## Endpoints (for `--json` digging or new features)

| What | URL |
|---|---|
| Scoreboard | `https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard` (`?seasontype=2&week=N` or `?dates=YYYYMMDD`) |
| Game summary | `.../nfl/summary?event=<gameId>` (keys: `boxscore`, `drives`, `scoringPlays`, `leaders`, `winprobability`, `pickcenter`, `injuries`, `standings`, `news`) |

The game ID is the number in ESPN game URLs, e.g. `espn.com/nfl/game/_/gameId/401872953`.

The summary payload is several hundred KB. The script writes it to a temp file for jq, because passing it as an argument fails with "Argument list too long".
