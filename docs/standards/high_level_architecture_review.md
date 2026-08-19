# High-Level Architecture Review Standard

> Performs high-level engineering reviews — validates security protocols, compliance
> requirements, operational continuity, and architectural decision consistency across
> a project's tech stack — and defines the **Technical Document Generation** contract
> (Pre-build and Post-build). Expressed generically for any project; stack specifics
> come from the Project Manifest; project-specific validations register in §6.
> Rule IDs are prefixed `A-`.

Unlike code review (per-change, `code_review_standards.md`), this review is
**per-system and per-milestone**: at design time (before a significant build), at
release time, and on a recurring cadence (at least quarterly). Its unit of analysis is
the system and its decisions, not the diff.

---

## 1. Review triggers & scope

| # | Rule | Failure mode |
|---|---|---|
| A-1.1 | An architecture review is mandatory when: a new service/deployable is proposed; a system boundary or cross-service contract changes; a new external dependency class is introduced (data store, queue, third-party platform); a compliance regime newly applies; or the recurring cadence elapses. These same triggers scope the §5.1 document gates — routine feature work inside existing boundaries does not re-trigger them. | Architecture drifts between "big" projects — or ceremony smothers small changes |
| A-1.2 | The review consumes artifacts, not memories: the Manifest, the ADR log, the boundary map, the current pre/post technical documents (§5), and observability data. Claims unverifiable from artifacts are recorded as `unverified` (R-7.3 semantics). | Review theater over tribal knowledge |
| A-1.3 | Output uses the standard finding format (R-2.1) and `BLOCKER / FIX / ADVISORY` severities; BLOCKERs stop the build/release they gate. | Advisory-only reviews change nothing |

## 2. Security protocols & operational continuity

| # | Rule | Failure mode |
|---|---|---|
| A-2.1 | The system has a written authn/authz model: identity provider, token lifecycle, role/permission scheme, and where each is enforced. Every trust boundary on the architecture diagram names its check. | Implicit trust between components |
| A-2.2 | Deny-by-default at every tier: new endpoints, queues, buckets, and network paths are closed until declared open with an owner and a reason. | Forgotten-open surfaces |
| A-2.3 | Secrets management is centralized (platform secret store), rotated, and access-audited; no long-lived credentials embedded in clients or CI config. Client-distributed artifacts (apps, bundles) are assumed extractable. | Credential theft; unrotatable compromise |
| A-2.4 | Data is classified (public / internal / confidential / regulated) and every store, log stream, and third-party flow declares the classes it may hold; encryption in transit everywhere, at rest for confidential+ classes. | Unnoticed regulated-data sprawl |
| A-2.5 | A threat review (attack surface, abuse cases, tenant isolation, injection surfaces including prompt injection for AI features) exists for every externally-reachable component and is refreshed when A-1.1 triggers fire. Abuse cases feed T-8.3's testing pass. | Designing only for the honest user |
| A-2.6 | Incident readiness: every production component has an owner (Manifest ownership table), an escalation path (comms adapter), a runbook, and a tested rollback; blast-radius of each deployable is written down. | 3 AM incidents with no map |
| A-2.7 | Supply chain: dependency update policy with a declared staleness floor (default: no dependency more than one major version behind without an ADR), CVE patch SLAs by severity, artifact signing/provenance where the platform supports it, CI credentials scoped to least privilege. | Build system as the softest target |
| A-2.8 | Every data store declares its backup mechanism, its **RPO/RTO per data class** (Manifest), and a **restore-test cadence**. A backup whose restore has never been exercised is recorded `unverified` — an untested backup is a hope, not a plan. | Data loss discovered to be permanent during the incident |
| A-2.9 | Every production service declares SLOs (availability/latency targets + error budget) in the Manifest at first release. Every alert is actionable and links its runbook; page-vs-ticket severity is declared; alerts fire on symptoms, not causes. R-5.5 and T-8.1 assume these exist — this rule creates them. | Alert fatigue over unmeasured reliability |
| A-2.10 | Unhandled-exception capture to an error tracker (observability adapter) with release tagging is wired **before first production release** — for every tier the project ships (server, web, installed clients). | Silent crashes; debugging blind |

