---
name: bstack:auto
description: 'End-to-end autopilot — ticket → spec → mockup gate → parallel implement → QA + screenshots → PR → deploy, stopping only at defined gates'
argument-hint: '[ticket URL/ID, feature description, or "latest"] [--env=staging|production] [--yes-to-gate=details|mockup]'
model: opus
---

# /bstack:auto

> **TASK TRACKING:** Create one task per stage below (0–9). Mark each complete as you go. This command does not do the work itself — it drives the existing `/bstack:*` commands in order and enforces the gates between them.

The single-command spine: hand it a ticket, it carries the work from intake to deploy. It **delegates** each stage to the specialized command (so their rules, agents, and outputs stay authoritative) and **stops only at the three gates** — everything between a gate is autonomous. It never idles while a long step runs (see Non-idle rule).

This command orchestrates; it does not replace. If a stage's own command stops for its own reason (test failure, scope challenge, CI red), `/bstack:auto` surfaces that and waits — it does not paper over it.

## The three gates (the only places it stops)

| Gate | When | What the user sees | Skippable? |
|---|---|---|---|
| **G1 — Details** | After ticket intake, if the ticket is underspecified | The specific missing facts, as questions (D-format) | `--yes-to-gate=details` only if the ticket is already complete |
| **G2 — Mockup** | After spec, before any code, for UI-affecting work | A rendered sample of the feature to approve | `--yes-to-gate=mockup` for pure-API/no-UI changes (auto-skipped when no frontend surface is touched) |
| **G3 — Production deploy** | Before a production deploy | Commit SHA, version, blast radius, rollback command | **Never** — production always confirms (deploy Step 3, hard rule) |

Everything else — spec authoring, planning, parallel implementation, tests, QA, screenshots, staging deploy, canary — runs without prompting.

## MCP usage

| MCP | Stage | What for |
|---|---|---|
| Linear / Jira | 0, 7, 9 | `get_issue` / `jira_get_issue` to load the ticket; transition status as stages complete |
| Notion / Confluence | 1 | Existing spec/ADR lookup before writing a new contract |
| context7 | 1, 3 | Pin exact library API shapes the contract and implementation depend on |
| Playwright | 5 | QA drive + screenshots (positive and negative scenarios) |
| GitHub | 7, 8 | Open the PR, read CI status, deploy workflow |
| Slack / Google Chat | 2, 7, 8 | Post the mockup for async approval; PR link; deploy notices |
| Datadog | 8 | Canary metrics during the (non-idle) deploy watch |

## Stages

**0. Intake** — resolve the argument to a concrete work item.
   - Ticket URL/ID → fetch via Linear/Jira MCP; treat description + acceptance criteria as authoritative scope.
   - `latest` → most recent open ticket assigned to the current user, or the most recent `docs/specs/` entry if no tracker signal.
   - Free-text → the work item is the text.
   - Open the **run manifest** (see below) and record: source, ticket ID, timestamp, resolved scope summary.

**1. Contract-first spec** — run `/bstack:spec <resolved-scope>`. This is mandatory and comes before any planning or code (contract before implementation). The spec's Behavior section fixes inputs/outputs/edge-cases/authorization; its Acceptance criteria become both the test table and the QA checklist. Frontend builds against this frozen contract while the API is built in parallel (Stage 4).

**2. Gate G1 — Details** — after the spec drafts, check its "Open questions" section and the ticket for gaps that block a correct build (ambiguous acceptance criteria, undefined error behavior, missing authorization rule, unspecified data shape). If any exist, **stop** and ask them together via AskUserQuestion in D-format. Fold the answers back into the spec. If none exist (or `--yes-to-gate=details` and the spec has zero open questions), proceed silently.

**3. Mockup** — if the work touches a frontend surface (`apps/frontend-web`, any `apps/mobile-*` / `apps/native-*` screen):
   - Run `/bstack:design-shotgun <surface>` for a UI-heavy new surface, or generate a **single** representative mockup for a smaller change (a rendered HTML sample at the real viewports, per design-shotgun hard rules — 1440×900 + 375×812).
   - Render to `docs/auto-runs/<run-id>/mockup/` and capture the file path + a screenshot.
   - If no frontend surface is touched, skip to Stage 5 and note "no UI — mockup gate N/A" in the manifest.

**4. Gate G2 — Mockup approval** — post the rendered mockup (screenshot + open path, and Slack/Chat it for async sign-off) and **stop** for explicit approval. "Approve" → proceed. "Iterate" → one focused question, regenerate, re-present. This is the "show a sample of how it will look, confirm, then build" checkpoint — code does not start until it passes.

