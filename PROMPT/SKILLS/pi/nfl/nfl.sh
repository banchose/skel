#!/usr/bin/env bash
# nfl.sh — live NFL scores and game detail from ESPN's public (undocumented) site API.
# No key, no signup. Requires: bash 5+, curl, jq.
set -euo pipefail

BASE='https://site.api.espn.com/apis/site/v2/sports/football/nfl'
DEFAULT_TEAM=${NFL_TEAM:-bills}

usage() {
    cat >&2 <<'EOF'
usage:
  nfl.sh [scores] [--week N] [--date YYYYMMDD] [--json]   every game (default: current week)
  nfl.sh game [TEAM] [--plays N] [--json]                  one team's game in detail (default: $NFL_TEAM or bills)
  nfl.sh TEAM                                              shorthand for: game TEAM

TEAM matches abbreviation, nickname, or city: BUF, bills, buffalo, NYG, giants ...
EOF
    exit 2
}

require() {
    local missing=() cmd
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if (( ${#missing[@]} )); then
        printf >&2 'nfl.sh: missing required commands: %s\n' "${missing[*]}"
        exit 1
    fi
}

die() { printf >&2 'nfl.sh: %s\n' "$*"; exit 1; }

tmpdir=""
cleanup() { [[ -n $tmpdir ]] && rm -rf "$tmpdir"; return 0; }
trap cleanup EXIT

fetch() {   # fetch URL -> stdout; fail loudly with HTTP code
    local url=$1 body code
    body=$(curl -sS -m 20 -w '\n%{http_code}' "$url") || die "curl failed: $url"
    code=${body##*$'\n'}
    body=${body%$'\n'*}
    [[ $code == 200 ]] || die "HTTP $code from $url"
    printf '%s' "$body"
}

scoreboard_json() {   # $1 = extra query string (may be empty)
    fetch "${BASE}/scoreboard${1:+?$1}"
}

# ---------- scores ----------
cmd_scores() {
    local query="" json=0
    while (( $# )); do
        case $1 in
            --week) [[ ${2:-} =~ ^[0-9]+$ ]] || usage; query="seasontype=2&week=$2"; shift 2 ;;
            --date) [[ ${2:-} =~ ^[0-9]{8}$ ]] || usage; query="dates=$2"; shift 2 ;;
            --json) json=1; shift ;;
            *) usage ;;
        esac
    done
    local sb; sb=$(scoreboard_json "$query")
    if (( json )); then printf '%s\n' "$sb"; return; fi

    jq -r '
      def pct: if . == null then "" else ((. * 100) | round | tostring) + "%" end;
      "NFL \(.season.year) week \(.week.number)   (fetched \(now | strftime("%H:%M:%SZ")))",
      "",
      ( .events
        | sort_by({"in":0,"pre":1,"post":2}[.status.type.state], .date)[]
        | .competitions[0] as $c
        | ($c.competitors | map(select(.homeAway=="away"))[0]) as $a
        | ($c.competitors | map(select(.homeAway=="home"))[0]) as $h
        | .status.type.state as $st
        | ($c.broadcasts[0].names // [] | join("/")) as $tv
        | if $st == "pre" then
            "  \(.status.type.shortDetail | sub("^[0-9/]+ - "; ""))  \($a.team.abbreviation) (\($a.records[0].summary // "")) @ \($h.team.abbreviation) (\($h.records[0].summary // ""))  \($tv)"
          elif $st == "post" then
            "  FINAL      \($a.team.abbreviation) \($a.score) @ \($h.team.abbreviation) \($h.score)"
          else
            ($c.situation // {}) as $s
            | ($s.lastPlay.probability.homeWinPercentage) as $hp
            | "  LIVE \(.status.type.shortDetail)  \($a.team.abbreviation) \($a.score) @ \($h.team.abbreviation) \($h.score)"
              + (if $s.downDistanceText then "  | \($s.downDistanceText)" else "" end)
              + (if $s.isRedZone then " [RED ZONE]" else "" end)
              + (if $hp != null then "  | win%: \($h.team.abbreviation) \($hp|pct) / \($a.team.abbreviation) \((1-$hp)|pct)" else "" end)
          end )
    ' <<<"$sb"
}

# ---------- single game ----------
find_event() {   # $1 scoreboard json, $2 team query -> event id (empty if none)
    jq -r --arg q "${2,,}" '
      [ .events[]
        | select(any(.competitions[0].competitors[].team;
            [.abbreviation, .name, .shortDisplayName, .displayName, .location]
            | map(ascii_downcase) | index($q)))
        # prefer a live game, then upcoming, then finished
        | {id, r: {"in":0,"pre":1,"post":2}[.status.type.state]} ]
      | sort_by(.r) | .[0].id // empty
    ' <<<"$1"
}

cmd_game() {
    local team=$DEFAULT_TEAM plays=6 json=0
    while (( $# )); do
        case $1 in
            --plays) [[ ${2:-} =~ ^[0-9]+$ ]] || usage; plays=$2; shift 2 ;;
            --json) json=1; shift ;;
            -*) usage ;;
            *) team=$1; shift ;;
        esac
    done

    # payloads go to files: the summary is several hundred KB, too big for jq argv
    tmpdir=$(mktemp -d)
    local sb id
    sb=$(scoreboard_json "")
    printf '%s' "$sb" > "$tmpdir/sb.json"
    id=$(find_event "$sb" "$team")
    [[ -n $id ]] || die "no game this week for '$team' (bye week, or unknown team name)"
    fetch "${BASE}/summary?event=${id}" > "$tmpdir/g.json"

    if (( json )); then
        jq -n --slurpfile sbf "$tmpdir/sb.json" --slurpfile gf "$tmpdir/g.json" --arg id "$id" \
            '{scoreboardEvent: ($sbf[0].events[] | select(.id==$id)), summary: $gf[0]}'
        return
    fi

    # situation/win% come from the scoreboard: it updates faster than summary's play list
    jq -r -n --slurpfile sbf "$tmpdir/sb.json" --slurpfile gf "$tmpdir/g.json" --arg id "$id" --argjson n "$plays" '
      def pct: if . == null then "?" else ((. * 100) | round | tostring) + "%" end;
      $sbf[0] as $sb | $gf[0] as $g |
      ($sb.events[] | select(.id==$id)) as $e
      | $e.competitions[0] as $c
      | ($c.competitors | map(select(.homeAway=="away"))[0]) as $a
      | ($c.competitors | map(select(.homeAway=="home"))[0]) as $h
      | $e.status.type.state as $st
      | ($c.situation // {}) as $s
      |
      "\($a.team.displayName) (\($a.records[0].summary // "")) @ \($h.team.displayName) (\($h.records[0].summary // ""))",
      "\($c.venue.fullName // "")  | TV: \($c.broadcasts[0].names // [] | join("/"))  | fetched \(now | strftime("%H:%M:%SZ"))",
      "",
      "STATUS: \($e.status.type.shortDetail)",
      (if $st != "pre" then
         "SCORE:  \($a.team.abbreviation) \($a.score)  -  \($h.team.abbreviation) \($h.score)",
         ( ($g.boxscore.teams // []) as $bt
           | if ($bt|length) > 0 and (($g.header.competitions[0].competitors[0].linescores // []) | length) > 0 then
               ($g.header.competitions[0].competitors
                | map("        \(.team.abbreviation)  " + ([.linescores[]?.displayValue] | join("  ")) ) | .[])
             else empty end )
       else empty end),
      (if $st == "in" then
         "",
         "SITUATION: " + ($s.downDistanceText // "—")
           + (if $s.isRedZone then "  [RED ZONE]" else "" end)
           + (if $s.possession then "  (ball: " + ([$c.competitors[] | select(.id==$s.possession) | .team.abbreviation][0] // "?") + ")" else "" end),
         "LAST PLAY: " + (($s.lastPlay.text // "—") | gsub("^\\s+"; "")),
         "WIN PROB:  \($h.team.abbreviation) \($s.lastPlay.probability.homeWinPercentage // ($g.winprobability // [] | last | .homeWinPercentage) | pct)"
           + " / \($a.team.abbreviation) \((1 - ($s.lastPlay.probability.homeWinPercentage // ($g.winprobability // [] | last | .homeWinPercentage) // 1)) | pct)"
       else empty end),

      (($g.pickcenter // [])[0]) as $odds
      | (if $odds then "PREGAME LINE: \($odds.details // "?")  O/U \($odds.overUnder // "?")  (\($odds.provider.name // ""))" else empty end),

      (if ($g.scoringPlays // [] | length) > 0 then
         "", "SCORING:",
         ($g.scoringPlays[] | "  Q\(.period.number) \(.clock.displayValue)  \(.team.abbreviation)  \(.type.text): \(.text)  [\(.awayScore)-\(.homeScore)]")
       else empty end),

      (if ($g.boxscore.teams // [] | length) == 2 then
         ($g.boxscore.teams) as $t
         | ["Total Yards","Passing","Rushing","1st Downs","3rd down efficiency","4th down efficiency","Red Zone (Made-Att)","Turnovers","Sacks-Yards Lost","Penalties","Possession"] as $want
         | "", "TEAM STATS:            \($t[0].team.abbreviation | .[0:6])    \($t[1].team.abbreviation | .[0:6])",
           ( $want[] as $lbl
             | [ $t[] | (.statistics[] | select(.label==$lbl) | .displayValue) // "-" ] as $v
             | "  \($lbl | .[0:20] | . + (" " * (20 - length)))  \($v[0] | . + (" " * (8 - length)))  \($v[1])" )
       else empty end),

      (if ($g.leaders // [] | length) > 0 then
         "", "LEADERS:",
         ($g.leaders[] | .team.abbreviation as $tm | .leaders[]
           | select(.leaders | length > 0)
           | "  \($tm)  \(.displayName): \(.leaders[0].athlete.displayName) — \(.leaders[0].displayValue)")
       else empty end),

      ( ($g.drives.current // null) as $d
        | if $d and ($d.plays // [] | length) > 0 then
            "", "CURRENT DRIVE (\($d.team.abbreviation // "")): \($d.description // "")",
            ($d.plays[-$n:][] | "  Q\(.period.number) \(.clock.displayValue)  \(.text | gsub("^\\s+"; ""))")
          else
            (($g.drives.previous // []) | last) as $p
            | if $p then
                "", "LAST DRIVE (\($p.team.abbreviation // "")): \($p.description // "")  → \($p.displayResult // "")",
                (($p.plays // [])[-$n:][] | "  Q\(.period.number) \(.clock.displayValue)  \(.text | gsub("^\\s+"; ""))")
              else empty end
          end ),

      ( ($g.injuries // []) | map(select(.injuries | length > 0)) as $inj
        | if ($inj|length) > 0 then
            "", "INJURY REPORT:",
            ($inj[] | "  \(.team.abbreviation): " + ([.injuries[] | "\(.athlete.displayName) (\(.athlete.position.abbreviation // "")) \(.status)"] | join("; ")))
          else empty end )
    '
}

# ---------- main ----------
require curl jq

case ${1:-scores} in
    scores)        shift || true; cmd_scores "$@" ;;
    game)          shift; cmd_game "$@" ;;
    -h|--help|help) usage ;;
    --week|--date|--json) cmd_scores "$@" ;;
    -*)            usage ;;
    *)             cmd_game "$@" ;;
esac
