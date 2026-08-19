# bstack — Command Conventions

> Single source of truth for IDs, ports, and invariants used across `/bstack:*` commands. Edit ONCE here; commands read this file.

## Local environment ports

| Service | Port |
|---|---|
| backend-api | 3000 |
| frontend-web | 4200 |
| ai-agent | 8000 |
| ai-extraction | 8001 |
| workflow-engine | 8082 |
| data-api (gRPC) | 50051 |
| agent-api (gRPC) | 50052 |

**Local stack rule:** authenticated frontend pages need backend-api + ai-agent + workflow-engine all running. Use `npm run local` (full stack). Never `npx nx serve <single-service>` for QA — auth pages will break.

## Channels

| Slack | Use |
|---|---|
| `#bstack-reviews` | PR review requests/results (`ship`, `review`, `hotfix`) |
| `#bstack-adr` | ADR announcements + brainstorms (`brainstorm`, `plan`) |
| `#bstack-incidents` | Production incidents (`hotfix`, `deploy` rollbacks) |

> Replace IDs above once channels are created. mrkdwn link syntax `<url|text>` — never bare URLs.

## Notion

| Item | Notes |
|---|---|
| ADR registry | Notion → ADRs / Proposals. ADRs live in Notion only — never in git. |
| Specs | Notion → Specs. Linked from the plan file under "## Spec reference". |

## Linear

| Convention | Rule |
|---|---|
| Hotfix label | `hotfix` + Priority `Urgent` |
| ADR ticket type | `Doc` |
| PR-tracking ticket | Always created by `/bstack:plan`, transitioned by `/bstack:ship` |

## Commit safety invariant

**Never commit, push, or open a PR until the user has explicitly approved it in this session.**

- Invoking a command does NOT authorize a commit.
- Before any `git commit` / `git push` / `gh pr create`: show the file list + commit message + target branch and take one explicit confirmation.
- Never sweep unrelated uncommitted changes — surface them and let the user decide.
- Never force-push.
- Never `--no-verify` unless the user explicitly asks.

## Branch & base

| Convention | Rule |
|---|---|
| Feature branch | `<initials>/<short-topic>` (e.g. `jk/invoice-export`) |
| Hotfix branch | `hotfix/<incident-id>-<short>` |
| Base branch | Default `main`. Active release window may pin `dev` — check `governance/release-process.md`. |

## Datadog references

| Use | Search |
|---|---|
| Per-request trace | `requestId:<id>` |
| Per-workflow | `workflowId:<id>` |
| Error grouping | Error Tracking → group by `error.message` |

## Test runners

| Stack | Command |
|---|---|
| TypeScript | `nx affected --target=test` |
| Python | `pytest apps/<py-app>/tests` |
| Go | `go test ./apps/<go-app>/...` |
| E2E (Playwright) | `nx e2e frontend-web-e2e` |

## File-naming conventions

| File | Pattern |
|---|---|
| Strategy | `STRATEGY.md` (repo root — single living file, overwrite + bump "Last reviewed") |
| Office-hours | `docs/office-hours/YYYY-MM-DD-<topic>.md` |
| Brainstorm | `docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md` |
| Spec | `docs/specs/YYYY-MM-DD-<topic>-spec.md` |
| Plan | `docs/plans/YYYY-MM-DD-<topic>-plan.md` |
| Solution | `docs/solutions/<category>/<short-slug>.md` |
| Migration | `libs/db/src/lib/migrations/files/YYYYMMDDHHMMSS_<verb>_<noun>.ts` |
| QA report | `docs/qa-reports/YYYY-MM-DD-qa.md` |
| Preset-E2E report | `docs/preset-e2e-reports/YYYY-MM-DD-<preset>.md` |
| CSO audit | `docs/security/YYYY-MM-DD-cso-audit.md` |
| Health report | `docs/health/YYYY-MM-DD-health.md` |
| Autoplan audit trail | `docs/plans/<plan-stem>-decisions.md` |
| Eval results (LLM) | `evals/llm/results/YYYY-MM-DD-<model>.md` |

## Model tiers (single source — command frontmatter cites this table)

Effort-match the model to the stage (standards P-1.3); aliases (`haiku`/`sonnet`/`opus`), never pinned IDs, so tiers survive model releases. `bin/bstack-command-lint` enforces valid tiers.

| Tier | Commands | Why |
|---|---|---|
| `haiku` | careful, freeze, unfreeze, context, learn, make-pdf | Toggles + mechanical utilities — no judgment |
| `sonnet` | scrape, qa, design-review, design-shotgun, review-doc, retro, ship, compound, health, setup, improve | Procedural flows and report generation — bounded judgment |
| `opus` | strategy, office-hours, brainstorm, spec, plan, plan-review, autoplan, implement, review, debug, hotfix, deploy, devops, migrate, refactor, mobile-release, preset-e2e, cso, auto, rice, rice-init | Architecture, review, incident, and safety judgment |

Per-tier behavioral overlays live in `.claude/overlays/<tier>.md` — a command's agent reads the overlay matching its tier at start.

## Evals (swap-safety gate)

`bin/bstack-eval` runs the deterministic golden suites (router accuracy, migrate-check verdicts, command lint); LLM-judged suites are specified in `evals/llm/`. Run before changing prompts, routes, checkers, overlays, or models — a regression blocks the change (standards P-5.2). Router misroutes observed in the wild get a new row in `evals/routes.golden.tsv` before the pattern fix (test-first).
