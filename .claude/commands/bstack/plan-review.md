---
name: bstack:plan-review
description: 'Review a plan or brainstorm doc from one of four perspectives: ceo | eng | design | devex. Returns must-fix issues and questions to answer before implementation.'
argument-hint: '[--mode=ceo|eng|design|devex] [path-to-doc, or "latest"]'
model: opus
---

# /bstack:plan-review

> **TASK TRACKING:** Create one task per numbered finding. Mark each as Addressed / Deferred / Won't-do with a one-line rationale.

Apply a specific lens to a plan or brainstorm BEFORE implementation. Default `--mode=eng`.

## Resolve input

- Doc path arg → use it.
- `latest` → newest file in `docs/plans/` then `docs/brainstorms/`.
- Nothing → ask.

## Mode lenses

### `--mode=ceo`

- What's the wedge? Is there a smaller version that ships in days, not weeks?
- Who is the user? Recent concrete example of the pain?
- What does success look like — measurable, by when?
- What's the cheapest experiment to kill this if wrong?
- Build-vs-buy? Why not a vendor?
- Distribution: how do users find / adopt it?

### `--mode=eng`

- Auth: every endpoint declares a required role? Object access authorized per user?
- DDD: any new cross-app imports? Shared types in `api-interfaces`?
- Data: migration reversible? Locking strategy for large tables? Rollback path?
- Async context: propagated through Temporal, SQS, queues?
- Rollout: feature-flagged? Reversible?
- Observability: logs, metrics, alerts named upfront?
- Tests: characterization + new + integration plan?

### `--mode=design`

- User story is one sentence?
- Empty states, loading states, error states named?
- Mobile? a11y? Internationalization?
- Brand alignment — theme tokens only, no rogue hex?
- Hierarchy: primary action unambiguous?
- AI-slop check — generic gradients, rounded-everything, lorem-ipsum-shaped copy?

### `--mode=devex`

- Local stack: does this break `npm run local`? Adds a new dep that needs `setup` updates?
- Onboarding: any new env var? Documented?
- Test ergonomics: can a new dev run the new tests in < 30 s on a clean checkout?
- Editor support: types exposed, TS paths configured, lint clean?
- Failure modes: is the error path clear to a future debugger?

## Output

For each finding:

```
### [BLOCKER | QUESTION | NICE-TO-HAVE] [Title]
**Lens:** <mode>
**Where in doc:** section name
**Reason:** one sentence
**Suggested change:** specific edit to the plan
```

BLOCKER = answer / fix before implementation.
QUESTION = open question that needs a decision from a named human.
NICE-TO-HAVE = follow-up after first ship.

## MCP usage

| MCP | When | What for |
|---|---|---|
| Linear | Always | Cross-reference the driving ticket; flag scope drift |
| Notion | If ADR linked | Verify alignment with the ADR |
| context7 | Plan involves libraries | Verify named libraries are current |

## Hard rules

- Do not rewrite the plan — surface findings, let the planner decide.
- If `--mode` is omitted, default to `eng` and tell the user (so they can re-run with another mode).