## 3. Compliance validation

| # | Rule | Failure mode |
|---|---|---|
| A-3.1 | The Manifest enumerates the compliance regimes in force (privacy, sector, regional, platform-store, licensing, accessibility). "None" is an explicit, signed statement — not a blank. | Discovering GDPR at audit time |
| A-3.2 | Every regime maps to a checklist artifact in the doc-store, with each obligation tied to the mechanism that satisfies it and the evidence that proves it. | Compliance as vibes |
| A-3.3 | Consent, data-subject rights, retention, and deletion paths are implemented mechanisms (not policies alone): the system can enumerate, export, and delete a subject's data on request within the regime's clock. | Unanswerable regulator letters |
| A-3.4 | Declared-vs-actual parity is checked deterministically where possible: privacy declarations vs. actual data flows, store metadata vs. shipped capabilities, license attributions vs. dependency graph. Divergence is a BLOCKER at release. | Delisting; legal exposure |
| A-3.5 | Third-party data processors are inventoried with contractual basis and data classes shared; adding one is an A-1.1 trigger. | Silent scope growth of data sharing |
| A-3.6 | Audit trail: security- and money-relevant actions are logged immutably with actor, object, and correlation ID, within retention rules. | Unprovable history |

## 4. Architectural decision consistency

| # | Rule | Failure mode |
|---|---|---|
| A-4.1 | ADRs live in exactly ONE declared home (doc-store adapter). Every doc that mentions ADRs points at that home. | Four inconsistent answers to "where do decisions live" |
| A-4.2 | Every load-bearing decision (stack choice, boundary, data store, communication style, locked dependency set) has an ADR with: context, decision, alternatives considered, consequences, and — where enforceable — the name of the check/agent that enforces it. | Decisions relitigated forever; unenforceable intent |
| A-4.3 | Consistency sweep: the review walks current reality (deps, services, infra) against the ADR log. Reality without a decision → retroactive ADR or removal; decision without reality → superseded. | ADR log as fiction |
| A-4.4 | One way per category: each recurring need (auth, config, queueing, styling, state) has one blessed pattern; a second way requires an ADR that supersedes or scopes the first. | Two ways to do everything, forever |
| A-4.5 | Deviations and escape hatches (native modules, raw SQL, vendor lock-ins) are inventoried with their justifying ADR; an unjustified escape hatch is a FIX. | Exceptions become the rule silently |
| A-4.6 | Cross-stack coherence: the same concern (logging, error handling, context propagation, versioning) is solved the same *shape* across every tier of the stack, adapted per tier, with the shape written down once. | Every tier a different country |
| A-4.7 | Rules follow the failure-mode format and are single-sourced; agents and docs cite numbers, never restate (README design rules 1–2, 6). Duplicated normative text found in review is itself a FIX. | Drift between copies becomes policy |

## 5. Technical Document Generation

Documents are generated artifacts of the pipeline (published via the `docs-generator`
adapter), not an afterthought. Each has one owner, one home (doc-store adapter), and a
freshness rule: **a stale doc is worse than no doc** — every doc carries its
last-verified date, and the review flags any doc older than its declared review window.

### 5.1 Pre-build documents (before implementation starts)

Produced by the strategy → brainstorm → spec → plan stages. The gates below apply
**when an A-1.1 trigger fires** (new system/service, boundary change, new dependency
class, new regime); routine feature work needs only the spec + plan artifacts of
E-1.3/E-1.4 at proportionate depth.

