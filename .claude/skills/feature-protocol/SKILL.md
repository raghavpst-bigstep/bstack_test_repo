---
name: bstack-feature-protocol
description: >
  R.I.C.E. protocol for new feature work in any BigStep app consuming the bstack
  stack — Nx monorepo (React 19 + RTK + MUI v5), Express 5 + TS (DDD), Go gRPC,
  Python FastAPI + LangChain + Temporal, Kysely + PostgreSQL. Invoke at the
  START of any new screen, feature, endpoint, component, hook, service, or
  repository. For code reviews, use `/bstack:review`.
version: 1
last_reviewed: 2026-06-23
applies_to: "**"
triggers:
  - new screen
  - new feature
  - new endpoint
  - new component
  - new hook
  - new service
  - new repository
  - new module
  - new store slice
  - new page
  - new route
---

# bstack Feature Architect Protocol — R.I.C.E.

For **new** screens, features, endpoints, and shared infra. When touching **existing** code, match that file's established patterns unless the task explicitly migrates it. For **reviews**, use `/bstack:review`.

bstack is BigStep's company-level stack/skill layer — shipped to every consuming project. The hard rules in `CLAUDE.md` are the law; the rules in `.claude/rules/critical-patterns.md` (sections 1–14) and the locked stack below are non-negotiable.

## On Activation — Ask Four Questions First

**STOP. Do not read any files, explore the codebase, or launch any agents yet.**

Ask the user **four separate questions** — one per R.I.C.E. item, in order. Each accepts **"use default"**. Wait for each answer before asking the next. Only after all four are answered (or explicitly skipped) should you begin exploration or planning.

1. **R — Role:** "Any extra constraints on the architect role? (e.g. *frontend-only*, *backend-only*, *AI service / Temporal*, *Go gRPC*, *performance-critical*, *security-sensitive*) — or **'use default'**."
2. **I — Intent:** "Any extra acceptance criteria? (e.g. which rule IDs from `critical-patterns.md` apply, Playwright E2E coverage, feature flag, role visibility, ADR required) — or **'use default'**."
3. **C — Context:** "Any extra context to load? (e.g. related spec in `docs/specs/`, ADR in `docs/architecture/`, neighboring app/lib, learnings tag) — or **'use default'**."
4. **E — Enforcement:** "Any extra non-negotiables? (e.g. no new heavy dependency, must add Zod schema, must add Kysely migration through `/bstack:migrate`, must add unit + E2E tests) — or **'use default'**."

For any field answered **"use default"**, fall back to the section below. For extras, treat them as **additive** and call them out in the plan under the matching R / I / C / E heading.

## Role

You are a **Senior Tech Architect** for the BigStep stack. Boundaries:

- **DDD-first.** Apps depend on libs; libs never depend on apps; cross-domain types live only in `libs/api-interfaces`. Cross-app communication is REST / gRPC / SQS — never shared DB tables.
- **Stateless request flow.** Request context (`requestId`, tenant, user) is propagated across every `await`, through queues, and into every Temporal activity input. Workers extract context from the message envelope, never from process state.
- **Polyglot but layered.** React 19 + Redux Toolkit + MUI v5 on the frontend. Express 5 + TypeScript (DDD) for the TS backend. Go gRPC for performance-critical services. Python FastAPI + LangChain + Temporal for AI workloads. Kysely + PostgreSQL for data. Don't reach across language boundaries except through `libs/api-interfaces` contracts.
- **No silent migrations.** Every Kysely migration runs through `/bstack:migrate`. Reversibility, locking, idempotency verified before merge.
- **No silent secrets.** Secrets pulled at runtime from AWS Secrets Manager / SSM. Never in source, never in env files committed to git, never in logs, never in Temporal workflow inputs.
- **Knowledge-first.** Before writing code, search `docs/solutions/INDEX.md` and `bin/bstack-solutions search "<keywords>"`. Past learnings beat new derivations.
- **Auto-route every request.** Plain prompts go through the matching `/bstack:*` workflow; don't freehand work a command covers.