**5. Plan + parallel implement**
   - `/bstack:plan <spec-path>` → structured plan. The plan MUST mark API tasks and frontend tasks as **parallelizable** where they only share the frozen contract (Stage 1), so they run concurrently, not lockstep.
   - `/bstack:autoplan <plan-path>` → auto-review the plan (must pass before implement per E-1.8 / implement Step 2).
   - `/bstack:implement <plan-path>` → spawns one subagent per task, parallel where the plan marks tasks independent. API and frontend agents run at the same time against the shared contract.

**6. QA — 100% scenarios + screenshots**
   - `/bstack:qa --mode=diff` against the running full stack (`npm run local` — never a single service, or auth pages break; see command-conventions).
   - Exercise **both** paths per acceptance-criteria row: positive (valid input → expected output/status) and negative (empty, max, concurrent, **unauthorized/IDOR**, partial-failure). The spec's acceptance criteria + the IDOR-negative test are the source list — nothing is skipped.
   - Screenshot each scenario (Playwright `browser_take_screenshot`) at both viewports into `docs/auto-runs/<run-id>/screenshots/`. Verify each against the mockup/intent and flag visual regressions.
   - Any Critical/High QA finding routes back to Stage 5 (fix), not forward. Bound the fix → re-QA cycle to **at most 2 iterations**, then stop with evidence and surface the remaining findings (standards P-2.9) — do not loop indefinitely.

**7. Ship — PR with screenshots attached**
   - `/bstack:ship`. The PR body carries: Summary · ticket link · Test plan (the positive+negative matrix from Stage 6) · **Screenshots embedded as uploaded images** (not local paths — upload via `gh` asset or the run-manifest artifact host so they render in the PR) · Fingerprint section for mobile (§12.18) · Rollback plan.
   - Transition the ticket to In Review. Post the PR link to Slack/Chat.

**8. Deploy — staging always, production behind G3**
   - After CI is green, `/bstack:deploy --env=staging`. Watch the canary **without idling**: run the deploy/canary as a background task and poll on a fixed interval (do not block the turn on a fixed sleep). On canary FAIL → auto-rollback (deploy Step 9) → `/bstack:hotfix`.
   - If `--env=production` was requested: **Gate G3** — deploy's Step 3 confirmation fires (SHA, version, blast radius, rollback). Never auto-confirmed. Staged rollout + canary per deploy hard rules.

**9. Close** — `/bstack:compound` if the run produced a non-trivial learning; transition the ticket to Done; write the run manifest's final status. Post a one-line Slack/Chat summary with the deploy result.

## Run manifest (traceability)

Every run writes `docs/auto-runs/<run-id>/manifest.md` (`<run-id>` = `YYYY-MM-DD-HHMM-<topic>`), appended at each stage:

```
# Auto run <run-id>
Source: <ticket URL / description>       Ticket: <ID>
Stage log (append-only):
  0 intake     — <scope summary>
  1 spec       — <spec path>
  2 G1 details — <asked? answers folded>
  3 mockup     — <path> | N/A (no UI)
  4 G2 mockup  — approved by <user> at <time> | skipped (--yes-to-gate)
  5 implement  — <plan path>, <n> tasks, <parallel API+FE?>
  6 qa         — <health score>, <pos/neg counts>, <screenshots dir>
  7 ship       — <PR url>
  8 deploy     — <env>, <canary verdict>, <rollback? >
  9 close      — <ticket status>, <compound?>
```

This is the single artifact tying ticket → spec → approval → code → QA evidence → PR → deploy for one run. (It is a build trace, not a compliance system of record — an immutable audit log, per-change approval matrix, and signed release manifest are a separate follow-up.)

## Hard rules

- **Gates are the only stops.** Between gates, do not ask for confirmation — act. At a gate, do not proceed without the explicit answer.
- **Non-idle:** never block a turn on a fixed sleep waiting for a build, CI run, or canary window. Run long steps as background tasks and poll, so the run stays live and interruptible.
- **A stage's own stop wins.** If `/bstack:spec`, `/bstack:plan`, `/bstack:implement`, `/bstack:review`, or `/bstack:deploy` halts for its own reason, surface it and wait — never suppress or auto-retry more than once.
- **Commit-safety invariant holds** (command-conventions): no commit / push / PR / production deploy without an explicit in-session confirmation — Stage 7's PR and Gate G3 are those confirmations.
- **Contract before code** — Stage 1 (spec) cannot be skipped; Stage 5 cannot start before it.
- **No mockup, no UI code** — for a frontend surface, Gate G2 must pass before Stage 5 runs.
- **QA covers the full matrix** — every acceptance-criteria row gets a positive AND a negative scenario, including the IDOR-negative; a happy-path-only QA is a fail, not a pass.

## Decision format (all AskUserQuestion calls)

```
D<N> — <short title>
ELI10: <2-4 sentence plain-English explanation>
Stakes: <what breaks if we choose wrong>
Recommendation: <option> — <reason>
- Option A: ✅ pros / ❌ cons
- Option B: ✅ pros / ❌ cons
Net: <one-sentence tradeoff synthesis>
```
