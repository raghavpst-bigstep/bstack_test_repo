---
name: bstack:compound
description: "5. Document a recently solved problem so the next occurrence takes minutes — duplicate-aware, pattern-promoting"
argument-hint: '[optional: brief context about the fix]'
model: sonnet
---

# /bstack:compound

> **TASK TRACKING:** Create one task per numbered step. The command is NOT done until the doc is committed AND any pattern promotion is filed.

Capture a fresh solution into `docs/solutions/`. Knowledge compounds — first solve takes hours, next takes minutes.

## When to invoke

- Multi-step debugging that worked
- A non-obvious fix that surprised the team
- Phrases like "that worked", "fixed now", "finally" in the conversation
- After any `/bstack:debug` or `/bstack:hotfix` that lands

## Steps

1. **Reconstruct the fix** — from recent edits + the conversation. Identify: problem, root cause, fix, why-this-works.
2. **Duplicate check** — `bin/bstack-solutions search "<keywords>"`. If a near-match exists, **update it** instead of writing new. Stop and confirm with user before overwriting.
3. **Classify** — solution category (auth, data, frontend, infra, AI, perf, observability). Choose folder under `docs/solutions/<category>/`.
4. **Write the doc** with YAML frontmatter:
   ```yaml
   title: <one-line>
   category: <category>
   tags: [<keywords>]
   added: YYYY-MM-DD
   problem-time-to-fix: <approx>
   ```
   Sections: Symptom · Root cause · Fix · Why it works · Detection (logs / signals next time) · Related solutions.
5. **Pattern promotion** — if this is the 2nd+ occurrence of a pattern, append it to `.claude/rules/critical-patterns.md`.
6. **Update INDEX** — run `bin/bstack-solutions index` to regenerate `docs/solutions/INDEX.md` from frontmatter (deterministic — never hand-edit the index).
7. **Post-action** — Slack the team, link from the Linear ticket / GitHub PR if applicable.

## Conventions

- One solution per file.
- Always link the Linear ticket, PR, and Datadog trace (if runtime bug).
- If the fix touches a system contract, write an ADR via `/bstack:plan` later — note "ADR needed" in the doc.
