---
name: bstack-improve
description: >
  Self-maintenance for the bstack toolkit. Reads every command, skill, agent,
  and doc; checks structure, lint, index drift, and README prose; then applies
  mechanical + prose corrections. Keeps the toolkit consistent with itself.
  Invoked by /bstack:improve. Does NOT change command behavior or app code.
version: 1
last_reviewed: 2026-08-03
applies_to: ".claude/**, docs/**, readme.md, MANIFEST.md, bin/README.md"
triggers:
  - improve bstack
  - audit bstack commands
  - fix bstack docs
  - readme cleanup
  - lint the commands
  - keep bstack in sync
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
---

# bstack-improve — Toolkit Self-Maintenance

bstack is a hand-maintained set of ~38 command preambles, skills, agents, and index
docs. Hand-maintained files drift: a command is added but the count in `readme.md`
never moves; a model tier disagrees with the table; a README sentence is a fragment.
This skill is the janitor that keeps the toolkit honest. It is invoked by
`/bstack:improve` and runs at the **sonnet** tier (procedural audit + mechanical
fixes — bounded judgment).

## Scope boundary

- **In scope:** `.claude/commands/bstack/*.md`, `.claude/skills/*/SKILL.md`,
  `.claude/agents/*.md`, `.claude/config/*`, `.claude/overlays/*`,
  `.claude/hooks/*`, and the doc/index set (`readme.md`, `MANIFEST.md`,
  `docs/**`, `bin/README.md`).
- **Out of scope:** the consuming application's source, tests, and behavior — those
  go through `/bstack:review`, `/bstack:health`, or `/bstack:plan`. This skill never
  edits app code and never changes what a command *does*, only how consistently it
  is described.

## The five audit dimensions

Run one task per dimension; do them in this order because later ones depend on the
inventory from the first.

### 1. Inventory (read everything)

Enumerate the files above and read them. They are individually small — reading the
whole surface is cheap relative to guessing at drift. Build an in-session list of
`{command → file, model tier, has-task-tracking, categories it appears in}`.

### 2. Structure + lint

Run the deterministic checker:

```bash
bin/bstack-command-lint
```

It enforces, per command: `name` == `bstack:<stem>`, non-empty `description`, a model
tier in `{haiku, sonnet, opus}`, a `> **TASK TRACKING:**` block before the first `##`,
and that every referenced `bin/…` or `.claude/…` path exists. Fix any FAIL, then
re-run until clean. Never edit a command just to silence the linter if the fix would
change behavior — flag it instead.

### 3. Index / drift sync

Run the deterministic checker first — do not compare the indexes by eye (standards P-2.2):

```bash
bin/bstack-doc-drift
```

It reconciles the command set on disk against every index and exits non-zero on drift.
Fix only the rows it flags. The same command list is written down in five places, which
is what it checks:

| Source of truth | Consumers that must match it |
|---|---|
| files in `.claude/commands/bstack/` | `readme.md` count + category tables |
|   | `MANIFEST.md` count + category tables |
|   | `.claude/hooks/SessionStart.sh` command list |
|   | model-tier table in `.claude/config/command-conventions.md` |
|   | routable rows in `.claude/config/routes.tsv` |

A command present on disk but missing from any index (or listed in an index but
absent on disk) is drift. Correct the index — the files on disk are authoritative.
Recompute every count from the actual file list; never carry a stale number forward.

### 4. Routes

Every command that a user could reach from a plain-English prompt has a row in
`routes.tsv`; every route target names a command that exists. Add a missing row using
the existing ERE-pattern style (most-specific-first ordering). Toggles and pure
utilities (freeze, unfreeze, careful, context) may legitimately have no route.

### 5. Prose (the README pass)

For each README / index doc, check two things:

- **Format:** heading levels nest correctly, tables align and have matching column
  counts, code fences declare a language, no trailing whitespace, links resolve to a
  real file/anchor.
- **Plain English:** complete sentences (no fragments where prose is intended),
  consistent tense and voice, correct grammar, no typos, no duplicated words.

Correct in place. Preserve meaning and the terse, imperative house style. Never add
marketing adjectives, never invent capabilities, never rewrite for personal taste —
this is copy-editing, not authoring.

## Output

A change table: `dimension | files touched | what was fixed`. With `--report-only`,
list findings and stop. Always finish with a clean `bin/bstack-command-lint` run and
a re-verification of any count you changed.

## Hard rules

1. Mechanical + prose only. Behavior changes route to `/bstack:plan`.
2. Every count/table entry is derived from files read this session (A-1.2) — no memory.
3. `bin/bstack-command-lint` is green before you finish, or you explain why it can't be.
4. House voice preserved: terse, imperative, factual.
