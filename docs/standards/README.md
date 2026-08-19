# bstack Engineering Standards

The stack-agnostic core of bstack, distilled from a deep review of the whole system
(commands, reviewer agents, hooks, digest tools, rules, docs) and hardened by an
adversarial verification pass. These five documents carry only what transfers to
**any** project — the process, the rule formats, the gates, and the AI-layer
discipline — and give every consuming project a declared place to plug in its own
specifics. BigStep's current stack bindings (`.claude/rules/critical-patterns.md`,
`bin/` tools, command bodies) are one *project registry* implementing these
standards, not part of the generic core.

## The five standards

| Doc | Rule prefix | Governs | Primary audience |
|---|---|---|---|
| [`fullstack_execution.md`](fullstack_execution.md) | `E-` | End-to-end feature implementation: pipeline, repository structure, coding conventions, resilience, delivery pipeline, definition of done | Implementers (human or agent) |
| [`testing_standards.md`](testing_standards.md) | `T-` | Test content and quality: unit, integration, contract, E2E/browser, coverage, flake policy, non-functional testing, QA | Implementers + reviewers |
| [`code_review_standards.md`](code_review_standards.md) | `R-` | Structured code review: lenses, severities, finding format, triage | Reviewers (human or agent) |
| [`high_level_architecture_review.md`](high_level_architecture_review.md) | `A-` | System-level engineering review: security protocols, compliance, operations continuity, decision consistency — plus pre/post technical document generation | Architects, tech leads |
| [`ai_prompt_chain_optimization.md`](ai_prompt_chain_optimization.md) | `P-` | The AI layer itself: LLM performance metrics, prompt-chain design, context-window mitigation, token efficiency | Whoever maintains the agent system |

## Design rules (apply to all five docs)

1. **Rules are numbered, with failure modes.** Every rule row is `# | Rule | Failure mode`.
   The failure-mode column is load-bearing — a rule nobody can tie to a real failure
   gets retired, not accumulated.
2. **Single source.** A rule lives once. Every other doc, agent, or command cites the
   number (`per E-4.2`) and never restates the text. Where a review-lens rule verifies
   an execution rule, it cites it explicitly.
3. **Generic core, declared extensions.** Normative rule text names no vendor,
   framework, or language (doc titles and descriptions may name the owning org).
   Project specifics live in the **Project Manifest** (below) and each doc's final
   *Project-specific checks* registry.
4. **One severity taxonomy:** `BLOCKER` (cannot merge/ship), `FIX` (must fix, may merge
   with a tracked task), `ADVISORY` (judgment call, recorded). **Default severities**,
   unless a rule row states otherwise: violations of security, authorization, secrets,
   data-safety, and release-gate rules are **BLOCKER**; structural and process rules
   default to **FIX**; rules tagged *(conduct)* are **ADVISORY** — they guide judgment
   and are not mechanically checkable.
5. **Deterministic before probabilistic.** Any check a script can compute, a script
   computes; agents and humans reason over the digest, never re-derive facts from the
   raw tree.
6. **Rule IDs are stable.** IDs are never renumbered or reused. A retired rule leaves a
   tombstone row (`E-3.2 — retired, superseded by E-3.7`). Generic sections only grow
   by appending.
7. **Registry namespace.** Project-registered rules use the doc prefix plus `P`:
   `EP-n`, `TP-n`, `RP-<lens>-n`, `AP-n`, `PP-n` — so they can never collide with
   generic IDs, and every citation is unambiguous about whether it is generic or
   project-specific. A registry rule may **tighten** a generic rule (smaller budget,
   stricter gate, higher severity) and must cite the rule it refines; it may never
   loosen one. Registry changes pass the code-review process like code (per R-2.6 and
   R-8 mechanics). **Legacy-corpus form:** an existing rule corpus may be re-homed
   wholesale as the project registry under a single citation prefix (e.g. `bstack §`)
   with a per-section refines map, preserving its historical numbers per design
   rule 6 — new rules added to it still follow the tighten-never-loosen and
   review-like-code requirements.

## The Project Manifest

Each consuming project commits a `PROJECT.md` (or equivalent, referenced from its root
agent-context file) declaring its **adapter bindings**. Generic rules reference
adapters by role, never by product:

