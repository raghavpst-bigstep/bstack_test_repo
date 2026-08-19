---
name: bstack:review
description: '4. Multi-agent code review — detects affected apps, runs reviewers in parallel, surfaces findings as todos'
argument-hint: '[PR #, branch, file paths, or --scope=...]'
model: opus
---

# /bstack:review

> **TASK TRACKING:** Create one task per spawned reviewer. Mark complete when its findings are triaged.

Orchestrate a multi-agent review. Detects scope, spawns the right reviewers in parallel, returns a triaged findings list.

## MCP usage

| MCP | When | What for |
|---|---|---|
| context7 | Library code changed | Verify usage follows current best practices |
| Linear | Always | Find the driving ticket; link findings |
| Notion | Architecture-touching changes | Pull relevant ADRs / design docs |
| Playwright | Frontend changes + dev server up | Visually verify changes |
| GitHub | PR review target | `get_pull_request`, `get_pull_request_files` |

## Deterministic pre-pass (run before spawning reviewers)

Run `bin/bstack-affected <base>` once. It returns the affected apps/libs, an inline DDD-boundary digest, and flags migration / `api-interfaces` changes — deterministically, in one shot. Use its output to **decide which reviewers to spawn** instead of reading `project.json` files yourself. Hand each reviewer the relevant slice; the `ddd-boundary-enforcer` and `kysely-migration-validator` agents will re-run their own focused checkers (`bstack-ddd-check`, `bstack-migrate-check`) on just their files.

Then run `bin/bstack-rice path <one touched file>` to resolve the active SKILL.md (base + per-app chain) and `bin/bstack-rice validate` for advisory lint. Read each resolved SKILL.md and pass its **Enforcement** numbered list and **Forbidden** bullets to every spawned reviewer as additional review criteria. Forbidden-list hits in the diff are review-blocking unless the PR description has an explicit override (§14.3). Deps added by the diff that aren't in the resolved locked-stack table are surfaced as a reviewer prompt (§14.2 — advisory, reviewer decides).

## Scope resolution

| Argument | Action |
|---|---|
| `#1234` | `gh pr diff 1234` |
| `<branch>` | `git diff main...<branch>` |
| File paths | `git diff -- <paths>` |
| (none) | `git diff HEAD`; if clean, `git diff HEAD~1` |
| `--scope=<app>` | filter to `apps/<app>/` |
| `--scope=libs` | filter to `libs/` |
| `--incremental` | use `.claude/.last-review-commit` as the base |

## Reviewers (spawn in parallel based on detected scope)

| Reviewer | Scope trigger |
|---|---|
| `ddd-boundary-enforcer` (bstack) | New imports, new modules, lib/app changes |
| `kysely-migration-validator` (bstack) | Any change in `libs/db/src/lib/migrations*` |
| `mobile-manifest-auditor` (bstack) | Any change in `apps/mobile-*`, `apps/native-*`, `AndroidManifest.xml`, `Info.plist`, `*.entitlements` |
| `mobile-release-gate` (bstack) | Any change to `app.json`, `eas.json`, mobile version files (Gradle `versionCode`, iOS `CFBundleVersion`) |
| `mobile-compose-reviewer` (bstack) | Any `apps/native-android-*/**/*.kt` change containing `@Composable` |
| `architecture-strategist` | DDD boundary changes, new modules, shared libs |
| `kieran-typescript-reviewer` | TS app/lib changes |
| `kieran-python-reviewer` | Python service changes |
| `security-sentinel` | Always (light pass), full pass on auth code |
| `data-integrity-guardian` | Migrations, schema, persistence code |
| `data-migration-expert` | Migration files specifically |
| `performance-oracle` | Queries, loops over large datasets, large lists |
| `pattern-recognition-specialist` | Always |
| `code-simplicity-reviewer` | Final pass once others triaged |

## Cross-model consensus (high-stakes diffs only)

When the diff gates a release or touches auth, secrets, migrations, or payment paths, AND an independent second-model reviewer is available (`codex` CLI or the /codex skill), run it once on the same diff — standards P-2.7:

- **Timeout 10 minutes**; on timeout or error, degrade to single-model review and log it — never retry-loop, never block (E-5.3 budget).
- **Merge findings in triage:** flagged by both models → high confidence, lead with it; flagged by one → normal finding; models disagree on severity → surface the disagreement to the user, do not average it (E-8.1).
- Skip entirely for routine diffs — this step is opt-in cost, scaled to stakes.

## Output

1. **Per-reviewer findings** — severity, file:line, rationale, suggested fix.
2. **Triage** — must-fix (block merge), should-fix (this PR), follow-up (new ticket). De-duplicate overlapping-lens findings before presenting (R-1.4).
3. **Persistence** — write must-fix and should-fix findings to TaskCreate. Update `.claude/.last-review-commit`.
4. **Post-action** — post summary to Slack, link findings in Linear / GitHub.
