---
name: bstack:autoplan
description: 'Auto-review pipeline for a plan — runs ceo → design (if UI) → eng → devex (if dev-facing) lenses sequentially with auto-decisions, surfacing only taste decisions at one final gate'
argument-hint: '[plan path | "latest"]'
model: opus
---

# /bstack:autoplan

> **TASK TRACKING:** Create one task per phase that runs, plus one for the final gate. Mark each complete as you go.
>
> **Use when:** a plan exists and you want the full multi-lens review without 15–30 question round-trips. For a single lens interactively, use `/bstack:plan-review --mode=<lens>`.

Runs the `/bstack:plan-review` lenses **sequentially with auto-decisions**: mechanical
questions are answered by the decision principles below and logged; only genuine taste
decisions and direction changes reach the user, batched at one final approval gate
(E-8.1 still holds — direction changes are never auto-decided).

## Auto-decision principles

Apply in order; log every auto-decision to the audit trail (never hold them in context — P-3.4):

1. **Choose completeness** — pick the approach that covers more edge cases (E-6.1).
2. **Boil lakes** — auto-approve scope expansions that fix everything in the blast radius at < 1 day effort; anything bigger is a taste decision for the gate.
3. **Pragmatic** — two options fix the same issue → pick the cleaner one, no deliberation.
4. **DRY** — reject duplicated functionality; reuse what exists (R-3.3).
5. **Explicit over clever** — a 10-line obvious fix beats a 200-line abstraction.
6. **Bias toward action** — merge > review cycles > stale deliberation.

## Phases (conditional — skip what the scope doesn't touch)

| Phase | Lens | Runs when |
|---|---|---|
| 1 | ceo | Always |
| 2 | design | Plan mentions UI scope (2+ of: screen, page, component, form, layout, UX, style, frontend) |
| 3 | eng | Always |
| 4 | devex | Plan touches developer-facing surface (2+ of: CLI, SDK, API docs, config, tooling) or the product targets developers |

## Steps

1. **Resolve input** — plan path, or `latest` = newest file in `docs/plans/`. No plan → stop, route to `/bstack:plan`.
2. **Scope detection** — scan the plan once; decide Phase 2/4 per the table. Log skipped phases with the trigger counts (no silent skips).
3. **Run each phase** — load the corresponding `/bstack:plan-review` mode checklist; resolve its BLOCKER/QUESTION items via the auto-decision principles where mechanical; queue the rest for the gate.
4. **Audit trail** — append every decision incrementally to `docs/plans/<plan-stem>-decisions.md`: `phase · finding · decision · principle # · (auto|gate)`.
5. **Final gate** — present queued taste decisions and any direction changes in one batch (decision format per command conventions). Apply the user's calls; update the plan file.
6. **Stamp the review record** — add a `## Review record` section to the plan naming the phases run and linking the audit trail. `/bstack:implement` pre-flight requires this section (E-1.8).
7. **Handoff** — `/bstack:implement <plan>`.

## Degradation rules

- A phase that errors twice is recorded `unverified` (R-7.3) in the audit trail and the pipeline continues — no retry loops (E-5.3 budget).
- If an external second-model reviewer is wired (see `/bstack:review` cross-model step), a 10-minute timeout degrades to single-model review, logged — never blocks the pipeline.

## Hard rules

- Auto-decisions never touch direction, security posture, or data safety — those always queue for the gate (E-8.1, README severity defaults).
- The audit trail is append-only during the run; it is the evidence artifact for E-1.8.
