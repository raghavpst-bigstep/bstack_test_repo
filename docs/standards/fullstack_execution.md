# Fullstack Execution Standard

> Guides full-stack feature implementation by enforcing coding conventions, repository
> structure standards, and code maintainability practices — expressed generically so
> any project on any stack can adopt them. Stack specifics come from the Project
> Manifest (`docs/standards/README.md`); project-specific checks register in §10.
> Rule IDs are prefixed `E-`. Test **content** rules live in `testing_standards.md`
> (`T-`); this doc owns the gates that invoke them.

---

## 1. The execution pipeline

Work flows through staged commands/rituals, each with a crisp *stops-at* boundary and
a committed artifact. Execution is deliberately the smallest, dullest stage: when the
marginal cost of code approaches zero, ~80% of leverage moves upstream to deciding the
right thing and downstream to verifying it held.

```
strategy → idea interrogation → brainstorm → spec → plan → IMPLEMENT → review → ship → release
   │            │                   │          │      │        │          │       │       │
 direction   premise            3 approaches contract tasks   code     findings  PR    staged
 artifact    challenge          + wedge      + AC     + risks           + triage        rollout
                                        (loops back: fix → compound → knowledge store)
```

| # | Rule | Failure mode |
|---|---|---|
| E-1.1 | Implementation requests route to planning first — never straight to code. A plan may be one paragraph for a small change, but it exists and is visible before the first edit. **Incident exception:** a production incident may run the project's compressed hotfix ritual (diagnose → minimal fix → test → review → ship in one pass) with artifacts written post-hoc — minimal scope, no refactors or features in the same change. | Unreviewable scope creep — or refusing to fix prod because process |
| E-1.2 | Each stage stops at its boundary: strategy has no implementation detail; a spec has behavior and contracts but no implementation file names or private signatures; a plan has tasks and files but writes no code. **Carve-out:** cross-boundary interface contracts (shared types, API shapes, events) are spec/plan-stage output in their single declared home (E-2.3) — they are contract, not implementation. | Stages collapse into one pass — or the pipeline gates on an artifact no stage may produce |
| E-1.3 | A spec defines, per behavior: inputs (types + validation), outputs (shape + side effects), error paths, and authorization. A spec without error paths is a happy-path sketch. Every spec'd error path maps to a rendered/returned state (E-3.15). | Edge cases discovered in production |
| E-1.4 | A plan carries: affected modules, numbered tasks sized within the Manifest's task-size budget (default ≤ ~30 min focused execution), the test-type table (per T-1), top-3 risks with detection signals, and a **rollback path** — before any task runs. | Unbounded tasks; no way back from a bad change |
| E-1.5 | Complexity tripwire: a plan exceeding the Manifest's budgets (default: > 8 files or any new service/module) pauses for explicit scope confirmation before proceeding. | Quiet expansion of a "small" change |
| E-1.6 | Knowledge-first: before designing or coding, search the project knowledge store (location per Manifest). A hit is read before anything is written. | Re-solving solved problems, worse |
| E-1.7 | Every non-trivial fix is captured back into the knowledge store before moving on; a fix you don't document is a fix you pay for twice. | Institutional memory evaporates |
| E-1.8 | Pre-implementation review gates are enforced by the implement stage's pre-flight: the plan artifact exists AND carries a review record naming an **independent lens or actor** (not the implementing agent reviewing itself in the same turn) with its findings. | Gates exist but nothing passes through them — or self-review theater |

## 2. Repository structure standards

The Manifest declares the project's **boundary map**: named layers (e.g.
`entrypoints` / `domain` / `shared-contracts` / `infrastructure` — names are the
project's own) and the allowed dependency directions between them. The generic
invariants:

| # | Rule | Failure mode |
|---|---|---|
| E-2.1 | Deployable units never depend on other deployable units' internals. Communication between them goes through declared interfaces (API, RPC, queue) — never shared private state or shared DB tables. | Deploy lockstep; hidden coupling |
| E-2.2 | Shared libraries never depend on deployable units. Dependencies point inward/downward only, per the boundary map. | Inverted dependencies; untestable libs |
| E-2.3 | Cross-boundary types/contracts live in exactly one declared home. The same domain type defined twice is a defect, not a convenience. | Type drift; integration bugs |
| E-2.4 | Declared dependencies (build metadata) match actual imports. | Broken caching/affected graphs; invisible coupling |
| E-2.5 | Every artifact type has one declared output location (specs, plans, ADRs, reports, migrations, runbooks) and one naming convention (dated, kebab-case topic). New artifact types extend the convention table in the same change that introduces them. | Artifacts scattered and unfindable |
| E-2.6 | Boundary violations are checked deterministically (a script over the import graph), with a gating exit code — at author time and again at review time, same checker. (No checker yet → Bootstrap step 2 in the README.) | Honor-system architecture erodes |
| E-2.7 | VCS hygiene: no build artifacts, large binaries, or environment files in the repo; lockfiles ARE committed; the default branch is protected (E-9.3). | Bloated, leaky, unreproducible repos |

## 3. Coding conventions

| # | Rule | Failure mode |
|---|---|---|
| E-3.1 | New code reads like the surrounding code: match idiom, naming, comment density. Convention consistency beats personal preference. | Style churn drowns real diffs |
| E-3.2 | Comments state constraints the code can't show — never narrate the next line or justify the change to a reviewer. | Noise that rots the moment it merges |
| E-3.3 | Server-side validation is authoritative; client-side validation is UX only. | Tampered input accepted |
| E-3.4 | Every endpoint/action declares its required role/permission — no implicit "any authenticated user" — and object access is re-authorized against the current user at the action site. | Privilege escalation; IDOR |
| E-3.5 | Secrets never appear in source, committed env files, logs, or job/workflow inputs; they are fetched at runtime from the platform secret store. Truncated secret prefixes in logs count as leaks. | Credential exposure |
| E-3.6 | Request/operation context (request ID, tenant, actor) is carried explicitly across async boundaries — into queues, background jobs, and workflow activities — never read from ambient process state. | Untraceable or wrongly-scoped work |
| E-3.7 | Structured logs only in services, each carrying the request/correlation ID; errors log enough to reproduce (input shape, not PII). | Untraceable incidents |
| E-3.8 | Queries over potentially unbounded data carry a limit and/or pagination; N+1 access patterns are blockers, not warnings. | Cost and latency grow linearly with data |
| E-3.9 | Long lists in any UI virtualize beyond the Manifest's row budget. | Jank as data grows |
| E-3.10 | Background retries are idempotent — a retried job produces no duplicate side effects. Queues declare dead-letter/poison-message handling. | Double charges; silent message loss |
| E-3.11 | Every outbound network call has an explicit timeout — no infinite defaults. Synchronous retries are bounded, use backoff + jitter, and apply only to idempotent operations. | One slow dependency hangs the fleet; retry storms |
| E-3.12 | Every hard dependency declares its failure behavior — fail fast, degrade gracefully, or queue — and services drain in-flight work on shutdown signals. | Undefined behavior exactly when things break |
| E-3.13 | Public endpoints have inbound rate limiting / abuse throttling with declared limits. | One client (or attacker) takes the service down |
| E-3.14 | APIs are consistent project-wide: ONE error-response shape (machine code + human message + correlation ID), ONE pagination format, declared versioning + deprecation window for public APIs, and idempotency keys on client-retryable mutations. | Every endpoint a special case; double-submit bugs |
| E-3.15 | Every user-facing surface implements its non-happy states: loading, empty, error (actionable, correlation-ID-bearing, never a raw stack trace), and unauthorized. These map from the spec's error paths (E-1.3). | Happy-path-only UI shipped to real users |
| E-3.16 | File uploads enforce size and content-type limits validated server-side (content inspection, not extension), and land in private-by-default storage outside any web root. | Malware hosting; public-bucket leaks |
| E-3.17 | Non-production environments never send real email/SMS/push — outbound messaging is sandboxed; unsubscribe/consent hooks exist where compliance regimes (A-3.1) require them. | Test blasts to real customers |
| E-3.18 | Time is stored in UTC and rendered in the user's locale/timezone; money uses exact decimal types, never binary floats. | Off-by-a-day bugs; cent-rounding losses |
| E-3.19 | User-facing surfaces meet the Manifest's declared accessibility level: semantic structure, keyboard operability, focus management, labeled controls, sufficient contrast. | Unusable for real users; legal exposure |
| E-3.20 | When the Manifest declares more than one locale, user-facing strings are externalized and formatting (dates, numbers, currency) is locale-aware — no hardcoded display strings. | Untranslatable product; retrofit rewrite |