| Adapter role | What it must provide | Read by (examples) | Examples (non-normative) |
|---|---|---|---|
| `tracker` | Issue/ticket CRUD, labels, priorities | E-6.4, R-2.5 | Jira, Linear, GitHub Issues |
| `doc-store` | ONE declared home per artifact type (ADRs, specs, reports) | E-2.5, A-4.1 | Git `docs/`, Confluence, Notion |
| `comms` | Notification channel per event type (review, incident, decision) | R-2.5, A-2.6 | Slack, Google Chat, Teams |
| `observability` | Log search, trace lookup, metric query, error tracker | R-5.5, A-2.9, A-2.10 | Datadog, Grafana, Sentry |
| `vcs-host` | PRs/reviews/CI status, branch protection settings | E-9.3, R-1.5 | GitHub, GitLab, Bitbucket |
| `build-system` | "What changed / what's affected" resolver + test/lint/typecheck runners | R-1.1, E-9.1, T-2.6 | Nx, Turborepo, Bazel, make |
| `data-layer` | Migration tooling + deterministic migration safety checker | E-4.5, T-3.1 | Kysely, Flyway, Alembic |
| `browser-automation` | Driving a real browser for E2E and QA | T-4.x, T-9.2 | Playwright, Cypress |
| `release-target` | Deploy channel(s), staged-rollout mechanism, rollback command | E-9.4, E-9.7, A-5.2 | K8s, serverless, app stores |
| `docs-generator` | How pre/post technical documents are produced and published | A-5.1 | Docs-as-code toolchain |

The manifest also declares: the **boundary map** (module layers, allowed dependency
directions), **numeric budgets** (performance, coverage floor, canary thresholds, PR
size, task-size and file-count tripwires, suite speed, flake quarantine window),
**critical user journeys** (the E2E-mandatory set, per T-4.1), **SLOs and error
budgets** per production service (A-2.9), **RPO/RTO per data class** (A-2.8),
**target accessibility level and locale set** (E-3.19/E-3.20 — "none" is a signed
statement, never a blank), **compliance regimes**, the **ownership table**
(per-module primary/backup owner + escalation channel), and the location of the
**knowledge store** and **incremental-review state**.

**Fail loudly on blanks:** any process step that reads a manifest field and finds it
empty must surface that as a finding — never silently no-op. The severity of a blank
inherits from the **strictest gate that reads the field** (a blank ownership table is
a BLOCKER at production release, because the runbook/escalation gate A-2.6/§5.2 reads
it). An empty ownership table pages nobody at 3 AM; that is worse than a stale one.

## Bootstrap (day zero)

The standards must be followable on a brand-new project. In order:

1. **Creating the Manifest is the first act of the pipeline.** On any project without
   one, every command's pre-flight stops and produces `PROJECT.md` first — populated
   by inspecting the repo where possible, with explicit blanks elsewhere. A missing
   manifest is the first BLOCKER of any run; a blank field is handled per the
   fail-loudly rule above.
2. **Missing deterministic checkers are findings plus setup tasks, not deadlocks.**
   Where a rule requires a checker (E-2.6 boundary check, E-4.5 migration check,
   R-1.1 pre-pass) and none exists yet, the check is performed manually, the result
   is marked `unverified` (R-7.3 semantics), a FIX finding is raised, and a setup
   task to build the checker enters the tracker in the same session (E-6.4 pattern).
3. **Tool discovery fallback.** Where the Manifest doesn't yet name a runner
   (tests, lint, typecheck), detect it from repo conventions, use it, and record the
   detection into the Manifest as part of the change — detection is never silently
   re-done per session.
4. **Knowledge-loop cold start.** A knowledge store younger than the Manifest's
   grace window (default: 30 days or 20 entries) is exempt from the P-6.5
   reuse-rate judgment; capture (P-6.2) applies from day one.

## Precedence

For any consuming repo: the **generic standards** set the floor; the **project
registry** (its `*P-` rules and legacy rule files it re-homes) tightens them; the
repo's root agent-context file binds both and wins on pure convention conflicts
(naming, locations). A project rule that *loosens* a generic rule is invalid per
design rule 7 — flag it, don't follow it. In this repo, `.claude/rules/critical-patterns.md`
is BigStep's project registry: its numbered rules (`§1.1`–`§14.3`) are cited with the
`bstack §` prefix to avoid collision with generic IDs.
