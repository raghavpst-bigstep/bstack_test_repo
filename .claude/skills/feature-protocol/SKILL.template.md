<!-- bstack:template — do not edit in place. Use `/bstack:rice-init` to derive a project copy. -->
---
name: [repo-name]-feature-protocol
description: >
  R.I.C.E. protocol for new feature work on [PROJECT NAME] ([SHORT STACK SUMMARY]).
  Invoke at the START of any new [UNITS OF WORK] under `[PRIMARY SOURCE DIR]/`.
  For code reviews, use `/bstack:review` instead.
version: 1
last_reviewed: [YYYY-MM-DD]
applies_to: "[GLOB e.g. apps/web/** or src/**]"
extends: "[OPTIONAL relative path to a parent SKILL.md — e.g. ../../../.claude/skills/feature-protocol/SKILL.md]"
triggers:
  - new screen
  - new feature
  - new endpoint
  - new component
  - new hook
  - new service
  - new repository
  - new module
---

# [PROJECT NAME] Feature Architect Protocol — R.I.C.E.

For **new** screens, features, endpoints, and shared infra under `[PRIMARY SOURCE DIR]/`. When touching **existing** code, match that file's established patterns unless the task explicitly migrates it. For **reviews**, use `/bstack:review`.

[ONE-PARAGRAPH ORIENTATION: what this project/app is, who uses it, the non-obvious constraint. The [SOURCE OF TRUTH] is the law; the locked stack and rule IDs are non-negotiable.]

## On Activation — Ask Four Questions First

**STOP. Do not read any files, explore the codebase, or launch any agents yet.**

Ask the user **four separate questions** — one per R.I.C.E. item, in order. Each is optional and defaults to the section below. Wait for each answer. Each accepts **"use default"**.

1. **R — Role:** "Any extra constraints on the architect role? (e.g. *[LENS 1]*, *[LENS 2]*) — or **'use default'**."
2. **I — Intent:** "Any extra acceptance criteria? (e.g. *[CRITERION]*, *feature flag*, *role visibility*) — or **'use default'**."
3. **C — Context:** "Any extra context to load? (e.g. *[RELATED DOC]*, *[DESIGN ARTIFACT]*) — or **'use default'**."
4. **E — Enforcement:** "Any extra non-negotiables? (e.g. *no new [HEAVY DEPENDENCY]*, *must add [VALIDATION]*) — or **'use default'**."

For any field answered **"use default"**, fall back to the section below. For extras, treat them as **additive** and call them out explicitly in the plan under the matching R / I / C / E heading.

Skip a question only when the user has already supplied that field in the same turn. Skip all four only when the user has explicitly said so.

## Role

[ARCHITECT PERSONA — e.g. "Senior [STACK] Tech Architect for [DOMAIN]"]. Boundaries:

- [BOUNDARY 1 — workflow / framework lock-in, e.g. "Expo Bare only — never Expo Managed".]
- [BOUNDARY 2 — data flow / state direction, e.g. "Unidirectional: screens read from store; writes go through repositories."]
- [BOUNDARY 3 — role / scope limits, e.g. "Mobile-only roles X, Y, Z. Never propose mobile UI for web-only roles."]
- [BOUNDARY 4 — runtime floor, e.g. "Android 9+, iOS 14+. No APIs that exclude these."]
- [BOUNDARY 5 — lifecycle / leak rules, e.g. "Camera / GPS / voice subscriptions bounded by useFocusEffect + AppState."]
- [BOUNDARY 6 — offline / network rules, e.g. "Every write persists locally first, then syncs. Never gate a user action on connectivity."]

## Intent

A change is **correct** only if verifiable against the task. By default, also satisfy:

- **[RULE-ID TRACEABILITY]** — if the feature enforces a domain rule, the rule ID appears in code comments and test names (e.g. `// W1: no skip steps`). Reviewers must be able to grep from rule to code.
- **[AUTHZ / ROLE GATING]** — the feature is wired into the correct role boundary and only that boundary. Repository / service calls assert role / tenant before fetching.
- **[OFFLINE / RESILIENCE PATH]** — [if applicable: new mutations queue locally when offline; new queries serve from cache; UI surfaces sync state.]
- **[STATELESS UI / SEPARATION]** — UI reads from selectors / hooks; it does not own server state or business state.
- **[TYPE SAFETY]** — TS strict / mypy / equivalent; schema validation at every API boundary; no `any` / `interface{}` / unsafe casts without an explicit, reviewed comment.
- **[A11Y / I18N FLOOR]** — [if applicable: all user-visible strings via i18n; minimum interactive font 16; touch targets ≥ 44×44.]
- **[EVIDENCE]** — at least one render / smoke test; non-trivial logic gets a unit test; risky flows get an E2E note (even if implementation is deferred).

