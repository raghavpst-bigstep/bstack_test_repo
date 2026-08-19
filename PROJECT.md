# PROJECT.md — <PROJECT NAME>

> **This file is the Project Manifest** required by `docs/standards/README.md`.
> A missing manifest is the first BLOCKER of any run. A **blank field is also a
> finding** — the fail-loudly rule says any process step that reads a field and
> finds it empty must surface that, never silently no-op. The severity of a blank
> inherits from the strictest gate that reads it.
>
> Do not delete rows to make this file "clean". Replace `TODO` with a value, or
> with an explicit signed statement (`none — <reason>, <owner>, <date>`).

## Adapter bindings

Generic rules reference adapters **by role, never by product**. Bind each role to
the tool this project actually uses.

| Adapter role | Binding | Target / config | Notes |
|---|---|---|---|
| `tracker` | TODO | TODO | Jira / Linear / GitHub Issues |
| `doc-store` | TODO | TODO | ONE declared home per artifact type |
| `comms` | TODO | TODO | One channel per event type |
| `observability` | TODO | TODO | Log search, traces, metrics, error tracker |
| `vcs-host` | github | `raghavpst-bigstep/bstack_test_repo` | Branch protection is read/written through this role (E-9.3) |
| `build-system` | TODO | TODO | "What changed" resolver + test/lint/typecheck runners |
| `data-layer` | TODO | TODO | Migration tooling + safety checker |
| `browser-automation` | TODO | TODO | E2E / QA driver |
| `release-target` | TODO | TODO | Deploy channels, staged rollout, rollback command |
| `docs-generator` | TODO | TODO | How technical docs are produced/published |

`bin/bstack-protect` reads the `vcs-host` row. If it is absent, the script detects
the host from `git remote origin`, uses it, and **appends the detection here** —
per Bootstrap rule 3, detection is never silently re-done per session.

## Branch protection

| Field | Value |
|---|---|
| Protected branches | TODO (e.g. `main`) |
| Strictness | `strict` (default) — see below before changing |
| Provisioned by | `bin/bstack-protect --apply` |
| Verified by | `bin/bstack-protect --verify` (exit 0 = compliant) |
| Evidence | `.bstack/evidence/branch-protection-<branch>-<sha>.json` |

**Strictness opt-out.** `--solo` drops the required-approval count to 0 so a one-person
project is not deadlocked. It is a **recorded** exception, never a silent default. If
used, fill this in — an untraced escape hatch becomes the default:

| Field | Value |
|---|---|
| `--solo` in use | no |
| Reason | TODO |
| Approved by | TODO |
| Review / expiry date | TODO |

## Boundary map

Module layers and the allowed dependency directions. Downward only.

```
TODO — e.g. Presentation → State → Domain → Data Access → Platform → Cross-cutting
```

| Rule | Value |
|---|---|
| Layers | TODO |
| Forbidden directions | TODO |
| Cross-domain contract location | TODO |

## Numeric budgets

| Budget | Value |
|---|---|
| Coverage floor (overall) | TODO |
| Coverage floor by criticality tier | Tier 1 TODO · Tier 2 TODO · Tier 3 TODO |
| PR size tripwire | TODO |
| File-count tripwire | TODO |
| Suite speed ceiling | TODO |
| Flake quarantine window | TODO |
| Canary / staged-rollout thresholds | TODO |
| Performance budgets | TODO |

## Critical user journeys

The E2E-mandatory set. Every row here must have an E2E test.

| # | Journey | E2E test |
|---|---|---|
| 1 | TODO | TODO |

## SLOs, error budgets, and data recovery

| Service | SLO | Error budget | RPO | RTO | Data class |
|---|---|---|---|---|---|
| TODO | TODO | TODO | TODO | TODO | TODO |

## Accessibility and locales

`none` is a **signed statement**, never a blank (E-3.19 / E-3.20).

| Field | Value |
|---|---|
| Target accessibility level | TODO |
| Locale set | TODO |
| Signed by (if `none`) | TODO |

## Compliance regimes

| Regime | Applies? | Notes |
|---|---|---|
| GDPR / CCPA | TODO | |
| COPPA | TODO | |
| Regional (KSA / UAE / India / China) | TODO | |
| Other | TODO | |

## Ownership

An empty ownership table pages nobody at 3 AM; that is worse than a stale one, and
it is a **BLOCKER at production release** because the escalation gate reads it.

| Module | Primary owner | Backup | Escalation channel |
|---|---|---|---|
| TODO | TODO | TODO | TODO |

## Locations

| Thing | Path |
|---|---|
| Knowledge store | TODO (e.g. `docs/solutions/`) |
| Incremental-review state | TODO (e.g. `.claude/state/`) |
| Evidence artefacts | `.bstack/evidence/` |
