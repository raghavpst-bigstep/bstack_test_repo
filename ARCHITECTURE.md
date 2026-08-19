# bstack — Architecture

> This document explains the *why* behind bstack. For the *what*, see `CLAUDE.md` (quick reference) and `.claude/rules/critical-patterns.md` (enforced rules). For the *how it should feel*, see `ETHOS.md`.

bstack is a Claude Code skill bundle — slash commands, reviewer subagents, hooks, and rules — that turns a Claude Code session into a teammate who already knows the BigStep stack. This document explains the architectural decisions that shape every command in the bundle.

---

## 1. The stack we're skilling against

| Layer | Tech | Why this choice shapes bstack |
|---|---|---|
| Frontend | React 19 + Redux Toolkit + MUI v5 | `bstack:design-review` knows MUI tokens; Redux slices are reviewed for server-validated state. |
| Backend (TS) | Express 5 + DDD on Nx | The whole point of `ddd-boundary-enforcer` and the `apps/` vs `libs/` discipline. |
| Backend (Go) | gRPC + dynamic SQL | Cross-service comms are gRPC, never shared DBs (rule 1.4). |
| AI services | Python FastAPI + LangChain + Temporal | `bstack:debug` knows Temporal activity inputs must carry context explicitly (rule 2.3). |
| Data | Kysely + Postgres | One database, accessed only through Kysely. Migrations go through `bstack:migrate`. |
| Monorepo | Nx + npm | `nx affected:*` drives `bstack:qa`, `bstack:review`, `bstack:implement`. |
| Infra | AWS (EKS, RDS, S3) + Terraform | `bstack:deploy` and `bstack:hotfix` know the AWS shape. |
| Test | Vitest, pytest, go test, Playwright | `bstack:preset-e2e` orchestrates Playwright via MCP. |

**The organizing principle:** DDD boundaries on an Nx monorepo. Domains are isolated as libs, services are deployable apps, and cross-domain contracts live in `libs/api-interfaces`. Most other architectural choices — async context propagation, migration discipline, the reviewer agents — exist to keep that structure honest as the codebase grows.

---

## 2. Why DDD with Nx

The Nx monorepo enforces module boundaries that match the business domain. We chose this over a many-repos setup because:

- Cross-cutting refactors (e.g. renaming an API type used by 4 apps) are atomic.
- `nx affected:*` lets `bstack:qa`, `bstack:review`, and `bstack:implement` run only what changed — fast feedback at scale.
- The dependency graph is enforceable: `apps/*` never imports `apps/*` (rule 1.1), `libs/*` never imports `apps/*` (rule 1.2). `ddd-boundary-enforcer` checks this.

### Cross-domain types live in `libs/api-interfaces` only

This is rule 1.3. Without it, the same `Order` type ends up redefined in 4 apps, drifts, and causes integration bugs. With it, there's one canonical home — and changes go through one review surface.

### Cross-app communication is REST / gRPC / SQS — never shared DB tables

Rule 1.4. Two apps reading from the same table is hidden coupling: it works until one team adds a column, and the other team's deploy breaks. The contract belongs in an interface, not in a shared schema.

---

## 3. Why separate reviewer subagents (not one)

Bstack ships five specialized reviewer agents:

| Agent | Enforces | Why it's separate |
|---|---|---|
| `ddd-boundary-enforcer` | Rules §1 | Structural / import-graph check. A focused mental model: the dependency graph. |
| `kysely-migration-validator` | Rules §4 | Migrations are write-once. A separate gate catches reversibility and locking before merge. |
| `mobile-manifest-auditor` | Rules §10–§11 | Android permissions + iOS `Info.plist`/entitlements are their own risk surface — permission and capability hygiene needs a dedicated pass. |
| `mobile-release-gate` | Rules §12 | Store and OTA releases are hard to reverse; version monotonicity, symbol upload, and staged rollout get a pre-release gate. |
| `mobile-compose-reviewer` | Rules §10 (Compose) | Jetpack Compose recomposition and stability failures are invisible to structural checks — a Compose-specific lens catches them. |

`bstack:review` spawns the relevant reviewers in parallel (alongside the generic `compound-engineering` reviewers) on every PR — the mobile trio only when the diff touches mobile apps. Findings surface as todos, not as blocks — the user decides what to fix.

We considered "one big reviewer agent that does everything." Rejected: the failure mode is that one concern dominates and the others get missed. Specialization keeps each agent's prompt focused enough to maintain.

---

## 4. The compounding loop

bstack treats institutional knowledge as a first-class artifact, not as something that lives only in heads and Slack threads.

```
problem → solution → /bstack:compound → docs/solutions/<entry>.md
                                     → docs/solutions/learnings.jsonl
                                     → indexed in INDEX.md
                                     → searchable on next /bstack:debug
```

The chain has three storage layers:

1. **`docs/solutions/*.md`** — long-form solution writeups for non-trivial bugs and architectural decisions. Hand-curated via `/bstack:compound`.
2. **`docs/solutions/learnings.jsonl`** — append-only structured log. Machine-searchable via `bstack-learn`. Linked back to rule numbers from `.claude/rules/critical-patterns.md`.
3. **`docs/solutions/INDEX.md`** — quick scan from the SessionStart hook. The first thing `bstack:debug` reads.

The mechanism: every commit triggers a `PostToolUse` hint to consider `/bstack:compound`. SessionStart shows the count of learnings + the most recent. `/bstack:retro` synthesizes weekly patterns. The default tendency of teams is to learn and forget — bstack inverts it by making logging cheaper than not.