## Context

**Workflow:** [BUILD/RUN/DEPLOY toolchain — e.g. "Expo Bare + EAS Build/Update", "Nx + npm + Vercel", "FastAPI + Temporal + Docker", "Gradle + Play Console".]

**Stack (locked, do not swap without re-reading [SOURCE OF TRUTH]):**

| Concern | Library | Notes |
|---|---|---|
| [UI] | [LIBRARY] | [Constraint] |
| [Client state] | [LIBRARY] | [Pattern] |
| [Server cache] | [LIBRARY] | [Wrapping rule] |
| [Forms / validation] | [LIBRARY] | [Schema source] |
| [Local DB / storage] | [LIBRARY] | [Encryption / migration rule] |
| [HTTP / RPC] | [LIBRARY] | [Interceptors / auth rule] |
| [Observability] | [LIBRARY] | [Logger wrapper — no `console.*` / `print()` / `fmt.Println`] |
| [...] | [...] | [...] |

**Folder layout:**

```
[paste the project's canonical folder map here]
```

[OPTIONAL: layered architecture statement, e.g. `Presentation → State → Domain → Data → Platform → Cross-cutting`, downward dependencies only.]

**Design / API source of truth:** [PATH or LINK]. Mirror these primitives — do not re-invent:
[`Primitive1`, `Primitive2`, ...]

**Domain rule cheat-sheet** ([SOURCE OF TRUTH] §[N]):

- **[NAMESPACE-1]** [short description of category — e.g. "workflow gates, block at API + UI"].
- **[NAMESPACE-2]** [...]
- **[NAMESPACE-3]** [...]

**Forbidden / avoid:**

- [DRIFT PATTERN 1 — one line per common past-PR failure mode.]
- [DRIFT PATTERN 2 — e.g. `console.log` in committed code.]
- [DRIFT PATTERN 3 — e.g. hardcoded user-visible strings.]
- [DRIFT PATTERN 4 — e.g. direct DB driver use, bypass of repository.]
- [DRIFT PATTERN 5 — e.g. unbounded subscriptions outside lifecycle hooks.]
- [DRIFT PATTERN 6 — e.g. mobile UI for web-only roles.]
- [DRIFT PATTERN 7 — e.g. blocking the user on network.]
- [...]

## Enforcement (non-negotiable for new features)

Numbered invariants every new-feature diff must show:

1. **[INVARIANT 1]** — [precise rule, e.g. "Every mutation persists locally before any network call."]
2. **[INVARIANT 2]** — [e.g. "Photo / video uploads route through the sync queue with netinfo tiering."]
3. **[INVARIANT 3]** — [e.g. "Camera evidence uses [LIBRARY] only — gallery picker rejected on [GATED SURFACES]."]
4. **[INVARIANT 4]** — [e.g. "Role gating: screens declared in exactly one role stack; repo asserts role from JWT."]
5. **[INVARIANT 5]** — [e.g. "Rule ID traceability — `// W1`, `// V4`, `// G3` in code comments and test names."]
6. **[INVARIANT 6]** — [e.g. "i18n + a11y floor — every user-visible string from i18n; min interactive font 16; touch targets ≥ 44×44."]
7. **[INVARIANT 7]** — [e.g. "Error shape — Result<T, E> or thrown into TanStack Query boundary; never silent try/catch."]
8. **[INVARIANT 8]** — [e.g. "Background work registered centrally, idempotent, time-bounded, instrumented."]
9. **[INVARIANT 9]** — [e.g. "Native module changes call out Android + iOS impact, EAS Build downtime, Dev Client rebuild needed?"]
10. **[INVARIANT 10]** — [...]

## Suggestions (apply when they fit)

- Mirror an existing feature folder before inventing a new structure. Consistency > novelty.
- Extend an existing design-system / API primitive before creating a new one — re-invention is the most common review reject.
- [PROJECT-SPECIFIC sanity command — e.g. `yarn tsc --noEmit && yarn lint && yarn test`, `nx affected -t test lint typecheck`, `pytest && ruff check && mypy`.]
- [PROJECT-SPECIFIC conflict / partial-failure default — e.g. "server wins; non-blocking toast for the user".]
- [PROJECT-SPECIFIC weak-area call-out — e.g. "iOS note:" for changes the team has weaker intuition on.]
- When in doubt: re-read the relevant [SOURCE OF TRUTH] section. Plan and source-of-truth disagreements: **source of truth wins**.
