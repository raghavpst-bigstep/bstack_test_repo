---
name: bstack:freeze
description: 'Restrict file edits to a specific directory for the session — prevents accidental cross-boundary edits during focused work (hotfix, investigation, refactor)'
argument-hint: '[optional: directory path]'
model: haiku
---

> **TASK TRACKING:** Single task: apply the toggle and confirm state. Mark complete when done.

# /bstack:freeze — Restrict edits to a directory

Locks file edits to a specific directory. Any `Edit` or `Write` outside the allowed path is **blocked** (not just warned). Useful when:

- Hotfixing a single microservice and you don't want me wandering into other apps.
- Debugging — prevents "fixing" unrelated code while you investigate.
- Refactoring inside one Nx lib without touching its consumers until you say so.
- Working in a worktree dedicated to one domain.

## How to invoke

- `/bstack:freeze` → ask which directory to freeze
- `/bstack:freeze apps/api-gateway` → freeze immediately to that path
- Run `/bstack:unfreeze` to lift the boundary.

## Steps

1. **Resolve the boundary.**
   - If the user gave a path as `$ARGUMENTS`, use it.
   - Otherwise ask: "Which directory should I restrict edits to? Files outside this path will be blocked."

2. **Validate and persist.**
   ```bash
   TARGET="${ARGUMENTS:-<user-provided-path>}"
   FREEZE_DIR=$(cd "$TARGET" 2>/dev/null && pwd)
   if [ -z "$FREEZE_DIR" ]; then
     echo "ERROR: $TARGET does not exist. Provide an existing directory."
     exit 1
   fi
   mkdir -p .claude/state
   printf '%s' "$FREEZE_DIR" > .claude/state/freeze-dir.txt
   echo "Freeze boundary set: $FREEZE_DIR"
   ```

3. **Confirm to the user.**
   > Edits are restricted to `<path>/`. Any `Edit` or `Write` outside this directory will be blocked. To change the boundary, run `/bstack:freeze <new-path>`. To remove it, run `/bstack:unfreeze` or end the session.

## How it works

A `PreToolUse` hook (`.claude/hooks/check-freeze.sh`) runs on every `Edit` and `Write`. It reads `file_path` from the tool input, checks if it starts with the freeze directory, and returns `permissionDecision: "deny"` if not.

The freeze boundary persists for the session via the state file `.claude/state/freeze-dir.txt`. The state file is gitignored by convention — it's per-developer, per-session.

## Notes

- The trailing-path check prevents `/src` from matching `/src-old`.
- Freeze applies to `Edit` and `Write` only — `Read`, `Bash`, `Glob`, `Grep` are unaffected.
- This is **accident prevention, not a security boundary** — `Bash` can still run `sed -i` against files anywhere.
- Combine with `/bstack:careful` for both edit-scope + destructive-command guards.
- Freeze does NOT replace the `ddd-boundary-enforcer` reviewer — that runs at review time on what changed. Freeze stops bad edits before they happen.

## Scoping tip

When hotfixing, freeze to the specific repo + service file you're touching to prevent accidental cross-app edits that would expand the blast radius. Smaller freeze boundary = smaller deploy.