---

## 5. Safety architecture

Three layers, in order of when they fire:

1. **`bstack:freeze`** — pre-edit. Restricts which files I can touch this session.
2. **`bstack:careful`** — pre-bash. Asks before destructive commands (rm -rf, DROP, force-push, S3 recursive delete, Kysely rollback).
3. **`.claude/settings.json` deny list** — hard block. Always-on, no override (`rm -rf`, `git push --force`, `git commit --no-verify`).

These don't replace each other — they layer. A hotfix session might be:
```
/bstack:freeze apps/billing
/bstack:careful
... do the work ...
/bstack:ship
```

Both guards stay active until session end. The deny list is always active.

The reviewer agents are the fourth, lagging layer — they catch what made it past the first three at PR time.

---

## 6. Why slash commands, not skills

Some skill bundles use top-level skill directories with `SKILL.md` files. Bstack uses Claude Code slash commands (`.claude/commands/bstack/*.md`). Why?

- **Discoverability.** `/bstack:` autocompletes in the prompt. Users see the menu.
- **No runtime dependencies.** Slash commands are just markdown — no Bun binary, no daemon, no installer beyond `setup`.
- **Composition.** Commands can invoke each other (`/bstack:ship` → `/bstack:review` → reviewers).
- **MCP-native.** Commands call MCP servers (Linear, JIRA, Notion, Slack, Google Chat, Datadog, GitHub, context7) directly without a wrapper.

The tradeoff: we hand-maintain each command's preamble. At 22+ commands, drift is a risk. The eventual fix is a template (see "Future" below).

---

## 7. MCP integration as the integration layer

bstack does not ship its own integrations with Linear, Notion, Slack, etc. It relies on MCP servers the user already has configured. The commands declare which MCPs they use and expect the user to have them connected.

| MCP | Used by | For |
|---|---|---|
| Linear | brainstorm, plan, ship, hotfix | Issue tracking |
| JIRA | brainstorm, plan, ship, hotfix | Issue tracking |
| Notion | brainstorm, plan, compound | ADRs, specs, design docs |
| Slack | brainstorm, ship, deploy | Team comms |
| Google Chat | brainstorm, ship, deploy | Team comms |
| context7 | plan, implement, debug | Library docs |
| Playwright | qa, preset-e2e | Browser automation |
| Datadog | debug, deploy | Observability |
| GitHub | ship, review | PRs, issues |

Rationale: MCPs are versioned and maintained by their owners. Bstack inheriting them keeps the bundle small and avoids reimplementing what already exists.

---

## 8. Installation model

`./setup` does two things:

1. **User-wide:** copies `commands/`, `agents/`, `rules/`, `output-styles/` into `~/.claude/`. Every project gets bstack.
2. **`--project`:** vendors `.claude/` into a repo. Teammates clone and inherit.

The user-wide install means a single developer can use bstack across all their repos. The project install means a team can standardize without each member running setup.

`settings.json` is only seeded on `--project` install if it doesn't exist — never overwritten.

---

## 9. What bstack deliberately does NOT do

- **No daemon, no headless browser.** Bstack uses Playwright via MCP — sufficient for our web stack, zero runtime.
- **No telemetry.** We may add opt-in usage logging later. Today, the only persistent state is `.claude/state/*` (per-session), `.claude/context/*` (checkpoints), and `docs/solutions/*` (per-repo, git-tracked).
- **No global config.** No `bstack-config get/set`. Configuration is per-repo via `.claude/`. Override via env vars at `setup` time only.

### Adopted (2026-07)

- **Model tiers + overlays.** Commands are effort-matched (`haiku`/`sonnet`/`opus` aliases — tier table in `.claude/config/command-conventions.md`); per-tier behavioral overlays live in `.claude/overlays/`.
- **Command template + lint.** `docs/templates/command.md.tmpl` + `bin/bstack-command-lint` (CI-gateable) replace hand-maintained preamble discipline.
- **`/bstack:autoplan`** — conditional multi-lens plan review with auto-decisions and one final gate; its audit trail satisfies implement's pre-flight review requirement.
- **`/bstack:cso` and `/bstack:health`** — security audit (OWASP + STRIDE + secrets) and quality dashboard with trend tracking.
- **Evals.** `bin/bstack-eval` deterministic golden suites (router, migrate-check, command lint) + LLM-judged tasks in `evals/llm/` — the model swap-safety gate.
- **Checkpoint stamps.** `bin/bstack-context-stamp` fires on every commit for crash recovery; cross-model consensus is an optional high-stakes step in `/bstack:review`; design-shotgun reads/writes a taste profile via `bstack-learn`; `bstack-solutions search` uses gbrain semantically when installed, regex otherwise.

---

## 10. Future architectural changes (tracked)

These are intentionally NOT built yet but are on the roadmap. Each will get its own ADR before implementation.

- **Optional usage telemetry.** Opt-in, local-only by default. Surface which commands fire, which fail, which the user skips. (hook-events.jsonl already captures guardrail fires.)
- **Semantic knowledge index by default.** gbrain integration is opt-in today; make it the default backend for `bstack-solutions` once proven on a real store.

---

## TL;DR

bstack exists to make a Claude Code session fluent in the BigStep stack: DDD boundaries on Nx, Kysely + Postgres, Temporal-backed services, and a compounding knowledge base. Every command, agent, hook, and rule keeps the structure honest and the changes safe while moving fast.

If a command makes you faster but weakens a safety rule, the rule wins. If the rule makes you slower without preventing a real failure mode, file an ADR to change it.
