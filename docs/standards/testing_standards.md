# Testing Standards

> Defines what tests must exist and what makes them trustworthy — unit, integration,
> contract, end-to-end/browser, coverage semantics, flake policy, test data, and
> non-functional testing — generically for any stack. `fullstack_execution.md` §5
> owns *when* tests gate work; this doc owns test **content and quality**. Runners
> come from the Manifest's `build-system` adapter; browser tests from the
> `browser-automation` adapter (Playwright-class tooling). Project-specific checks
> register in §10. Rule IDs are prefixed `T-`.

---

## 1. Test-type taxonomy & placement

| Type | Verifies | Runs against |
|---|---|---|
| **Unit** | One behavior of one unit, in isolation | In-process, doubles at owned boundaries |
| **Integration** | Code + real collaborator (DB, queue, filesystem, framework wiring) | Real engine, ephemeral/containerized |
| **Contract** | Both sides of a cross-service interface agree | Executable consumer/provider checks |
| **E2E / browser** | A user journey through the deployed stack | Real browser / real client via the browser-automation adapter |

| # | Rule | Failure mode |
|---|---|---|
| T-1.1 | Placement is by what the behavior crosses: pure logic → unit; anything crossing a process/data boundary → integration against a real engine; every cross-service contract → an executable contract test; every Manifest-declared **critical user journey** → E2E. E-5.1 enforces this mapping per acceptance criterion. | Mock-everything suites that prove nothing |
| T-1.2 | The plan's test-type table (E-1.4) assigns each acceptance criterion its type per T-1.1. For features with externally-visible behavior this table is a BLOCKER at plan time (aligns A §5.1). | Test strategy improvised after the code |
| T-1.3 | The pyramid holds by default — many unit, fewer integration, few E2E. Inverting it (E2E-heavy) requires a registered justification. | 40-minute suites; flake swamps |

## 2. Unit test conventions

| # | Rule | Failure mode |
|---|---|---|
| T-2.1 | One behavior per test; the name states the behavior and expected outcome ("rejects expired token"), not the method under test ("test1"). | Failures that don't say what broke |
| T-2.2 | Arrange–act–assert (given/when/then) structure; one logical assertion subject per test. | Tests nobody can read or trust |
| T-2.3 | Deterministic by construction: no real wall-clock, network, filesystem, or unseeded randomness — inject clocks, IDs, and randomness through seams. | Heisenbugs in the suite itself |
| T-2.4 | No inter-test order dependence or shared mutable state; every test runs alone and in any order. | One test's residue fails another |
| T-2.5 | Mock only at owned boundaries (ports the code declares); never mock the unit under test's internals, and prefer real implementations of your own pure code. | Tests that pass while the wiring is broken |
| T-2.6 | The unit suite meets the Manifest's speed budget (default: fast enough to run after every task per E-5.3); slow tests move up the pyramid or get optimized, not skipped. | Tests too slow to run → not run |

## 3. Integration, data-layer & contract tests

| # | Rule | Failure mode |
|---|---|---|
| T-3.1 | Persistence code is tested against a real database engine (ephemeral/containerized), not an in-memory fake; migrations are applied in tests the same way they are in production (E-4.5). | "Passes on the fake, fails on prod SQL" |
| T-3.2 | Per-test data isolation via transaction rollback or truncation — tests never depend on residue from other tests (T-2.4 applied to data). | Order-dependent integration suites |
| T-3.3 | Every cross-service interface has an executable contract test (consumer-driven where the consumer is known); contract changes run both sides before merge (pairs with R-6.2). | Integration bugs found at deploy time |
| T-3.4 | External third-party APIs are faked at the boundary with recorded/verified fixtures; a scheduled (not per-PR) verification job detects fixture drift. | Suites that break when a vendor sneezes — or never notice it changed |

## 4. End-to-end / browser tests

Driven through the Manifest's `browser-automation` adapter (Playwright-class).

| # | Rule | Failure mode |
|---|---|---|
| T-4.1 | Every Manifest-declared critical user journey (sign-in, the core value path, payment/checkout where present) has an E2E test, green at release time — BLOCKER (E-9.2). | The one flow that pays the bills breaks silently |
| T-4.2 | Selectors are resilient and semantic: role/label/test-id, in that preference order — never brittle CSS chains, XPath positions, or nth-child. | Suite rots on every markup change |
| T-4.3 | No fixed sleeps — waits are condition-based (element state, network idle, app signal). A fixed sleep in an E2E test is a FIX finding. | Slow AND flaky at the same time |
| T-4.4 | Authenticated tests reuse session/storage state established once per run — never a UI login per test (login itself gets exactly one dedicated test). | Minutes of duplicated login; auth rate-limits |
| T-4.5 | Tests own their data: they seed what they need and clean up after; no dependence on pre-existing environment state or other tests' leftovers. | Green locally, red in CI, unreproducible |
| T-4.6 | The viewport/device matrix comes from the Manifest (desktop + smallest supported mobile minimum for responsive surfaces). | Ships broken on the devices users actually hold |
| T-4.7 | E2E failures block **release**, not merge — the PR-time and release-time suites are declared separately (E-9.1/E-9.2), so slow journeys don't gate every commit. | Either E2E gates everything (dev grinds) or nothing |
| T-4.8 | E2E tests capture evidence on failure (screenshot, trace, console + network log) attached to the run. | Failures that take a day to reproduce |

