# Code Review Standards

> Conducts structured code reviews against these engineering standards — checks
> correctness, maintainability, security, performance, and architectural pattern
> compliance — expressed generically for any project and any stack. Stack specifics
> come from the Project Manifest; project-specific lenses register in §8. Rule IDs
> are prefixed `R-`. Where a review check verifies an execution or testing rule, it
> cites that rule (`E-`/`T-`) rather than restating it (README design rule 2).

---

## 1. Review architecture

Review is a pipeline, not a vibe: a deterministic pre-pass establishes the facts, then
specialized lenses (parallel reviewers — human or agent) judge them, then triage turns
findings into decisions.

```
diff + base ──► deterministic pre-pass ──► lens selection ──► parallel lenses ──► triage
               (affected modules,          (core lenses         (findings in        (BLOCKER /
                boundary digest,            always; registered   fixed format)       FIX /
                migration/config flags)     lenses by trigger)                       ADVISORY)
```

| # | Rule | Failure mode |
|---|---|---|
| R-1.1 | Every review starts from a deterministic pre-pass (build-system adapter): affected modules, boundary-violation digest, flags for migrations/config/contract changes. Reviewers reason over the digest — they do not re-derive facts from the tree. (No pre-pass tool yet → README Bootstrap step 2: manual, marked `unverified`, setup task filed.) | Reviewers burn effort rediscovering facts, inconsistently |
| R-1.2 | Lenses are specialized and scoped. One mega-reviewer is rejected: one concern dominates and the rest get missed. | Coverage illusion |
| R-1.3 | The four core lenses — §3 correctness & maintainability, §4 security, §5 performance, §6 architecture — run on **every** review. Registered lenses (§8) run when their triggers match. The **simplicity pass** (R-3.2 + R-3.4, verifying E-6.3) runs last, after other findings are in. | Gaps by omission — or fixed cost with no marginal signal |
| R-1.4 | Overlapping lenses declare their overlap; triage de-duplicates findings before presenting them. | The same finding argued three times |
| R-1.5 | Incremental mode: the last-reviewed revision is recorded in the Manifest-declared review-state location (PR metadata or a state file); re-review covers only the delta plus previously-open findings. | Full-review fatigue → reviews skipped |
| R-1.6 | Review-time checks and author-time checks are the same tools (same scripts, same exit codes — E-2.6/E-4.5 pattern). | "Passes locally, fails review" divergence |

## 2. Finding format & triage

| # | Rule | Failure mode |
|---|---|---|
| R-2.1 | Every finding: `[SEVERITY] title · Where (file:line) · Rule (generic `E/T/R/A/P` ID or registry `*P-` ID) · Why it matters (failure mode) · Suggested fix`. | Un-actionable review prose |
| R-2.2 | Severity is exactly `BLOCKER / FIX / ADVISORY`, assigned per the README's default-severity policy (design rule 4) unless the cited rule declares its own. | Four taxonomies; reviewer-mood severity |
| R-2.3 | A clean review returns a single PASS line — silence and padding are both banned. | Noise hides signal; or ambiguity about whether review ran |
| R-2.4 | A finding that can't cite a rule is `ADVISORY` — and is a candidate for a new registered rule if it recurs. | Reviewer taste enforced as law |
| R-2.5 | Triage output is persisted: BLOCKERs block merge; FIX items become tracker tasks linked from the PR; ADVISORY items are recorded with the decision; the summary is posted to the Manifest's review channel (comms adapter). | Findings evaporate after the review call |
| R-2.6 | A pattern seen in review for the second time is promoted to a registered rule (`*P-` namespace) — and the registration itself is reviewed like code (README design rule 7). The review that catches the pattern, not just the bug, is the one that compounds. | The next ten instances stay latent |

## 3. Correctness & maintainability lens

Correctness first — does the change do what the spec says — then whether the next
engineer can live with it.

| # | Rule | Failure mode |
|---|---|---|
| R-3.1 | The change matches surrounding idiom and the project's declared conventions (E-3.1). | Style entropy |
| R-3.2 | No speculative abstraction: interfaces with one implementation, flags with one caller, config with one value are flagged (verifies E-6.3). | Accidental framework nobody asked for |
| R-3.3 | Duplication of an existing capability (helper, type, query, component) is a finding — reuse or consciously supersede, never fork silently. | Parallel truths drift apart |
| R-3.4 | Dead code, commented-out blocks, and debug artifacts (prints, temp flags, sample data) do not merge (verifies E-6.3). | Archaeology for the next reader |
| R-3.5 | Public-surface changes (API, schema, events, exported types) call out their consumers; a breaking change names its migration path. | Downstream breakage discovered in production |
| R-3.6 | Naming honesty: a function does what its name says, no more; a misleading name is a FIX even when the code is correct. | Reviewers and callers reason from lies |
| R-3.7 | The diff is checked against the spec's acceptance criteria and error paths (E-1.3): every claimed behavior is implemented, every spec'd error path is handled and rendered (E-3.15). | Merges that satisfy the letter, not the contract |
| R-3.8 | Boundary and edge conditions are read for real: empty, maximum, concurrent, unauthorized, partial-failure. Concurrent mutation paths name their protection (transaction, lock, idempotency key — E-3.14). | The bug class that only fires under load |
| R-3.9 | Test-quality spot check on the riskiest changed paths per T-5.3/T-5.4: assertions are meaningful, the test would fail if the code were wrong (E-5.5), placement matches T-1.1. | Assertion theater passes review |
| R-3.10 | Error handling is deliberate: no swallowed exceptions, no bare catch-and-continue, failures carry context (E-3.7) and propagate or degrade per the dependency's declared behavior (E-3.12). | Silent corruption instead of loud failure |

