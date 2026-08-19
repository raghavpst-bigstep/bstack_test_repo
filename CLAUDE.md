# bstack — Claude Context

When a bstack command runs, this file is the single source of truth for BigStep stack contracts. Keep this file short. Defer specifics to per-app `CLAUDE.md` files in the workspace.

## Stack

| Layer | Tech |
|---|---|
| Frontend | React 19 + Redux Toolkit + MUI v5 |
| Mobile (default) | React Native + Expo + TypeScript + Redux Toolkit (see `docs/architecture/ADR-001-mobile-stack.md`) |
| Mobile (native escape hatch) | Android: Kotlin + Compose · iOS: Swift + SwiftUI |
| Backend (TS) | Express 5 + TypeScript (DDD) |
| Backend (Go) | gRPC + dynamic SQL |
| AI services | Python FastAPI + LangChain + Temporal |
| Data | Kysely + PostgreSQL |
| Monorepo | Nx + npm |
| Infra | AWS (EKS, RDS, S3) + Terraform |
| Test | Vitest (TS), pytest (Python), go test (Go), Playwright (E2E) |

## Hard rules

1. **DDD boundaries:** apps depend on libs, libs never depend on apps. Cross-domain communication goes through `api-interfaces`.
2. **Knowledge-first:** before writing code, search `docs/solutions/INDEX.md` and `.claude/rules/critical-patterns.md`.
3. **Compound on every fix:** non-trivial fix → `/bstack:compound` before moving on.
4. **No silent migrations:** every Kysely migration runs through `/bstack:migrate` so reversibility and locking are verified.
5. **Understand before changing:** before modifying code, read the relevant `docs/` reference — architecture & design principles, code structure, testing strategy, and business details (see below). Never change behavior you don't yet understand.
6. **Auto-route every request:** before acting on any prompt — even one with no slash command — classify its intent against `.claude/config/routes.tsv` and run the matching `/bstack:*` workflow. The `UserPromptSubmit` hook surfaces the route; you act on it. Work always flows through a command so it stays planned, reviewed, and compounded. Freehand only what no command covers, and route implementation requests to `/bstack:plan` first — never straight to code.
7. **Feature-protocol gate (conditional):** for **new** screens / features / endpoints / components / hooks / services / repositories — if `bin/bstack-rice path <touched file>` resolves a SKILL.md, follow its Role / Intent / Context / Enforcement. Run `/bstack:rice` first to capture the four R.I.C.E. answers; embed them in the plan. If no SKILL.md resolves, `/bstack:rice` offers to scaffold one via `/bstack:rice-init` but does **not** block. For existing-code edits, match local file conventions instead.

## MCP integration

Commands that touch external systems use these MCP servers. **Do not bypass:**

| MCP | Used by | For |
|---|---|---|
| Linear | brainstorm, plan, ship, hotfix | Issue tracking |
| JIRA | brainstorm, plan, ship, hotfix | Issue tracking |
| Notion | brainstorm, plan, compound | ADRs, specs, design docs |
| Slack | brainstorm, ship, deploy | Team comms, decision context |
| Google Chat | brainstorm, ship, deploy | Team comms, decision context |
| context7 | plan, implement, debug | Library docs |
| Playwright | qa, preset-e2e | Browser automation |
| Datadog | debug, deploy | Observability, traces, logs |
| GitHub | ship, review | PRs, issues |

**Recommended additions** (wire these so the model stays replaceable — knowledge lives in the system, not the agent):

| MCP | Would serve | For |
|---|---|---|
| PostgreSQL | debug, migrate, plan | Read schema + run read-only queries against a real DB instead of guessing |
| AWS | deploy, debug | EKS / RDS / S3 state, deploy verification |
| Kubernetes | deploy, hotfix | Pod / rollout status, log tail during incidents |
| Filesystem | (host-level) | Sandboxed file access for non-repo artifacts |

## Engineering standards

`docs/standards/` holds the generic engineering standards (rule prefixes `E-`, `T-`,
`R-`, `A-`, `P-`) that govern execution, testing, review, architecture review, and the
AI layer. `.claude/rules/critical-patterns.md` is BigStep's **project registry**
implementing them — cite its rules with the `bstack §` prefix (e.g. `bstack §4.1`) to
avoid collision with generic IDs. Precedence: standards set the floor, the registry
tightens them, this file wins on pure conventions (see `docs/standards/README.md`).

## Read before you change (in this repo)

Per hard rule 5, read the doc that matches what you're touching **before** editing related code:

- `docs/architecture/PRINCIPLES.md` — architecture principles & design principles
- `docs/code-structure/STRUCTURE.md` — how the code is organized (where things live)
- `docs/testing/TESTING.md` — unit test + end-to-end test strategy and conventions
- `docs/business/BUSINESS.md` — business domain, rules, and why the system exists
- `docs/README.md` — index of the above

## Authoritative references in the workspace

- `workspace/CLAUDE.md` — root architecture reasoning
- `workspace/AGENTS.md` — agent orchestration
- `workspace/governance/` — ADRs, principles, domain boundaries
- `workspace/docs/solutions/` — past learnings (search FIRST)
- `workspace/.cursor/rules/` — syntax-level enforcement

When a bstack command needs context, **read these — don't restate them.**