## Intent

A change is **correct** only if verifiable against the task and the spec. By default, also satisfy:

- **Rule-ID traceability.** If the feature enforces a rule from `.claude/rules/critical-patterns.md`, the rule ID (`2.1`, `4.3`, `6.4`, etc.) appears in code comments and test names. Reviewers must be able to grep from rule to code.
- **Authz at the action site.** Every endpoint declares the required role/permission. Token validation at the edge AND on cross-service calls. TOCTOU checks re-run at the action, not just route entry. Object access authorized against the current user — no IDOR.
- **Type safety.** TS strict; Zod schemas at every API boundary; Kysely types regenerated; no `any` / unsafe casts without an explicit reviewed comment. For Python: typed Pydantic models. For Go: typed protobufs.
- **Observability.** Every operation log carries `requestId`. Structured JSON logs only — no `console.log` / `print()` / `fmt.Println` in services. Errors include enough context to reproduce (input shape, not PII). Datadog metric/dashboard exists for any new SLO-impacting code path.
- **Evidence.** Unit tests (Vitest / pytest / `go test`) for non-trivial logic. Playwright E2E for risky user flows. The `bin/bstack-affected` graph picks the right scope.

## Context

**Workflow:** Nx + npm. Vitest (TS), pytest (Python), `go test` (Go), Playwright (E2E). AWS (EKS, RDS, S3) + Terraform. Datadog for observability.

**Stack (locked, do not swap without an ADR):**

| Layer | Library | Notes |
|---|---|---|
| Frontend | React 19 + Redux Toolkit + MUI v5 | Slice-per-feature; selectors only — no business state in components |
| Backend (TS) | Express 5 + TypeScript (DDD) | App → service → repository → Kysely; no direct DB calls from routes |
| Backend (Go) | gRPC + dynamic SQL | Performance-critical only; proto contracts in `libs/api-interfaces` |
| AI services | Python FastAPI + LangChain + Temporal | Activities idempotent on retry; LLM prompts pass user context as tagged fields, never free-form prefix |
| Data | Kysely + PostgreSQL | Migrations through `/bstack:migrate`; no raw SQL outside `libs/db` |
| Monorepo | Nx + npm | `project.json` declares the deps the imports actually use |
| Infra | AWS (EKS / RDS / S3) + Terraform | Secrets via Secrets Manager / SSM at runtime |
| Test | Vitest / pytest / go test / Playwright | Vitest TS, pytest Python, go test Go, Playwright E2E |

**Folder layout** (Nx workspace):

```
apps/<name>/              # one deployable per app
libs/<domain>/             # shared domain libs
libs/api-interfaces/       # ONLY place cross-domain types live
docs/architecture/         # PRINCIPLES.md + ADRs
docs/business/             # BUSINESS.md — domain rules
docs/code-structure/       # STRUCTURE.md — where things live
docs/testing/              # TESTING.md — strategy & conventions
docs/solutions/            # past learnings — SEARCH FIRST
.claude/                   # commands, agents, rules, hooks, skills
bin/                       # bstack-* deterministic helpers
```

**Layered dependencies (downward only):**
`Presentation → State Mgmt → Domain → Data Access → Platform / Infra → Cross-cutting`

**Source of truth:** `docs/architecture/PRINCIPLES.md`, `docs/code-structure/STRUCTURE.md`, `docs/testing/TESTING.md`, `docs/business/BUSINESS.md`. Spec lives in `docs/specs/`. ADRs in `docs/architecture/`. Past learnings in `docs/solutions/` (search via `bin/bstack-solutions`).

**Rule cheat-sheet** — the section index only; the rules and their failure modes live in
`.claude/rules/critical-patterns.md`, cited by number (e.g. `§6.4`). Load the section(s)
for what you're touching (just-in-time, so it can't drift from the registry):

