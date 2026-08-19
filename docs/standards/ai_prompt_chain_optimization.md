# AI Prompt-Chain Optimization Standard

> Evaluates LLM performance metrics, optimises prompt-chain logic, and mitigates
> context-window expansion — enforcing token-efficiency principles for the AI layer
> itself: the commands, agents, hooks, routers, and knowledge stores that make an
> agentic engineering system work. Generic for any agent harness and any model;
> project specifics register in §7. Rule IDs are prefixed `P-`.

The founding premise: **the model executes; the repository remembers.** The model is
the execution engine, never the system of record. Everything below exists to keep the
system cheap, measurable, and model-swappable.

---

## 1. LLM performance metrics

You cannot optimize a chain you don't measure. Every agentic workflow tracks, per
stage and per run:

| Metric | Definition | Why it's load-bearing |
|---|---|---|
| Task success rate | % of runs producing an accepted artifact without human rework | The only metric users feel |
| Eval pass rate | % of golden-task evals passing (see §5) | Swap-safety; regression detection |
| Tokens in / out per task | Prompt + completion tokens per completed unit of work | The cost driver; the efficiency denominator |
| Cache hit ratio | % of prompt tokens served from cache | Chains that thrash cache pay 5–10× |
| Latency per stage | Wall-clock per pipeline stage | Reveals barrier stalls and over-serialized chains |
| Human intervention rate | Corrections/redirections per task | Hidden cost of "autonomous" flows |
| Guardrail fire rate | Warns/denies from safety hooks per session | Guardrail firings are analyzable data, not noise |
| Knowledge reuse rate | % of tasks where a knowledge-store hit was consumed | Proves (or falsifies) the compounding loop |

| # | Rule | Failure mode |
|---|---|---|
| P-1.1 | Metrics are logged as structured events (append-only, versioned in the repo or the observability adapter) — never inferred from memory or anecdotes. **Each metric names its producer** (router, hooks, session telemetry, eval runner). Bootstrap minimum on day zero: task success, tokens per task, and human intervention rate, emitted by the harness's session hooks; the rest phase in as the components that produce them land (tracked as setup tasks, README Bootstrap step 2). | Optimizing folklore — or metrics nobody emits |
| P-1.2 | Every optimization claim states its metric, before/after, and the eval run that verified it. | Cargo-cult prompt tweaks |
| P-1.3 | Model choice is tiered per stage by measured need: expensive models where judgment dominates, cheap/fast models for extraction, formatting, routing, and mechanical steps. Pinning the most expensive model on every stage is a FIX. | Paying judgment prices for clerical work |
| P-1.4 | Cost per completed task (not per call) is the reported unit — a cheaper call that fails and retries is not cheaper. | Local optimization, global regression |

## 2. Prompt-chain logic

| # | Rule | Failure mode |
|---|---|---|
| P-2.1 | Chains are staged with stop-at boundaries, each stage leaving a committed artifact the next stage reads (strategy → brainstorm → spec → plan → implement → review). One mega-prompt that plans, codes, and ships in a turn is banned — with the same incident exception E-1.1 defines (compressed hotfix ritual, artifacts post-hoc). | State leaks; nothing auditable; quality collapse |
| P-2.2 | **Deterministic pre-pass first**: any fact a script can compute (affected modules, boundary digests, config diffs, migration flags) is computed by a script with gating exit codes; the model reasons over the digest. Digests cost ~nothing; raw-tree reads cost thousands of tokens and are non-reproducible. | Paying the model to re-derive facts, differently each run |
| P-2.3 | Structured outputs at every model boundary: downstream stages consume validated schemas, not prose to re-parse. | Parse failures and silent misreads mid-chain |
| P-2.4 | Specialized narrow prompts over one omniscient prompt: reviewers, planners, and fixers are separate roles with minimal toolsets (read-only where possible) and explicit triggers (R-1.2 applied to the AI layer). | One concern dominates; the rest get missed |
| P-2.5 | Parallelize independent stages; serialize only genuine dependencies. A barrier (wait-for-all) needs a stated cross-item reason. | Wall-clock = sum of slowest paths, needlessly |
| P-2.6 | Freeform requests route through a deterministic router (pattern table + hook) into the right chain; the routing table is data, extended by adding rows, and its misroute rate is measured (P-1.1). | Every request freehanded; process exists only on paper |
| P-2.7 | Chains verify claims adversarially where the Manifest declares stakes high (default: anything gating a release, a security finding, or a destructive action): independent verification passes for findings, canary windows with numeric thresholds for releases. Agreement between two models is a signal, not a mandate — the human decides direction changes (E-8.1). | Plausible-but-wrong at machine speed |
| P-2.8 | Every chain declares its human-sovereignty points (per E-8.2/E-8.3) and its autonomy contract everywhere else. | Either rubber-stamp autonomy or ask-fatigue |
| P-2.9 | Retries are bounded and idempotent, on the E-5.3 budget (at most one retry-with-fix, then stop the line with evidence). | Token-burning retry storms |

## 3. Context-window expansion mitigation

Context is the scarcest chain resource; expansion is the default failure mode. The
mitigation toolbox, in order of preference:

