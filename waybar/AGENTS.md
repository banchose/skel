# Waybar config (Hyprland, Arch)

Source of truth for `~/.config/waybar`. That directory is symlinks into here:
`config`, `style.css`, and `scripts/` targets. Edit here, then reload:

    killall -SIGUSR2 waybar          # reload config+css
    scripts/waybar.sh                # full restart (needed for script changes)

## Layout

- `config` — waybar JSON (with `//` comments). Every top-level module key is in one of the
  three `modules-*` lists; don't leave unused module definitions around.
- `style.css` — only rules for modules actually in `config`.
- `scripts/OPENWEATHER.sh` — `custom/weather`. OpenWeather One Call 3.0. Reads
  `OPENWEATHER_APP_ID` and `OPENWEATHER_LOCATION` (`{"lat":..,"lon":..}`) from the environment —
  never hard-code keys in this repo. Bar text: `temp ☁ DIR SPEED [G<gust>] [icon>20mph] 🌡 dewpoint`.
- `scripts/market_indicator.sh SYMBOL EMOJI LABEL ID [invert|''] [dollar|index|pct]` — drives
  `custom/oil`, `custom/gold`, `custom/vix`, `custom/tnx`. See "Market indicators" below.
- `scripts/ping_host.sh <ip> <label>` — `custom/Ping_GW` / `Ping_fios` / `Ping_firewall`.
  Prints `UP<label>` / `DN<label>`, class `UP` / `DOWN`.
- `scripts/pinger.sh [host]` — `custom/pinger`, latency in ms to 1.1.1.1.
  Class `UP` <30 ms, `WARN` <100, `CRIT` ≥100, `DOWN` on timeout. `alt` mirrors class.
- `scripts/waybar.sh` — kill-and-restart helper.
- `scripts/ONECALL3-0API.md` — offline copy of the OpenWeather One Call 3.0 API doc.

## Market indicators (`market_indicator.sh`)

- Source: Yahoo Finance chart API `https://query1.finance.yahoo.com/v8/finance/chart/<SYMBOL>?range=1d&interval=1d`.
  Carets in symbols (`^VIX`) are URL-encoded.
- Cache: `${XDG_RUNTIME_DIR:-/tmp}/market_<ID>_cache.json`, written on every successful fetch.
- No market-hours logic. Yahoo returns the last price when closed; if `curl` fails the cache is
  served with its class rewritten `<id>-up` → `stale-up` (etc.) so CSS dims it. No cache at all →
  class `stale`, text `<emoji> --`.
- Classes: `<id>-up` / `<id>-down`; VIX uses `invert` → `vix-up-bad` / `vix-down-good`.
  Stale variants: `stale-up`, `stale-down`, `stale-up-bad`, `stale-down-good`, `stale`.
- Interval 300 s is casual; could be 3600. Yahoo has no documented rate limit but don't hammer it.

## Gotchas

- `config` and `style.css` contain Nerd Font private-use glyphs (U+F0xx) and emoji with
  variation selectors. Exact-text edits on those lines fail and a full-file rewrite will lose the
  glyphs — delete/insert by line range with `sed` instead.
- Waybar centers `modules-center` between the left and right groups; a wide left group pushes
  the clock right. Check width when adding modules.
- Test `OPENWEATHER.sh` offline by putting a stub `curl` on `$PATH` that prints One Call JSON.
  Test `market_indicator.sh` stale paths by setting `XDG_RUNTIME_DIR` to a scratch dir with a
  fake `market_<id>_cache.json` and no network.
- Emoji that are missing from the font render as a box. Known missing: 🌬️ (wind face). Stick to
  emoji already used in the bar.
- Validate config JSON after edits: strip `//` comments, then `jq -e . config`.
