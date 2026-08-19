---
name: bstack:improve
description: 'Self-maintenance for bstack — audit every command/skill/doc for drift, format, lint, and README prose, then fix. Keeps counts, tables, and routes in sync.'
argument-hint: '[--scope=commands|skills|docs|all] [--report-only]'
model: sonnet
---

# /bstack:improve

> **TASK TRACKING:** Create one task per audit dimension (structure, lint, docs-sync, prose, routes). Mark each complete as you go.
>
> **Use when:** you added or changed bstack commands/skills/docs and want the toolkit itself kept consistent — no drift between the files and the indexes that describe them. This command improves **bstack**, not the consuming app's code (for that, use `/bstack:review` or `/bstack:health`).

Delegates the heavy lifting to the `bstack-improve` skill. Reads the whole `.claude/` + `docs/` surface, digests it, and applies mechanical corrections at the cheapest correct model tier.

## Steps

1. **Inventory** — enumerate `.claude/commands/bstack/*.md`, `.claude/skills/*/SKILL.md`, `.claude/agents/*.md`, and the doc set (`readme.md`, `MANIFEST.md`, `docs/**`, `bin/README.md`). Read all of them (they are small; reading is cheap relative to guessing).
2. **Structure + lint** — run `bin/bstack-command-lint` for every command. Confirm each has valid frontmatter (`name` == `bstack:<stem>`, non-empty `description`, a model tier from the table in `.claude/config/command-conventions.md`) and a `> **TASK TRACKING:**` block before the first `##`.
3. **Docs-sync (drift)** — run `bin/bstack-doc-drift` (deterministic; standards P-2.2). It reconciles the command set on disk against every index — counts in `readme.md` / `MANIFEST.md`, the `SessionStart.sh` list, the model-tier table, and `routes.tsv` — and exits non-zero on drift. Fix only the rows it flags (disk wins); do not re-derive the comparison by hand.
4. **Routes** — every routable command has a matching row in `.claude/config/routes.tsv`; every route points to a command that exists.
5. **Prose (README pass)** — for each README/index doc, check formatting (heading levels, table alignment, code-fence languages, trailing whitespace, link targets resolve) and plain-English quality (complete sentences, no fragments, consistent tense/voice, no typos). Correct in place — preserve meaning and the terse house style; never invent facts.
6. **Report** — summarize what changed as a table (dimension → files touched → fix). With `--report-only`, list findings and stop without editing.
7. **Verify** — re-run `bin/bstack-command-lint`; it must exit clean. Re-check every count you touched.

## Hard rules

- Mechanical + prose fixes only — behavior of any command is never changed here. A behavior change routes to `/bstack:plan`.
- Never fabricate a count or a table row — every number is derived from files enumerated in this session (standards A-1.2).
- Preserve the house voice: terse, imperative, no marketing adjectives. Fix clarity, don't rewrite for taste.
- `bin/bstack-command-lint` must be green before you finish. If it can't be, surface why.
