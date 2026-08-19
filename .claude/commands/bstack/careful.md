---
name: bstack:careful
description: 'Activate destructive-command guardrails — warn before rm -rf, DROP, force-push, kubectl delete, Redis FLUSH, S3 recursive delete, terraform destroy, and Kysely migration rollbacks'
model: haiku
---

> **TASK TRACKING:** Single task: apply the toggle and confirm state. Mark complete when done.

# /bstack:careful — Safety mode for destructive commands

Activates a `PreToolUse` guard that intercepts dangerous bash commands and asks you to confirm before running them. The override is one-click — careful warns, you decide.

## How to invoke

- `/bstack:careful` → turn on. Stays on until session ends or you run `/bstack:careful off`.
- `/bstack:careful off` → turn off.
- `/bstack:careful status` → check current state.

## Steps

```bash
ARG="${ARGUMENTS:-on}"
STATE_DIR=".claude/state"
mkdir -p "$STATE_DIR"
case "$ARG" in
  off|disable|stop)
    rm -f "$STATE_DIR/careful-active"
    echo "Careful mode: OFF. Destructive commands run without prompts."
    ;;
  status)
    if [ -f "$STATE_DIR/careful-active" ]; then echo "Careful mode: ON."; else echo "Careful mode: OFF."; fi
    ;;
  *)
    touch "$STATE_DIR/careful-active"
    echo "Careful mode: ON. Destructive commands will prompt for confirmation."
    ;;
esac
```

Tell the user the result.

## What's protected

| Pattern | Example | Why it's risky |
|---------|---------|---|
| `rm -rf` / `rm -r` | `rm -rf /var/data` | Recursive delete |
| `DROP TABLE` / `DROP DATABASE` / `DROP SCHEMA` | `DROP TABLE users;` | Permanent data loss |
| `TRUNCATE` | `TRUNCATE orders;` | Wipes all rows in the table |
| **Kysely migration rollback** | `npm run db:migrate:down` | Rule 4.1 — confirm `down()` actually reverses `up()` |
| `git push --force` / `-f` | `git push -f origin main` | History rewrite |
| `git reset --hard` | `git reset --hard HEAD~3` | Discards uncommitted work |
| `git checkout .` / `git restore .` | `git checkout .` | Discards working tree |
| `git commit --no-verify` | | Bstack policy: fix the hook, don't bypass it |
| `kubectl delete` | `kubectl delete pod ...` | Prod impact — check context |
| `docker rm -f` / `docker system prune` | | Container/image loss |
| **Redis `FLUSHALL` / `FLUSHDB`** | `redis-cli FLUSHALL` | Wipes the entire cache |
| **AWS S3 recursive delete / `rb`** | `aws s3 rm s3://bucket --recursive` | Deletes files under the prefix |
| `terraform destroy` | `terraform destroy -auto-approve` | Tears down infra |
| `nx reset` | | Cache clear — not destructive, but informational |
| `psql` against `prod` | `psql postgres://...prod...` | Confirm read-only before running writes |

## Safe exceptions

`rm -rf` of standard build artifacts runs without prompt:
`node_modules`, `.next`, `dist`, `__pycache__`, `.cache`, `build`, `.turbo`, `coverage`, `.nx`, `tmp`, `.pytest_cache`.

## How it works

The hook (`.claude/hooks/check-careful.sh`) checks the state file `.claude/state/careful-active`. If absent, the hook is a no-op. If present, it scans every `Bash` command for destructive patterns and returns `permissionDecision: "ask"` with a contextual warning.

The hook is wired in `.claude/settings.json` and runs project-wide. To make it user-wide, copy `check-careful.sh` to `~/.claude/hooks/` and mirror the hook in `~/.claude/settings.json`.

## Pairs well with

- `/bstack:freeze` — scope edits to one directory while careful guards bash.
- `/bstack:deploy` — turn careful on automatically when shipping to prod (already done by the deploy command).
- The reviewer agents — careful blocks at command time, the reviewers catch at code-review time.

## Notes

- Careful is a **prompt, not a block** — you can always proceed. It exists to slow you down for one breath before something irreversible.
- The highest-leverage warnings here are DROP/TRUNCATE, Redis FLUSH, S3 recursive delete, and Kysely migration rollback (§4.1) — the operations that lose data or break prod silently if done wrong.