## 4. Security lens

Runs on **every** review, regardless of scope. Violations are BLOCKER by default
(README design rule 4).

| # | Rule | Failure mode |
|---|---|---|
| R-4.1 | Authorization verified per E-3.4: declared per endpoint/action, re-checked at the action site against the current user (TOCTOU-safe), not just at route entry. | Privilege escalation; IDOR; race-window escalation |
| R-4.2 | The authz-negative test exists for any change touching object access (verifies E-5.2). | Untested trust boundary |
| R-4.3 | No secrets or secret prefixes anywhere in the diff, per E-3.5 — including test fixtures and CI config. | Credential exposure |
| R-4.4 | External input validated server-side per E-3.3; injection surfaces (SQL, command, template, prompt) use parameterization/tagging, never string assembly. | Injection class |
| R-4.5 | Cross-service calls re-validate identity/tokens — trust is never inherited from "it came from inside". | Trust boundary collapse |
| R-4.6 | PII is classified and handled per the Manifest's compliance regimes: not logged, not shipped to third parties without a declared basis, not present in test data (T-7.2), redacted before send. | Privacy incident; regulatory exposure |
| R-4.7 | New dependencies are justified (maintenance, license, provenance) and pass the project's dependency policy (A-2.7); lockfile changes are reviewed, not waved through. | Supply-chain exposure |

## 5. Performance lens

| # | Rule | Failure mode |
|---|---|---|
| R-5.1 | N+1 data access is a BLOCKER, not a warning (verifies E-3.8). | Cost grows linearly with data |
| R-5.2 | Unbounded reads (no limit/pagination) over growable data are BLOCKERs (verifies E-3.8). | OOM as data grows |
| R-5.3 | Work moved to hot paths (per-request, per-render, per-message) is justified against the Manifest's numeric budgets. | Death by a thousand cuts |
| R-5.4 | Caches state their invalidation story or don't merge. | Stale data bugs, unreproducible |
| R-5.5 | Changes to SLO-impacting paths name the metric/dashboard (observability adapter, per A-2.9) that will detect a regression. | Silent regressions |
| R-5.6 | Outbound calls in the diff carry timeouts and bounded retries per E-3.11; new public endpoints carry rate limiting per E-3.13. | Resilience regressions ship unnoticed |

## 6. Architectural pattern compliance lens

| # | Rule | Failure mode |
|---|---|---|
| R-6.1 | The boundary digest from the pre-pass is clean: no dependency-direction violations against the Manifest's boundary map (verifies E-2.1–E-2.2; digest also surfaces E-2.4 mismatches). | Erosion, one import at a time |
| R-6.2 | Cross-boundary contracts changed only in their single declared home (E-2.3), with consumers updated or versioned, and contract tests run on both sides (T-3.3). | Type/contract drift |
| R-6.3 | The change follows the project's established pattern for its category (new endpoint, new job, new screen, new migration) or explicitly documents why it deviates — deviation without an ADR reference is a FIX. | Two ways to do everything |
| R-6.4 | New modules/services justify their existence against the complexity tripwire (E-1.5) and carry an ADR when they alter the system's shape (A-4.2). | Architecture by accretion |
| R-6.5 | Async/background work carries explicit context (E-3.6) and idempotent retries with DLQ handling (E-3.10). | Untraceable, duplicated side effects |
| R-6.6 | Observability parity: new code paths log/trace/measure at the same standard as the paths they extend (E-3.7). | Blind spots exactly where the new bugs are |

## 7. Reviewer conduct

R-7.1 is a *(conduct)* norm — ADVISORY semantics (README design rule 4).

| # | Rule | Failure mode |
|---|---|---|
| R-7.1 | *(conduct)* Review the diff in context — read enough surrounding code to judge fit, not just the changed lines. | Locally-fine, globally-wrong approvals |
| R-7.2 | Findings are surfaced to the author as recommendations with decisions recorded (E-8.1); reviewers (including agent reviewers) do not rewrite the change unilaterally. | Sovereignty inversion; review becomes a second implementation |
| R-7.3 | If the reviewer cannot verify a claim (test passes, dashboard exists, rollback works), the finding says `unverified` — never assumes. | Rubber-stamp confidence |

## 8. Project-specific lenses & checks (registry)

The consuming project registers additional lenses and checks here — never by editing
§§1–7. Rules use the `RP-<lens>-n` namespace (README design rule 7); registrations
are reviewed like code (R-2.6). Each lens declares: **trigger** (paths/flags that
spawn it), **pre-pass tool** (deterministic checker it runs first), **checks**
(numbered rule rows), and **overlap** (which other lenses share ground, for R-1.4
de-dup).

```markdown
### Lens: <name>
Trigger: <path globs / digest flags>
Pre-pass: <script — exit code gates>
Overlap: <other lenses>

| # | Rule (refines) | Failure mode |
|---|---|---|
| RP-<lens>-1 | <stack-specific check, e.g. framework lifecycle, ORM misuse, platform-store policy> (refines R-x.y or E-x.y) | <what breaks> |
```

Typical registrations: language/framework idiom lenses, the data-layer migration
validator (E-4.5's review-time twin), platform/release gates, visual-regression
review (T-8.4), domain-rule validators. A registered lens whose trigger never fires
for two quarters is pruned (with tombstone, README design rule 6).