| # | Rule | Failure mode |
|---|---|---|
| P-3.1 | **Reference, don't restate**: rules, conventions, and standards are cited by number and loaded once from their single source. Duplicated normative text in prompts is a FIX (same drift rule as A-4.7). | Every copy drifts; every copy costs tokens forever |
| P-3.2 | **Digest, don't dump**: models receive compact, purpose-built views (indexes, ranked search hits with one-line excerpts, diffs against base) — never whole trees, whole logs, or whole documents when a slice answers the question. | Context blown on bytes nobody reads |
| P-3.3 | **Just-in-time retrieval**: knowledge is looked up at the point of need (search the solutions store, query the schema, fetch the doc section) rather than pre-loaded "in case". A stateless agent that reads the file beats a stateful one that "knows" and is quietly wrong. | Stale context trusted over current truth |
| P-3.4 | **Stage isolation**: each chain stage starts from artifacts, not from the previous stage's full transcript; sub-agents return conclusions, not file dumps. | Context inheritance compounds until truncation |
| P-3.5 | **Session continuity by summary**: long sessions checkpoint working state (decisions, open tasks, next step) into a restorable artifact instead of relying on an ever-growing window. | Mid-task amnesia or runaway windows |
| P-3.6 | **Cache-conscious layout**: stable content (system prompts, standards, manifests) is ordered before volatile content; chains avoid mutating early-prompt content per call. | Cache thrash — full price on every call |
| P-3.7 | Context budgets per stage are declared in the Manifest and monitored (P-1.1); a stage habitually near its budget is split, not squeezed. | Silent truncation of the thing that mattered |

## 4. Token-efficiency principles

| # | Rule | Failure mode |
|---|---|---|
| P-4.1 | Instructions are written once, tersely, in the artifact the agent already loads; verbosity in always-loaded files is taxed on every call forever. | Ambient prompt bloat |
| P-4.2 | Tool outputs are trimmed at the source (limits, filters, structured slices) rather than post-filtered by the model. | Paying the model to be a text filter |
| P-4.3 | Expensive multi-agent fan-outs require explicit opt-in scaled to the ask; single-agent handles the default path. | Fleet-sized reviews of one-line diffs |
| P-4.4 | Knowledge-store entries are compact and structured (typed, confidence-scored, rule-linked, append-only with dedup/prune); prose lives in linked solution docs read only on hit. | Memory that costs more to read than to rediscover |
| P-4.5 | Repeated mechanical transformations get codified into scripts/skills after the second occurrence — the same promotion rule as R-2.6, applied to the AI layer itself. | Paying inference prices for scripted work |

## 5. Evaluation & model swap-safety

| # | Rule | Failure mode |
|---|---|---|
| P-5.1 | A golden-task eval set exists for each load-bearing chain (plan quality, review recall, fix correctness), versioned in the repo, runnable on demand. | No way to tell a better model from a different one |
| P-5.2 | Any model, prompt, or chain-structure change runs the evals before rollout; regressions block by the same BLOCKER semantics as code. | Silent capability regressions |
| P-5.3 | Nothing important lives in the agent: knowledge in the repo, execution in the model, verification in the tests (E-5.5 is the code-side twin). Swapping the model loses nothing. | Vendor/model lock-in via accumulated implicit state |
| P-5.4 | Eval failures feed the knowledge store like production failures do — wrong hypotheses are also learnings. | The same eval bug diagnosed quarterly |

## 6. The compounding loop (memory layer)

| # | Rule | Failure mode |
|---|---|---|
| P-6.1 | One knowledge system, two layers, one index: long-form solution docs + structured learnings log, with a single deterministic index/search tool over both. Two stores with no bridge is a defect. | Knowledge split-brains |
| P-6.2 | Capture is mechanically triggered (post-fix nudges, "that worked" routing, session-start surfacing) — logging must be cheaper than not logging. | Flywheel built but unspun |
| P-6.3 | Second occurrence promotes: a learning seen twice becomes a registered rule enforced by reviewers for free (R-2.6). | Learnings that never become leverage |
| P-6.4 | The store is maintained: dedup on write, prune on cadence (stale file refs, conflicting insights), and its search stays useful past hundreds of entries (upgrade retrieval before it degrades). | Write-only memory |
| P-6.5 | The loop is measured by knowledge reuse rate (§1) — a store nobody hits is a cost, not an asset. **Cold-start grace:** stores younger than the README Bootstrap window are exempt from this judgment; capture (P-6.2) applies from day one. | Ritual capture, zero payoff — or a flywheel killed while warming up |

## 7. Project-specific checks (registry)

Register as `PP-n` (README design rule 7), reviewed like code:

```markdown
| # | Rule (refines) | Failure mode | Metric/eval that verifies it |
|---|---|---|---|
| PP-1 | <e.g. model tier per stage, per-stage token budget, routing patterns, domain eval sets, PII redaction in traces> (refines P-x.y) | <what breaks> | <which §1 metric or §5 eval> |
```

Typical registrations: the model-tier table (which stage gets which model class,
P-1.3), per-stage context budgets (P-3.7), the routing pattern table (P-2.6),
domain-specific golden tasks (P-5.1), the high-stakes list for P-2.7, and any
regulated constraints on what may enter a prompt (ties to A-2.4 data classification).
