---
name: bstack:refactor
description: 'Guided refactor — scope, characterization tests, refactor in small steps, verify each step green'
argument-hint: '[file/path or "what" you want to refactor]'
model: opus
---

# /bstack:refactor

> **TASK TRACKING:** Create one task per refactor step. Mark each green test pass complete.

Safe behavior-preserving change. Never mix refactor + feature change in one pass.

## Steps

1. **Scope** — exactly which files / functions / modules. If user says "the auth module", list every file you'd touch and confirm.
2. **Why** — one sentence: what's better after this. If you can't say it crisply, refactor isn't ready.
3. **Characterization tests** — if existing test coverage is thin, write tests that lock current behavior FIRST. These tests should pass before any change.
4. **Plan the steps** — break into 5–10 tiny refactors, each green-to-green. Save to `docs/refactors/YYYY-MM-DD-<topic>.md`.
5. **Execute one step at a time** — after each: run affected tests (`nx affected --target=test --base=HEAD~1`); if red, stop and fix or revert.
6. **DDD boundary check** — at the end, run `ddd-boundary-enforcer` agent on the diff.
7. **Migration check** — if any migration touched, run `kysely-migration-validator`.
8. **Diff size** — refactor PR > 600 lines diff = split. PR description must say "behavior-preserving refactor; no feature change."
9. **Handoff** — `/bstack:ship` to PR.

## MCP usage

| MCP | When | What for |
|---|---|---|
| context7 | Library API in question | Verify modern signature before changing usage |

## Hard rules

- No feature change. No API change. No behavior change. If those happen, this becomes `/bstack:plan` + `/bstack:implement`.
- Tests pass at every step. If you can't get green between steps, the step is too big.
- No "while we're at it" reformat sweeps — keep the diff to the actual refactor.
