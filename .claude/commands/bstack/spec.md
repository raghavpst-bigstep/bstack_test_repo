---
name: bstack:spec
description: 'Turn a chosen approach into a precise, executable spec — inputs, outputs, contracts, acceptance criteria. Sits between brainstorm and plan.'
argument-hint: '[feature description or path to brainstorm/office-hours doc]'
model: opus
---

# /bstack:spec

> **TASK TRACKING:** Create one task per phase. Mark each complete as you go.

Sits **between `/bstack:brainstorm` and `/bstack:plan`**. Brainstorm picks the approach; spec nails down the exact contract so the plan can be decomposed into tasks with no ambiguity. A precise spec makes the plan smaller and the review sharper.

Output: `docs/specs/YYYY-MM-DD-<topic>-spec.md`. The spec is the input to `/bstack:plan`.

## MCP usage

| MCP | When | What for |
|---|---|---|
| context7 | Library/framework involved | `resolve-library-id` → `query-docs` to pin exact API shapes the spec depends on |
| Notion | Always | `notion-search` for an existing spec or ADR on this surface |
| Linear | Always | Link the tracking ticket the spec belongs to |

## Phases

1. **Intent** — resolve the input. If `arg` is a brainstorm/office-hours path, load it and carry the chosen approach forward. Otherwise restate the goal in one paragraph and confirm the approach before specifying. State the **one** sentence of success: "this is done when ___."
2. **Context & constraints** — read `docs/solutions/INDEX.md`, the relevant per-app `CLAUDE.md`, and `.claude/rules/critical-patterns.md`. Identify affected apps/libs, DDD boundary crossings, and any new `libs/api-interfaces` types. List the hard constraints the spec must satisfy (auth model, performance budget, data invariants).
3. **Behavior** — the precise contract. For each behavior:
   - **Inputs** — exact shape, types, validation rules (server-side, per §7.1).
   - **Outputs** — exact shape, status codes, side effects (DB writes, queued jobs, emitted events).
   - **Edge cases & error paths** — empty, max, concurrent, unauthorized, partial-failure. Boil the lake (Ethos #1) — enumerate them now, they cost seconds.
   - **Authorization** — who may call this, checked against the current user at the action site (§6.3 / §6.4). This is the one contract you never leave implicit.
4. **Acceptance criteria** — testable Given/When/Then assertions, one per behavior and one per edge case. Include the IDOR-negative test ("user A cannot reach user B's record") explicitly. These rows become the unit-test table in `/bstack:plan` and the checklist in `/bstack:review`.
5. **Write the spec** to `docs/specs/YYYY-MM-DD-<topic>-spec.md` — sections: Goal · Approach · Constraints · Behavior (contracts) · Acceptance criteria · Out of scope · Open questions. Then **handoff**: `/bstack:plan <this-spec-path>`.

## Conventions

- A spec describes **behavior and contracts, not implementation** — no file names, no function signatures. Those belong to `/bstack:plan`.
- Every behavior carries its authorization rule and its error paths. A spec without error paths is a happy-path sketch, not a spec.
- "Out of scope" is required — name what this spec deliberately does not cover so the plan doesn't quietly expand (oceans get an ADR, not silent scope creep — Ethos #1).
- If a contract changes a system boundary or domain interface, note "ADR needed" — `/bstack:plan` will draft it.
