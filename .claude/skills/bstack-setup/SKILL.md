---
name: bstack-setup
description: >
  Local bootstrap for a bstack repo — wire version control, confirm the bstack
  install, enable automatic update checks (auto-upgrade), and verify per-command
  model auto-selection (the tier-per-command mapping that runs each command at the
  cheapest correct model). Invoked by /bstack:setup. The heavy upgrade flow itself
  lives in the /bstack-upgrade skill; this skill turns it on and verifies wiring.
version: 1
last_reviewed: 2026-08-03
applies_to: ".claude/**, .git/**, ~/.bstack/config.yaml"
triggers:
  - set up bstack
  - bootstrap bstack
  - version control setup
  - enable auto upgrade
  - keep bstack updated
  - configure model tiers
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - AskUserQuestion
---

# bstack-setup — Local Bootstrap + Auto-Update + Model Auto-Selection

Stands bstack up in a repo and turns on the two "keep it current, keep it cheap"
behaviors the user asked for: **automatic update checks** and **per-command model
auto-selection**. Runs at the **sonnet** tier (procedural bootstrap). Idempotent —
safe to re-run to repair a partial install.

## 1. Version control

- Confirm the repo is under git; if not and `--no-git` was not passed, offer
  `git init` and an initial commit boundary. Never sweep unrelated changes.
- Verify the branch conventions from `.claude/config/command-conventions.md` are
  usable: feature branches `<initials>/<short-topic>`, hotfix `hotfix/<id>-<short>`,
  base defaults to `main`.
- Confirm the hooks are wired in `.claude/settings.json`: `SessionStart.sh` (session
  bootstrap) and `route.sh` (`UserPromptSubmit` auto-router). A missing hook means
  auto-routing (CLAUDE.md hard rule 6) silently does not run — surface it.

## 2. bstack install check

Detect the install so later steps target the right paths:

```bash
if   [ -d "$HOME/.claude/skills/bstack/.git" ]; then echo "global-git";
elif [ -d ".claude/skills/bstack/.git" ];       then echo "local-git";
elif [ -d ".claude/skills/bstack" ];            then echo "vendored";
elif [ -d ".claude/commands/bstack" ];          then echo "in-repo toolkit";
else echo "not found"; fi
```

Confirm the surface is complete: `.claude/commands/bstack/`, `.claude/agents/`,
`.claude/overlays/`, `.claude/config/routes.tsv`, `bin/`. A gap here is why a command
"isn't found" — report exactly which piece is missing.

## 3. Auto-update (check + update bstack automatically)

The full upgrade flow (detect install type, fetch, migrate, show what's new) lives in
the **`/bstack-upgrade`** skill. This step only decides whether it runs automatically.

- **`--auto-upgrade=on`** (the default when the user asked to "check and update
  automatically"): enable both auto-upgrade and the periodic update check.

  ```bash
  # Preferred: the config CLI, if the global install ships it
  ~/.claude/skills/bstack/bin/bstack-config set auto_upgrade true   2>/dev/null || true
  ~/.claude/skills/bstack/bin/bstack-config set update_check true   2>/dev/null || true
  ```

  If `bstack-config` is absent, fall back to `export GSTACK_AUTO_UPGRADE=1` for the
  current environment and tell the user how to persist it (shell profile or
  `~/.bstack/config.yaml: auto_upgrade: true`). When auto-upgrade is on, the upgrade
  runs without a prompt and restores from backup if `./setup` fails.

- **`--auto-upgrade=off`**: leave it manual — the user runs `/bstack-upgrade` on
  demand. Always tell the user the exact command to reverse whichever choice was made.

## 4. Model auto-selection (token economy)

There is no separate "model picker" to install — bstack already auto-selects the model
per command through frontmatter. Verify that mechanism instead of building a new one:

- The three overlays exist: `.claude/overlays/haiku.md`, `sonnet.md`, `opus.md`.
- Every command's frontmatter `model` tier matches the tier table in
  `.claude/config/command-conventions.md`. That table is the single source (haiku for
  toggles, sonnet for procedural flows, opus for judgment) — verify against it, do not
  restate the per-tier command lists here (they drift). Run `bin/bstack-doc-drift`, which
  fails if any command is missing from the table.

This tier-per-command mapping **is** the auto-selection and the token economy: each
command runs at the cheapest correct tier automatically, with no manual model
switching. Flag any command whose tier disagrees with the table; the fix is a
`/bstack:improve` pass (which owns edits to the table), not an ad-hoc tier change here.

## 5. Verify + report

Run `bin/bstack-command-lint` (must be clean) and print a readiness line:

```
git: ✓   install: <type>   auto-upgrade: on|off   overlays: 3/3   lint: clean
```

Plus any gap found (missing hook, missing overlay, tier mismatch, absent env var) as a
short follow-up list.

## Hard rules

1. Never commit secrets or credentials while wiring version control (critical-patterns §3).
2. Auto-upgrade is reversible — always print the exact off-switch.
3. Do not change a command's model tier to "save cost"; the table in
   `command-conventions.md` is the source of truth — correct it via `/bstack:improve`.
4. This skill enables and verifies; the upgrade mechanics themselves stay in `/bstack-upgrade`.
