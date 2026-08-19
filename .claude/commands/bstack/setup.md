---
name: bstack:setup
description: 'Local bootstrap — version control + auto-setup for a bstack repo, plus enable automatic bstack update checks and per-command model auto-selection.'
argument-hint: '[--auto-upgrade=on|off] [--no-git]'
model: sonnet
---

# /bstack:setup

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.
>
> **Use when:** standing up bstack in a repo for the first time (or repairing a partial install) — wire version control, confirm the bstack install, and turn on automatic updates + model tiering. Delegates to the `bstack-setup` skill.

## Steps

1. **Version control** — confirm the repo is a git repo (offer `git init` if not, unless `--no-git`). Verify the branch/base conventions in `.claude/config/command-conventions.md` are usable: feature branches `<initials>/<short-topic>`, base defaults to `main`. Confirm the SessionStart hook (`.claude/hooks/SessionStart.sh`) and router hook (`.claude/hooks/route.sh`) are wired in `.claude/settings.json`.
2. **bstack install check** — detect the install (global `~/.claude/skills/bstack`, vendored `.claude/skills/bstack`, or the in-repo `.claude/` toolkit). Confirm commands, agents, overlays, and `routes.tsv` are all present. **First-time machine setup — or missing Python deps for the docx/xlsx/PDF engines — run `./bin/setup`**: it provisions the toolchain (`requirements.txt` → python-docx, openpyxl, Pillow, reportlab) and registers commands/agents/skills/bin user-wide so bstack works in any project. `./bin/update` refreshes everything (and re-runs the gates) later.
3. **Auto-update** — enable automatic update checks so the toolkit stays current (item ties into the `/bstack-upgrade` skill):
   - `--auto-upgrade=on` (default when the user asked to "check and update automatically"): set `auto_upgrade true` and `update_check true` via the global install's `bstack-config` CLI (under `~/.claude/skills/bstack/`) when present, or export `GSTACK_AUTO_UPGRADE=1` for this environment; tell the user how to make it permanent.
   - `--auto-upgrade=off`: leave manual — the user runs `/bstack-upgrade` when they choose.
4. **Model auto-selection** — confirm the three overlays exist (`.claude/overlays/{haiku,sonnet,opus}.md`) and that every command's frontmatter `model` tier matches the tier table in `.claude/config/command-conventions.md`. Each command is **pinned in frontmatter to its cheapest correct tier** (haiku for toggles, sonnet for procedural flows, opus for judgment), so it runs at that tier automatically with no manual model switching — that static mapping is the token economy. Run `bin/bstack-doc-drift` to flag any command missing from or disagreeing with the table.
5. **Verify** — run `bin/bstack-command-lint` (must be clean) and print a readiness summary: git ✓/✗, install type, auto-upgrade state, overlays present, lint result.

## Hard rules

- Never commit secrets or credentials while wiring version control (critical-patterns §3).
- Auto-upgrade must be reversible — always tell the user the exact command to turn it back off.
- Do not change any command's model tier to "save cost" without the tier table agreeing — the table in `command-conventions.md` is the source of truth (edit it first via `/bstack:improve` if a tier is genuinely wrong).
