---
name: bstack:rice-init
description: 'One-time R.I.C.E. scaffold for this project — base SKILL.md at repo root, optional per-app SKILL.md for polyglot monorepos.'
argument-hint: ''
model: opus
---

# /bstack:rice-init

> **TASK TRACKING:** Create one task per numbered phase. Mark complete as you go.

Once-per-project setup. Produces:

- `.claude/skills/feature-protocol/SKILL.md` — repo-root **base** with cross-cutting Enforcement (DDD, async context, secrets, migrations, observability — pulled from `.claude/rules/critical-patterns.md`).
- `apps/<name>/.claude/skills/<app>-feature-protocol/SKILL.md` — optional **per-app** files for polyglot monorepos. Each `extends:` the base and sets an `applies_to:` glob.
- A short "Feature protocol" pointer line in `CLAUDE.md` (conditional — never blocking).

## Phases

1. **Detect stack signals.** Run `bin/bstack-rice init` once to print detected files (`nx.json`, `package.json`, `app.json`, `requirements.txt`, `go.mod`, `Podfile`, `build.gradle`, …) and any `apps/` / `projects/` / `packages/` candidates. Use the output to seed your questions.

2. **Confirm base.** Show the user:
   - project name (default = repo dir basename, override accepted)
   - one-line stack summary
   - source-of-truth doc path(s) (e.g. `docs/architecture/PRINCIPLES.md`, `SOW.md`, a Notion link)
   - domain rule namespace (e.g. `W/D/V/G` for SOW-style; for bstack: `DDD/SOC/AUTHZ/PERF` from `.claude/rules/critical-patterns.md` section numbers)
   - whether the project enforces an a11y/i18n floor (yes/no)

   Read `.claude/skills/feature-protocol/SKILL.template.md`. Substitute placeholders with the confirmed values and write to `.claude/skills/feature-protocol/SKILL.md`. Set `version: 1` and `last_reviewed:` to today (YYYY-MM-DD). Set `applies_to: "**"`.

3. **Pull base Enforcement from existing rules.** For bstack-shape repos, copy the numbered invariants from `.claude/rules/critical-patterns.md` (all numbered sections) into the base SKILL.md's Enforcement section. For non-bstack repos, copy from the user's `.claude/rules/` or equivalent; if absent, keep the placeholder Enforcement list from the template and tell the user to fill it.

4. **Per-app scaffold (interactive).** For each `apps/<name>` / `projects/<name>` candidate, ask the user: "scaffold SKILL.md for `<name>`? [y/N/skip-all]". For each yes:
   - Create `apps/<name>/.claude/skills/<name>-feature-protocol/SKILL.md`.
   - Set `extends: ../../../../.claude/skills/feature-protocol/SKILL.md` (count the `..` segments from the per-app file back to repo root).
   - Set `applies_to: apps/<name>/**`.
   - Detect the per-app stack from its `package.json` / `go.mod` / `requirements.txt` / `app.json` and pre-fill the locked-stack table with the actually-imported framework rows (React + RTK + MUI v5 for TS web; Express 5 for TS backend; FastAPI + Temporal + LangChain for Python; etc.).
   - Leave Role / Intent boundaries as placeholders for the user to refine.

5. **Wire CLAUDE.md.** Append (idempotent — skip if already present) a one-line pointer:
   ```
   ## Feature protocol (R.I.C.E.)
   This repo uses the R.I.C.E. feature-architect protocol. See `.claude/skills/feature-protocol/SKILL.md` (base) and per-app `.claude/skills/<app>-feature-protocol/SKILL.md`. New-feature work routes through `/bstack:rice` automatically; for existing-code edits, match local patterns.
   ```

6. **Validate.** Run `bin/bstack-rice validate`. Report hard fails (placeholders still in `[BRACKETED]` form, missing sections) to the user and stop — they must fill before the protocol is live.

7. **Summary.** Print the file tree of created SKILL.md files and the next command to try: `/bstack:rice` on any new-feature prompt.

## Conventions

- This command is **safe to re-run** — it never overwrites a SKILL.md that already exists. To regenerate, delete the file first.
- The base SKILL.md's Enforcement section is the **superset**; per-app files extend it, never narrow it.
- Don't ask permission to read template files — read freely. Do ask permission before writing per-app files.
