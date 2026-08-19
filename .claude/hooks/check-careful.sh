#!/usr/bin/env bash
# check-careful.sh — PreToolUse hook for /bstack:careful
# Reads JSON from stdin, checks Bash command for destructive patterns.
# Returns {"permissionDecision":"ask","message":"..."} to warn, or {} to allow.
#
# State file: .claude/state/careful-active — created by /bstack:careful, removed
# at session end or by the user. The hook is a no-op if the file is absent so
# careful only kicks in when explicitly enabled.
set -euo pipefail

INPUT=$(cat)

STATE_FILE="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/state/careful-active"
if [ ! -f "$STATE_FILE" ]; then
  echo '{}'
  exit 0
fi

# Extract command from tool_input
CMD=$(printf '%s' "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)
if [ -z "$CMD" ]; then
  CMD=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read()).get("tool_input",{}).get("command",""))' 2>/dev/null || true)
fi
if [ -z "$CMD" ]; then
  echo '{}'
  exit 0
fi

CMD_LOWER=$(printf '%s' "$CMD" | tr '[:upper:]' '[:lower:]')

# --- Safe-exception: rm -rf of standard build artifacts ---
if printf '%s' "$CMD" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*\s+|--recursive\s+)' 2>/dev/null; then
  SAFE_ONLY=true
  RM_ARGS=$(printf '%s' "$CMD" | sed -E 's/.*rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*//;s/--recursive[[:space:]]*//')
  for target in $RM_ARGS; do
    case "$target" in
      */node_modules|node_modules|*/\.next|\.next|*/dist|dist|*/__pycache__|__pycache__|*/\.cache|\.cache|*/build|build|*/\.turbo|\.turbo|*/coverage|coverage|*/\.nx|\.nx|*/tmp|tmp|*/\.pytest_cache|\.pytest_cache)
        ;;
      -*) ;;
      *) SAFE_ONLY=false; break ;;
    esac
  done
  if [ "$SAFE_ONLY" = true ]; then
    echo '{}'
    exit 0
  fi
fi

WARN=""
PATTERN=""

# rm -rf / rm -r
if printf '%s' "$CMD" | grep -qE 'rm\s+(-[a-zA-Z]*r|--recursive)' 2>/dev/null; then
  WARN="Recursive delete (rm -r). Permanently removes files."
  PATTERN="rm_recursive"
fi

# SQL DROP / TRUNCATE
if [ -z "$WARN" ] && printf '%s' "$CMD_LOWER" | grep -qE 'drop\s+(table|database|schema)' 2>/dev/null; then
  WARN="SQL DROP detected. Permanently deletes database objects. Confirm the target and that you have a backup."
  PATTERN="sql_drop"
fi
if [ -z "$WARN" ] && printf '%s' "$CMD_LOWER" | grep -qE '\btruncate\b' 2>/dev/null; then
  WARN="SQL TRUNCATE detected. Deletes all rows in the table — confirm scope."
  PATTERN="sql_truncate"
fi

# Kysely / migration rollback
if [ -z "$WARN" ] && printf '%s' "$CMD_LOWER" | grep -qE '(kysely.*migrate.*down|migrate:down|migrate-down)' 2>/dev/null; then
  WARN="Kysely migration rollback. Re-check the down() body — rule 4.1 says down must actually reverse up."
  PATTERN="kysely_rollback"
fi

# git force-push
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'git\s+push\s+.*(-f\b|--force)' 2>/dev/null; then
  WARN="git force-push rewrites remote history. Other contributors may lose work. NEVER on main/master."
  PATTERN="git_force_push"
fi

# git reset --hard
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'git\s+reset\s+--hard' 2>/dev/null; then
  WARN="git reset --hard discards all uncommitted changes."
  PATTERN="git_reset_hard"
fi

# git checkout . / restore .
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'git\s+(checkout|restore)\s+\.' 2>/dev/null; then
  WARN="Discards all uncommitted changes in the working tree."
  PATTERN="git_discard"
fi

# git --no-verify (skips hooks)
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE '(--no-verify|-n\b)' 2>/dev/null && printf '%s' "$CMD" | grep -qE 'git\s+commit' 2>/dev/null; then
  WARN="git commit --no-verify skips pre-commit hooks (lint, tests, secret scans). Bstack policy: investigate the hook failure, don't bypass it."
  PATTERN="git_no_verify"
fi

# kubectl delete / apply -f against prod
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'kubectl\s+delete' 2>/dev/null; then
  WARN="kubectl delete removes Kubernetes resources. Check the kubeconfig context — staging or prod?"
  PATTERN="kubectl_delete"
fi
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'kubectl.*--context[= ]\S*prod' 2>/dev/null; then
  WARN="kubectl command targeting a 'prod' context. Confirm intent."
  PATTERN="kubectl_prod"
fi

# Docker
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'docker\s+(rm\s+-f|system\s+prune)' 2>/dev/null; then
  WARN="Docker force-remove or prune. May delete running containers or cached images."
  PATTERN="docker_destructive"
fi

# Redis FLUSHALL / FLUSHDB
if [ -z "$WARN" ] && printf '%s' "$CMD_LOWER" | grep -qE '\bflushall\b|\bflushdb\b' 2>/dev/null; then
  WARN="Redis FLUSH detected. Wipes the entire cache — confirm you want to drop every key."
  PATTERN="redis_flush"
fi

# AWS S3 rm with --recursive or rb
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'aws\s+s3\s+(rm\s+.*--recursive|rb\s)' 2>/dev/null; then
  WARN="AWS S3 recursive delete or bucket removal. Confirm the prefix scope before deleting."
  PATTERN="s3_recursive_delete"
fi

# Terraform destroy
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'terraform\s+(destroy|apply\s+-destroy)' 2>/dev/null; then
  WARN="terraform destroy. Tears down managed infrastructure. Confirm the workspace."
  PATTERN="terraform_destroy"
fi

# Nx reset / cache clear
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'nx\s+reset' 2>/dev/null; then
  WARN="nx reset clears the Nx cache. Not destructive to source, but next build will be slow. Confirm intent (usually fine)."
  PATTERN="nx_reset"
fi

# Direct psql / pg connection (raw access to a DB)
if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE '\bpsql\s.*\b(prod|production)\b' 2>/dev/null; then
  WARN="psql against a 'prod' database. Read-only? Be explicit before running writes."
  PATTERN="psql_prod"
fi

if [ -n "$WARN" ]; then
  LEARN_DIR="${CLAUDE_PROJECT_DIR:-$PWD}/docs/solutions"
  mkdir -p "$LEARN_DIR" 2>/dev/null || true
  REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")
  printf '{"event":"hook_fire","skill":"careful","pattern":"%s","ts":"%s","repo":"%s"}\n' \
    "$PATTERN" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$REPO" >> "$LEARN_DIR/hook-events.jsonl" 2>/dev/null || true

  WARN_ESCAPED=$(printf '%s' "$WARN" | sed 's/"/\\"/g')
  printf '{"permissionDecision":"ask","message":"[bstack:careful] %s"}\n' "$WARN_ESCAPED"
else
  echo '{}'
fi