## 4. Data changes

| # | Rule | Failure mode |
|---|---|---|
| E-4.1 | Every schema migration is reversible (`down` actually reverses `up`) or explicitly declared irreversible with sign-off. | Stuck deploys |
| E-4.2 | Migrations on production-sized tables avoid long locks: additive defaults + backfill, concurrent index builds, per the data-layer adapter's mechanisms. | Lock-induced outage |
| E-4.3 | Migrations are idempotent / safe to re-run if interrupted. | Half-applied schema |
| E-4.4 | A shipped migration is never edited — write a new one. | History divergence across environments |
| E-4.5 | Every migration passes the project's deterministic migration checker (data-layer adapter) at author time AND at review time — the same checklist both times. | Author/review disagree; shift-left lost |

## 5. Testing gates

Test **content** standards (unit conventions, integration policy, E2E/browser, coverage
semantics, flake policy, test data, non-functional testing) live in
`testing_standards.md` — the `T-` rules. This section owns when tests gate the work:

| # | Rule | Failure mode |
|---|---|---|
| E-5.1 | Every acceptance criterion from the spec maps to at least one test **of the type T-1's placement table requires** — a unit test against mocks does not discharge an integration- or E2E-class criterion. | "Done" that proves nothing |
| E-5.2 | The authorization-negative test ("user A cannot reach user B's record") ships with the feature — it is the one test that cannot be deferred. | Silent IDOR class |
| E-5.3 | Tests run after each task, not once at the end. A failing test gets at most one retry-with-fix, then stops the line with its evidence. (P-2.9 cites this budget.) | Compounding breakage; token-burning loops |
| E-5.4 | Behavior-preserving refactors start from characterization tests and proceed in green-to-green steps; a refactor diff above the Manifest's split threshold (default 600 lines) is split. | "Refactor" that quietly changes behavior |
| E-5.5 | AI-generated code merges only with a test that would fail if the code were wrong — this is also what makes the model swappable. Verified by the review test-quality spot check (R-3.9, T-5.4). | Can never safely change the model or the code |

## 6. Maintainability practices

Rules E-6.1 and E-6.2 are *(conduct)* norms — ADVISORY by default (README design rule 4).

| # | Rule | Failure mode |
|---|---|---|
| E-6.1 | *(conduct)* Boil the lake: when the complete implementation (edge cases, error paths, the authz test) costs minutes more than the shortcut, do the complete thing. Oceans (rewrites, multi-quarter migrations) get an ADR, not silent scope. | Debt bought to save seconds |
| E-6.2 | *(conduct)* Build for the engineer reading this at 2 AM during an incident: names, tests, and log lines are messages to your future self; everything traceable to a correlation ID. | Unfixable because untraceable |
| E-6.3 | Simplicity pass before done: remove speculative abstraction, dead flags, and YAGNI surface introduced during the work. | Accretion nobody owns |
| E-6.4 | Every "we'll fix it later" becomes a tracker ticket in the same session, linked from the PR. | Later never comes |

## 7. Definition of done

