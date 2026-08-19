# R.I.C.E. Feature Protocol

A generic, stack-agnostic architect protocol that runs **before any new feature is written**. The agent stops, asks four questions (one per R.I.C.E. letter), and only after the answers are captured does it explore code or plan implementation. The protocol's per-project SKILL.md holds the locked stack, forbidden list, and non-negotiable Enforcement rules — so every plan and diff carries the same DNA without re-deriving it from chat history.

This directory ships:

- `SKILL.template.md` — the authoritative R.I.C.E. shape with `[BRACKETED]` placeholders. Never edit this in place; derive a project copy via `/bstack:rice-init`.
- (after `/bstack:rice-init` runs) `SKILL.md` at the repo root, with optional per-app `apps/<name>/.claude/skills/<app>-feature-protocol/SKILL.md` files that `extends:` the root.

## The four sections

| Letter | Section | What it pins |
|---|---|---|
| **R** | Role | The architect persona, framework lock-ins, runtime floor, lifecycle and safety rules. |
| **I** | Intent | What "correct" means by default — rule-ID traceability, authz, type safety, a11y/i18n floor, evidence (tests). |
| **C** | Context | Workflow summary, **locked stack table** (the libraries that don't change without a doc update), folder layout, source of truth, domain rule cheat-sheet, forbidden list. |
| **E** | Enforcement | Numbered invariants every new-feature diff must show. Reviewer checks against these. |

## The four-question gate

On activation the agent asks one question per letter, in order. Each accepts `use default` (fall back to the SKILL.md section) or **extras**, which are treated as **additive** and called out explicitly in the plan under the matching R / I / C / E heading. The agent does not read files, explore code, or launch agents until all four are answered (or `use default` four times).

## New-feature-only scope

R.I.C.E. fires on **new** work — new screen / feature / endpoint / component / service / hook / repository. For modifications to existing code, match that file's local patterns unless the task explicitly migrates it. The `routes.tsv` pattern that auto-invokes `/bstack:rice` matches on the word `new` for this reason.

## Inheritance (polyglot monorepos)

`SKILL.md` frontmatter supports `extends: <relative path>` and `applies_to: <glob>`. The CLI (`bin/bstack-rice path <file>`) walks up from a touched file, finds the most-specific matching SKILL.md, and chains it back through `extends:` to a base. At runtime, per-app overrides win on conflicts; Forbidden lists are **unioned** (subtractive bans accumulate, never subtract).

Typical layout for an Nx monorepo:

```
.claude/skills/feature-protocol/SKILL.md                          # base (cross-cutting Enforcement)
apps/web/.claude/skills/web-feature-protocol/SKILL.md             # extends: ../../../../.claude/skills/feature-protocol/SKILL.md
apps/api/.claude/skills/api-feature-protocol/SKILL.md
apps/ai-service/.claude/skills/ai-service-feature-protocol/SKILL.md
```

## Drift detection

Each SKILL.md carries `version` and `last_reviewed` frontmatter. `bin/bstack-rice validate`:

- **Hard fails** when required sections are missing or `[BRACKETED]` placeholders are left in.
- **Warns** when `last_reviewed` is more than 120 days old, or when the locked-stack table is empty.
- Exits 0 on warnings, non-zero on hard fails. Use it in CI as advisory; the reviewer makes the call on new deps not yet in the locked-stack table.

## Backport

The kiosk (`SmartWorksKioskApp`) and Gallant (`Gallant Sports ERP`) repos already have hand-rolled feature protocols predating this generic. Use `bin/bstack-rice diff <existing-SKILL.md>` to see what the generic template would add or remove — adopt at the project's own pace; no forced migration.
