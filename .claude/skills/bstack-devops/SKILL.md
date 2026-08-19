---
name: bstack-devops
description: >
  CI/CD pipeline and local dev environment engineering for the BigStep Nx/DDD
  stack (React 19 + Express 5 + Go gRPC + Python FastAPI + Kysely/PostgreSQL on
  AWS EKS/RDS/S3). Authors and repairs GitHub Actions with Nx affected wiring,
  and stands up reproducible local bring-up. Invoked by /bstack:devops. Deploys
  and mobile releases stay in /bstack:deploy and /bstack:mobile-release.
version: 1
last_reviewed: 2026-08-03
applies_to: ".github/workflows/**, nx.json, project.json, package.json, docker-compose*, .env.example"
triggers:
  - ci pipeline
  - github actions
  - build pipeline
  - nx affected
  - local dev environment
  - bring up the stack
  - docker compose
  - release automation
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
---

# bstack-devops — CI/CD + Local Dev Environment

Two responsibilities, selected by `--target`: **ci** (continuous integration and
release automation) and **local** (a reproducible local stack). Runs at the **opus**
tier because pipeline and infra changes carry release-safety judgment. This skill
builds the machinery; it does not push to production — that is `/bstack:deploy`.

Read `.claude/config/command-conventions.md` first: it holds the canonical service
ports, the test-runner commands, and the local-stack rule. Never restate those values
— read them.

## Target: ci

### Principles

- **Affected-only.** Build, test, and lint through `nx affected --target=…` so a PR
  runs only what its diff touches. A blanket `nx run-many` on every push is a cache
  and cost regression — treat it as a bug.
- **Deterministic + cacheable.** Every job is reproducible from a clean checkout;
  pin action versions and toolchain versions. Rely on the Nx cache, don't fight it
  (critical-patterns §1.5 — `project.json` must declare the deps imports actually use,
  or the affected graph is wrong).
- **Secrets from the store.** Signing keys, tokens, and DB creds come from the CI
  secret store (AWS Secrets Manager / repo secrets) at run time — never committed,
  never echoed into logs (critical-patterns §3, §3.1–§3.4).
- **Release automation reuses `/bstack:ship`.** VERSION bump + CHANGELOG + tag logic
  lives there; a release workflow invokes that path rather than re-implementing it.
- **Observability parity.** A new job that gates or affects an SLO path pairs with a
  Datadog metric/dashboard (critical-patterns §5.4) — otherwise the regression it is
  meant to catch is invisible.

### Standard job shape

Lint → typecheck → unit (`nx affected`) → build (`nx affected`) → e2e (Playwright,
only when the diff touches the frontend) → package/release (on the release branch
only, via `/bstack:ship`). Keep the YAML minimal and commented; one concern per job.

## Target: local

- Bring the whole stack up with `npm run local`. Authenticated frontend pages need
  **backend-api + ai-agent + workflow-engine** running together — a single
  `nx serve <one-service>` breaks auth pages and produces false QA failures.
- Ports are exactly those in `command-conventions.md` (backend-api 3000, frontend-web
  4200, ai-agent 8000, ai-extraction 8001, workflow-engine 8082, data-api gRPC 50051,
  agent-api gRPC 50052). Detect and surface collisions rather than reassigning silently.
- Required env vars are documented (e.g. `.env.example`) and pulled at runtime; no
  secret is committed. A missing var or unreachable dependency is surfaced, not guessed.

## Verify (both targets)

- **ci:** trigger the workflow (or a `workflow_dispatch` dry-run) and read the run
  result via the GitHub MCP. A pipeline is reported green only from an actual run
  (A-1.2), never inferred from reading the YAML. On a red run, apply **at most one
  retry-with-fix, then stop with the run URL as evidence** (standards P-2.9) — never
  re-trigger a failing pipeline in a loop.
- **local:** hit each service's health endpoint / port and confirm it answers.

## Output

What changed, how it was verified (run URL / port checks), and any follow-up — a
missing secret, an undocumented env var, or a service without a health check — as a
tracker item.

## Hard rules

1. No secrets in workflow files, env files, or logs (critical-patterns §3).
2. CI status comes from a run in this session, not from inspection (A-1.2).
3. `nx affected`, not blanket rebuilds — cost and cache correctness (critical-patterns §1.5).
4. Production rollout judgment stays in `/bstack:deploy`; this skill stops at the pipeline.