| Doc | Must contain | Gate |
|---|---|---|
| **High-Level Design (HLD)** | System context diagram, components and responsibilities, trust boundaries, data flows with classifications (A-2.4), scaling assumptions, infra cost estimate | BLOCKER for any new service/system |
| **ADR(s)** | Per A-4.2, for every load-bearing choice the design makes | BLOCKER when A-1.1 triggers fire |
| **Specification** | Behavior contracts: inputs, outputs, error paths, authorization per behavior (E-1.3); acceptance criteria (Given/When/Then); explicit out-of-scope | BLOCKER before planning |
| **Interface contracts** | Cross-boundary types/APIs/events in their single home (E-2.3, via the E-1.2 carve-out), versioning story | BLOCKER before parallel implementation |
| **Risk register** | Top risks with blast radius, mitigation, and detection signal; rollback path (E-1.4) | BLOCKER before implementation |
| **Test strategy** | Test-type table mapped to acceptance criteria per T-1.1/T-1.2; environments; data strategy (T-7) | BLOCKER at plan time for externally-visible behavior (T-1.2) |

### 5.2 Post-build documents (at/after ship)

Produced by the ship/release/retro stages; the architecture review validates them at
release and on cadence.

| Doc | Must contain | Gate |
|---|---|---|
| **As-built record** | Deltas between HLD and what shipped, with reasons; updated diagrams | FIX within one cycle of ship |
| **Runbook** | Start/stop/scale, health checks, known failure modes with responses, escalation path (A-2.6) | BLOCKER for production release |
| **API/interface reference** | Generated from the contracts' single home where possible; published location | FIX at release |
| **Deployment & rollback record** | Release identity (monotonic, SHA-traceable per E-9.6), staged-rollout plan and auto-abort thresholds (E-9.7), rehearsed rollback command path (release-target adapter) | BLOCKER for production release |
| **DR & continuity plan** | Backup/restore procedures, RPO/RTO per data class, last restore-test date (A-2.8) | BLOCKER for production systems |
| **Operations dashboard map** | The source-of-truth dashboard per SLO metric (A-2.9) — named once, so no two responders argue over which data wins | FIX at release |
| **Developer onboarding doc** | Repo README: what this is, clone-to-running in one documented path, how to test; verified on the freshness cadence | FIX at first release |
| **Handover/onboarding pack** | For externally-delivered projects: closure, access transfer, KT plan, support terms | BLOCKER at project close |
| **Changelog & release notes** | Human-readable, per release | FIX at release |
| **Retro/postmortem** | Per incident (not just weekly aggregate): timeline, contributing causes, process fixes with owners — feeding the knowledge store | BLOCKER after any Sev-1 |

| # | Rule | Failure mode |
|---|---|---|
| A-5.1 | Every document above is generated/updated by a named pipeline stage (docs-generator adapter) — a doc with no producing stage will not exist twice in a row. | Documentation decays to fiction |
| A-5.2 | Docs cite rules and ADRs by number; narrative that restates them is trimmed (A-4.7). | Same drift, prose edition |
| A-5.3 | Machine-checkable doc content (fingerprints, version numbers, dashboard links, rollback commands) is embedded in structured sections so gates can verify it mechanically (the PR-body-as-machine-interface pattern; E-9.3 uses this). | Human-only evidence that gates can't check |

## 6. Project-specific validations (registry)

Register as `AP-n` (README design rule 7), reviewed like code; regional/regulatory
specifics, platform-store gates, sector rules, internal policy:

```markdown
| # | Rule (refines) | Failure mode | Evidence artifact | Cadence/trigger |
|---|---|---|---|---|
| AP-1 | <e.g. "regulated data resides in region R", "store privacy label matches manifest", "escape-hatch inventory ≤ N"> (refines A-x.y) | <what breaks> | <the doc/digest that proves it> | <release / quarterly / trigger> |
```

Each registered validation names its **evidence artifact** — a review that cannot
point at evidence records `unverified` (A-1.2), and a validation that stays
unverifiable for two consecutive reviews is redesigned or dropped (with tombstone,
README design rule 6). Conduct-tagged rules are exempt from this self-pruning — they
are ADVISORY norms, not checks.
