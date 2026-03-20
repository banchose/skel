# Waybar Oil Price Module — Setup, Freshness Indicator, and Aider Workflow

**Date:** 2026-03-20  
**Type:** Project / In Progress  
**Environment:** Hyprland, Waybar, Arch Linux, Bash 5.3

* * *

## Summary

Custom waybar module displaying WTI crude oil price (CL=F) via Yahoo Finance API. Script uses market-hours detection and a cache file to avoid unnecessary fetches when NYMEX/Globex is closed. Planned enhancement: visual freshness indicator (colored dot) showing whether displayed data is live or stale.

## Current Setup

### Waybar Config (`~/.config/waybar/config`)

```json
"custom/oil": {
    "exec": "~/.config/waybar/scripts/oil_price.sh",
    "return-type": "json",
    "interval": 300,
    "tooltip": true,
    "min-length": 16
}
```

**Interval:** 300 seconds (5 minutes). Plenty casual. Could go to `3600` (1 hour) if desired — oil doesn't move meaningfully on shorter timescales for ambient awareness.

### Script Location

`~/.config/waybar/scripts/oil_price.sh`

### Data Source

Yahoo Finance chart API: `https://query1.finance.yahoo.com/v8/finance/chart/CL=F?range=1d&interval=1d`

### Cache

`${XDG_RUNTIME_DIR:-/tmp}/oil_price_cache.json` — written on every successful live fetch. Served when market is closed or curl fails.

### Market Hours Logic

WTI crude futures (NYMEX/Globex): Sun 18:00 ET → Fri 17:00 ET, with daily halt 17:00–18:00 ET on weekdays. Script correctly handles:

*   Saturday: closed all day
    
*   Sunday before 18:00 ET: closed
    
*   Friday after 17:00 ET: closed
    
*   Weekday 17:00–18:00 ET: daily halt
    

### Current Output

JSON with `text`, `tooltip`, `class` fields. Classes: `oil-up`, `oil-down`. Tooltip shows price, change, pct, high, low, prev close.

* * *

## Planned Enhancement: Freshness Indicator Dot

### Design

A `●` character prepended (or appended) to the text output, colored via CSS class:

| State | Dot Color | Meaning |
| --- | --- | --- |
| `oil-up` | Bright green | Live data, price up from prev close |
| `oil-down` | Bright red | Live data, price down from prev close |
| `stale-up` | Dark green | Cached/stale data, last known direction was up |
| `stale-down` | Dark red | Cached/stale data, last known direction was down |

Brightness communicates freshness. Color family communicates direction. No information lost.

### Implementation Notes

*   The `●` goes into the `"text"` field of the JSON output
    
*   The `class` field already exists and is written into the cache — so when serving stale data, read the cached class and emit the corresponding `stale-*` variant
    
*   CSS in `~/.config/waybar/style.css` targets:
    
    *   `#custom-oil.oil-up` — bright green dot
        
    *   `#custom-oil.oil-down` — bright red dot
        
    *   `#custom-oil.stale-up` — dark green dot
        
    *   `#custom-oil.stale-down` — dark red dot
        
*   The CSS colors the entire module text, so the dot and price text will share the color. If only the dot should be colored, it would need to be a separate module or use pango markup in the text field (waybar supports `"format"` with pango).
    

### Pango Markup Option (dot-only coloring)

If the text field uses pango markup, you can color just the dot:

```
"text": "<span color='#2e7d32'>●</span> 🛢️ $67.42 ▲1.23%"
```

This would let the dot be colored independently of the price text. The script would embed the color directly. No CSS class needed for the dot in that case — the class could still be used for other styling.

### Optional: Cache TTL Guard

For belt-and-suspenders throttling even during market hours:

```bash
readonly MAX_AGE=1800  # seconds
if [[ -f "${CACHE_FILE}" ]]; then
  cache_age=$(( $(date +%s) - $(stat -c %Y "${CACHE_FILE}") ))
  if (( cache_age < MAX_AGE )); then
    cat "${CACHE_FILE}"
    exit 0
  fi
fi
```

Insert before the `curl` call. Prevents hitting Yahoo more than once per `MAX_AGE` regardless of waybar interval.

* * *

## Using Aider to Edit This

This is a good candidate for aider — it's a shell script + JSON config + CSS, all text files.

### Workflow

```bash
cd ~/.config/waybar

# Dry run / plan first (no edits):
aider scripts/oil_price.sh
# Then in aider:
#   /ask  <describe the freshness indicator plan>
#   Review the plan
#   "go ahead" to execute

# To include the waybar config and CSS:
aider scripts/oil_price.sh config style.css

# Read-only reference (if you want aider to see but not edit):
#   /read-only config
```

### Preventing Auto-Commits

```bash
aider --no-auto-commits scripts/oil_price.sh
```

Or in `~/.aider.conf.yml`:

```yaml
auto-commits: false
```

Aider edits the files but does not commit. You review with `/diff` and commit yourself.

* * *

## Files

| File | Purpose |
| --- | --- |
| `~/.config/waybar/config` | Waybar module definitions (JSON) |
| `~/.config/waybar/style.css` | Waybar CSS styling |
| `~/.config/waybar/scripts/oil_price.sh` | Oil price fetch + cache script |

* * *

## Additions

> Items added outside of a structured update. May be rough, incomplete, or shorthand.  
> These should be integrated into the note body on the next formal update.

_(none yet)_
