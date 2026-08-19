---
name: bstack:health
description: 'Code quality dashboard — typecheck, lint, tests, dead code, dependency staleness, doc freshness — with trend tracking against the last run'
argument-hint: '[--scope=<app|lib|repo>]'
model: sonnet
---

# /bstack:health

> **TASK TRACKING:** Create one task per health dimension. Mark each complete as you go.
>
> **Use when:** you want a snapshot of code quality and whether it's trending better or worse. Read-only — fixes route to `/bstack:plan` or `/bstack:refactor`.

## Steps

1. **Scope** — one project or the repo. Resolve the runners from the build-system adapter (`nx` here; fall back to package scripts).
2. **Collect (deterministic, parallel where possible)**
   - typecheck: error/warning counts
   - lint: error/warning counts (are warnings gated? — E-9.1)
   - tests: pass/fail/skip counts, duration, quarantined count (T-6.4)
   - coverage: changed-code and total, vs the Manifest floor (T-5.1)
   - dead surface: unused exports/files where tooling exists
   - dependency staleness: majors behind, known CVEs (A-2.7)
   - doc freshness: last-verified dates vs review windows (A §5)
   - command drift: `bin/bstack-command-lint`
3. **Score** — per dimension: OK / WARN / FAIL against Manifest budgets; no invented metrics — a dimension without tooling is reported `unverified` (R-7.3), not guessed.
4. **Trend** — diff against the previous report in `docs/health/`; call out any dimension that moved.
5. **Report** — write `docs/health/YYYY-MM-DD-health.md`: dimension table, trend arrows, top 3 actions. FAIL dimensions each get a tracker ticket (E-6.4).

## Hard rules

- Read-only: this command changes no code.
- Every number comes from a tool run in this session — never from memory (A-1.2).