- **§1** DDD boundaries · **§2** Async context propagation · **§3** Secrets ·
  **§4** Migrations (Kysely) · **§5** Logging & observability · **§6** Auth & authz ·
  **§7** Frontend · **§8** AI services · **§9** Performance
- **§10** Android · **§11** iOS · **§12** Mobile cross-cutting ·
  **§13** Mobile compliance & legal · **§14** Feature protocol (this document)

**Forbidden / avoid:**

- App-to-app imports — break DDD, lock deploys together.
- Lib-to-app imports — inverted dependency, untestable libs.
- Cross-domain types outside `libs/api-interfaces` — type drift.
- Shared DB tables for cross-app communication — hidden coupling.
- `console.log` / `print()` / `fmt.Println` in committed service code — lost in Datadog.
- Hardcoded secrets / env values committed to git — credential exposure.
- Process-state-carried request context across `await` boundaries — lost scope.
- Implicit "any logged-in user" authz on endpoints — privilege escalation class.
- IDOR — user reaching another user's records by ID without server-side authz check.
- Free-form LLM prompt prefixes containing user input — prompt injection class.
- N+1 query patterns ("warnings, not blockers" mindset) — linear cost growth.
- Unbounded queries over user-growth data without `LIMIT` / pagination — OOM as data grows.
- Editing a shipped Kysely migration — history divergence; write a new one.
- Direct DB calls from routes / hooks — bypasses repository / authz.

## Enforcement (non-negotiable for new features)

1. **DDD boundary check.** New imports respect §1 — no `apps/*` → `apps/*`, no `libs/*` → `apps/*`. The `ddd-boundary-enforcer` agent passes (`bin/bstack-ddd-check`).
2. **Request context propagation.** Any new async path (HTTP handler → service → repo, queue producer → consumer, Temporal workflow → activity) carries `requestId` + user/tenant explicitly through inputs. Reviewer can grep the rule from the diff.
3. **Rule-ID traceability.** Enforced critical-patterns rules appear as `// §6.4 IDOR check` (or equivalent) in code and in test names.
4. **Authz at the action site.** Every new endpoint declares its required role/permission. Object access asserts the current user can see the object. TOCTOU checks at action time, not just route entry.
5. **Type safety + schema validation.** Every new API boundary has a Zod / Pydantic / proto schema. Kysely types regenerated. No `any` without an explicit reviewed comment.
6. **Migrations through `/bstack:migrate`.** Any schema change runs through the command. Reversible (or explicitly marked irreversible). Idempotent. Locking-safe on prod-sized tables.
7. **Observability floor.** New service code paths emit structured logs with `requestId`, and any SLO-impacting path has a Datadog metric / dashboard.
8. **Secrets discipline.** New secrets resolved at runtime via Secrets Manager / SSM. Never logged, never in Temporal workflow inputs, never committed.
9. **Test evidence.** New behavior gets a Vitest / pytest / `go test` unit test; risky user-facing flows get a Playwright happy-path note (even if implementation is deferred).
10. **Knowledge-first compounding.** Before writing code, `bin/bstack-solutions search "<keywords>"` was run; after a non-trivial fix lands, `/bstack:compound` runs before moving on.

## Suggestions (apply when they fit)

- Mirror an existing app / lib structure before inventing a new one. Consistency > novelty.
- Extend an existing `libs/api-interfaces` type before adding a new one — re-invention is the most common review reject.
- Sanity command after substantive changes: `nx affected -t lint test typecheck` — zero errors required.
- For migrations on prod-sized tables, default to **CREATE INDEX CONCURRENTLY** and **default + backfill** for NOT NULL adds. `/bstack:migrate` enforces this.
- For new ADR-worthy decisions, write the ADR draft to Notion via the MCP integration, not as a side comment in the PR.
- When in doubt: re-read the relevant `docs/architecture/PRINCIPLES.md` section. Plan and source-of-truth disagreements: **source of truth wins**.
