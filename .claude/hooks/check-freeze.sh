#!/usr/bin/env bash
# check-freeze.sh — PreToolUse hook for /bstack:freeze
# Reads JSON from stdin, checks if file_path is within the freeze boundary.
# State file is project-scoped at .claude/state/freeze-dir.txt.
# Returns {"permissionDecision":"deny","message":"..."} to block, or {} to allow.
set -euo pipefail

INPUT=$(cat)

# Project-scoped state. CLAUDE_PROJECT_DIR is set by Claude Code when a hook runs.
STATE_DIR="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/state"
FREEZE_FILE="$STATE_DIR/freeze-dir.txt"

if [ ! -f "$FREEZE_FILE" ]; then
  echo '{}'
  exit 0
fi

FREEZE_DIR=$(tr -d '[:space:]' < "$FREEZE_FILE")
if [ -z "$FREEZE_DIR" ]; then
  echo '{}'
  exit 0
fi

# Extract file_path from tool_input JSON (grep first, Python fallback for escapes)
FILE_PATH=$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read()).get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)
fi

if [ -z "$FILE_PATH" ]; then
  echo '{}'
  exit 0
fi

# Resolve to absolute
case "$FILE_PATH" in
  /*) ;;
  *)  FILE_PATH="$(pwd)/$FILE_PATH" ;;
esac

# Normalize double slashes / trailing slash
FILE_PATH=$(printf '%s' "$FILE_PATH" | sed 's|/\+|/|g;s|/$||')

# Resolve symlinks and .. (POSIX-portable for macOS)
_resolve_path() {
  local _dir _base
  _dir="$(dirname "$1")"
  _base="$(basename "$1")"
  _dir="$(cd "$_dir" 2>/dev/null && pwd -P || printf '%s' "$_dir")"
  printf '%s/%s' "$_dir" "$_base"
}
FILE_PATH=$(_resolve_path "$FILE_PATH")
FREEZE_DIR=$(_resolve_path "$FREEZE_DIR")

case "$FILE_PATH" in
  "${FREEZE_DIR}/"*|"${FREEZE_DIR}")
    echo '{}'
    ;;
  *)
    # Log to learnings sink for telemetry
    LEARN_DIR="${CLAUDE_PROJECT_DIR:-$PWD}/docs/solutions"
    mkdir -p "$LEARN_DIR" 2>/dev/null || true
    REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")
    printf '{"event":"hook_fire","skill":"freeze","pattern":"boundary_deny","ts":"%s","repo":"%s"}\n' \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$REPO" >> "$LEARN_DIR/hook-events.jsonl" 2>/dev/null || true

    printf '{"permissionDecision":"deny","message":"[bstack:freeze] Blocked: %s is outside the freeze boundary (%s). Edit only within the frozen directory, or run /bstack:unfreeze to lift the boundary."}\n' "$FILE_PATH" "$FREEZE_DIR"
    ;;
esac