A change is done when: all plan tasks complete · CI green per E-9.1 (typecheck, lint,
unit + integration tests, build, scans) · new acceptance + authz-negative tests in
place (E-5.1/E-5.2) · changed-code coverage meets the Manifest floor (T-5.1) ·
boundary check passes (E-2.6) · migration checker passes if applicable (E-4.5) ·
review findings triaged with no open BLOCKER · docs/artifacts updated per E-2.5 ·
knowledge store updated for any non-trivial lesson (E-1.7) · rollback path recorded
in the PR.

## 8. Human sovereignty

| # | Rule | Failure mode |
|---|---|---|
| E-8.1 | Agents recommend; users decide. When a recommendation changes the user's stated direction — present, explain, state missing context, ask. Never act first. | Confident wrong turns at machine speed |
| E-8.2 | No commit, push, or PR without explicit in-session approval; show the file list, message, and target branch first. Never force-push, never bypass hooks, never sweep unrelated files. | Irreversible surprises |
| E-8.3 | Destructive operations (data deletion, prod mutation, history rewrites) require a guardrail that asks first; always-on deny list for the worst class. | One bad command, no undo |

## 9. Delivery pipeline & environments

| # | Rule | Failure mode |
|---|---|---|
| E-9.1 | Minimum CI contract on every PR (build-system adapter): typecheck + lint at maximum practical strictness (warnings are errors; suppressions carry an inline justification and surface as ADVISORY findings), unit + integration tests, build, secret scan, dependency-CVE scan, boundary check (E-2.6), migration check (E-4.5). Red pipeline = no merge; bypass only with recorded sign-off. | Broken main; quality by mood |
| E-9.2 | Release-time gates, distinct from PR-time: the named regression suite (T-9.1) and critical-journey E2E (T-4.1) are green; the released artifact is traceable to a commit SHA. | Releases nobody can reproduce or trust |
| E-9.3 | The default branch is protected (vcs-host adapter): review + green CI required, no direct pushes. PRs link their tracker issue, stay within the Manifest's size budget, and carry at minimum: what, why, test evidence, rollback note (mechanically parseable sections per A-5.3). | Unreviewed changes; unreviewable PRs |
| E-9.4 | At least one production-like pre-production environment exists. Build once, promote the same artifact through environments; only config differs, via one declared mechanism, validated at boot (fail fast on missing keys). | "Works in staging" means nothing |
| E-9.5 | Feature flags declare an owner and expiry at creation, with a cleanup ticket (E-6.4). Risky changes ship dark behind a flag. Client-distributed artifacts (installed apps, embedded clients) additionally ship a server-controlled kill-switch / minimum-version path that survives a broken update layer. | Flag graveyard; no recovery from a bricked client |
| E-9.6 | Versioning follows the Manifest's declared scheme (semver default); release identifiers are strictly monotonic, never reused or decremented. | Store/registry rejects; targeting bugs |
| E-9.7 | The rollback command is rehearsed in pre-production before its first production use; code + schema roll out N-1 compatible (code works with both old and new schema during the transition); staged rollouts declare auto-abort thresholds and a named watcher. | Rollback as untested hypothesis; stuck mid-rollout |

## 10. Project-specific checks (registry)

The consuming project extends this standard here — never by editing §§1–9. Register
each check as `EP-n` (README design rule 7), citing the generic rule it refines:

```markdown
| # | Rule (refines) | Failure mode | Checker | Owner |
|---|---|---|---|---|
| EP-1 | <stack-specific rule> (refines E-4.2) | <what breaks> | <script/CI step or "judgment"> | <team/person> |
```

Registration guidance:
- Refine, don't contradict: a project rule may tighten a generic rule, never loosen it
  (README design rule 7); registry changes are reviewed like code.
- Every checker a script can run should run in CI **and** be invoked by the review
  stage — same tool, same exit codes (E-2.6, E-4.5 pattern).
- Budgets (file-count tripwire, task size, list-virtualization threshold, refactor
  split size, coverage floor, PR size) get concrete numbers here, sourced from the
  Manifest; the defaults named in §§1–9 apply until then.