## 5. Coverage & test quality

| # | Rule | Failure mode |
|---|---|---|
| T-5.1 | A coverage floor exists in the Manifest (blank = FIX per README fail-loudly) and is measured on **changed code per PR** as a gate — repo-wide totals are informational. | Legacy debt blocks new-code discipline — or hides it |
| T-5.2 | The floor is never lowered without a recorded sign-off (decision logged, tracker ticket). | Quiet ratchet-down to zero |
| T-5.3 | Coverage proves execution, not correctness: a test with no meaningful assertion is a FIX finding; writing tests to move the number without verifying behavior is gaming, and review treats it as such. | A green dashboard over an untested system |
| T-5.4 | Review spot-checks the E-5.5 property on the riskiest changed paths: would this test fail if the code were wrong? (Mutating the code mentally — or mechanically where mutation tooling is registered.) | Assertion theater passes review |

## 6. Flaky test policy

| # | Rule | Failure mode |
|---|---|---|
| T-6.1 | A flaky test is a defect: it gets an owner and a tracker ticket in the same session it's identified (E-6.4 pattern). | "Just re-run it" as culture |
| T-6.2 | Quarantine is explicit, visible, and time-boxed by the Manifest's window (default 2 weeks): fix it or delete it — a quarantined test that expires is deleted with a finding. | Quarantine as a landfill |
| T-6.3 | Blanket suite-level auto-retry to mask flakes is banned; targeted retry is allowed only on tests annotated with the ticket that tracks their fix. | Flakes laundered into "passes" |
| T-6.4 | Quarantined-test count is a reported metric per run. | Rot invisible until the suite means nothing |

## 7. Test data

| # | Rule | Failure mode |
|---|---|---|
| T-7.1 | Factories/builders over shared static fixtures — each test states the data it cares about and defaults the rest. | Fixture coupling: one change breaks 40 tests |
| T-7.2 | No production data or real PII in fixtures, seeds, or recorded cassettes (extends R-4.6 into test code); generated/anonymized data only. | Privacy incident via the test suite |
| T-7.3 | Test code is reviewed by the same lenses as production code — it is production code for the purpose of review. | The suite becomes the worst code in the repo |

## 8. Non-functional testing

| # | Rule | Failure mode |
|---|---|---|
| T-8.1 | SLO-bearing paths get a performance/load test against the Manifest's numeric budgets before release (BLOCKER at release; pairs with R-5.5 / A-2.9). | First load test is launch day |
| T-8.2 | UI surfaces pass an automated accessibility scan plus a keyboard-only pass at the Manifest's declared level (E-3.19) before release. | Inaccessible product; legal exposure |
| T-8.3 | Security scanning runs in CI per E-9.1 (static analysis, secret scan, dependency CVEs) with patch SLAs by severity from the Manifest; externally-reachable systems get an abuse-case pass (rate-limit bypass, mass assignment, enumeration) per A-2.5's threat review. | Known-vulnerable releases |
| T-8.4 | Visual regression testing is optional and registered per project (§10) — where registered, baselines are reviewed artifacts, not auto-accepted. | Silent UI drift — or baseline churn nobody reads |

## 9. QA & regression

| # | Rule | Failure mode |
|---|---|---|
| T-9.1 | A named regression suite exists whose meaning is exactly "green = releasable"; it is distinct from per-PR tests and is the E-9.2 release gate. | "Which tests matter for release" is folklore |
| T-9.2 | Before the first release of any user-facing surface, an exploratory QA pass (human or agent, via the browser-automation adapter) exercises it beyond the scripted paths; findings use the R-2.1 format and severity taxonomy. | Scripted tests all pass; the app is still unusable |
| T-9.3 | Bugs found in production get a regression test with the fix — the test demonstrates the bug before the fix and passes after. | The same bug ships twice |

## 10. Project-specific checks (registry)

Register as `TP-n` (README design rule 7), citing the generic rule refined:

```markdown
| # | Rule (refines) | Failure mode | Checker | Owner |
|---|---|---|---|---|
| TP-1 | <e.g. concrete runner invocations, mutation-testing tool, visual-regression baseline flow, device farm matrix> (refines T-x.y) | <what breaks> | <script/CI step> | <team/person> |
```

Typical registrations: the concrete test commands per suite, the critical-journey
list's E2E spec locations, coverage tooling and floor, flake-quarantine mechanics,
load-test tooling and budgets, a11y scanner and level.
