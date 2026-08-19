#!/bin/bash
# bstack — UserPromptSubmit router hook.
#
# Fires on every user prompt. Classifies plain-English intent against
# .claude/config/routes.tsv and injects a routing hint so work flows through a
# /bstack:* command even when the user typed no slash command. Terse by design —
# emits ONLY on a confident match, so it costs ~nothing per turn.
#
# Contract (CLAUDE.md hard rule 6): act on the hint — load the command's
# workflow and run it; never freehand work a command covers.
set -u

# Resolve routes.tsv relative to THIS script so the router works when installed as a
# plugin hook (cwd = the user's project), falling back to the project cwd for in-repo use.
_HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
ROUTES=""
[ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -f "$CLAUDE_PLUGIN_ROOT/.claude/config/routes.tsv" ] && ROUTES="$CLAUDE_PLUGIN_ROOT/.claude/config/routes.tsv"
[ -z "$ROUTES" ] && [ -f "$_HERE/../config/routes.tsv" ] && ROUTES="$_HERE/../config/routes.tsv"
[ -z "$ROUTES" ] && [ -f ".claude/config/routes.tsv" ] && ROUTES=".claude/config/routes.tsv"

# I-03: fail LOUDLY when the table is unreachable. A silent `exit 0` here reported
# success while routing nothing, which is exactly how I-02 (routes.tsv never vendored
# by setup) stayed invisible for weeks. Warn on stderr, then exit 0 — a non-zero exit
# from a UserPromptSubmit hook can block the user's prompt, and a broken router must
# degrade the session, never halt it.
if [ -z "$ROUTES" ] || [ ! -f "$ROUTES" ]; then
  printf '[bstack router] routes.tsv NOT FOUND — intent auto-routing is OFF, so CLAUDE.md hard rule 6 is unenforced this session.\n' >&2
  printf '[bstack router] looked in: $CLAUDE_PLUGIN_ROOT/.claude/config/, %s/../config/, ./.claude/config/\n' "$_HERE" >&2
  printf '[bstack router] fix: re-run  ./setup --project .  from your repo root.\n' >&2
  exit 0
fi

# Prompt arrives as JSON on stdin: {"prompt": "...", ...}
PROMPT=$(python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("prompt",""))
except Exception: pass' 2>/dev/null || true)
[ -z "$PROMPT" ] && exit 0

# Explicit slash command → user already chose a route; stay out of the way.
case "$PROMPT" in /*) exit 0 ;; esac

LOW=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')

hits=""
seen="|"
while IFS=$'\t' read -r pat cmd note; do
  [ -z "${pat:-}" ] && continue
  case "$pat" in \#*) continue ;; esac
  [ -z "${cmd:-}" ] && continue
  if printf '%s' "$LOW" | grep -qE "$pat" 2>/dev/null; then
    case "$seen" in
      *"|$cmd|"*) : ;;                       # already routed to this command
      *)
        hits="${hits}  ${cmd} — ${note}"$'\n'
        seen="${seen}${cmd}|"
        ;;
    esac
  fi
done < "$ROUTES"

[ -z "$hits" ] && exit 0   # no confident match — say nothing

# Cap at the top 2 routes to stay terse.
TOP=$(printf '%s' "$hits" | sed '/^$/d' | head -2)

printf '[bstack router] Detected intent → route through:\n%s\n' "$TOP"
echo "Load that command's workflow and run it; don't freehand work a command covers. Planning precedes coding. (Override only if the user explicitly asks for something else.)"
exit 0
