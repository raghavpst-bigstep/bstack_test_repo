---
name: web-app-qa
description: Exploratory and functional QA of any web app via Playwright MCP. Use when asked to "QA / test / sanity-check this web app", "exploratory test <url>", "functionally test this app against these requirements", or "click through <url> and find bugs". Takes a URL (required), an optional requirements markdown file, and optional username/password. With a requirements doc it verifies each requirement (functional); without one it does pure exploratory testing. Drives a qa-agent subagent per phase and produces an evidence-backed, report-only result. Portable across apps — no Playwright framework, no page objects, no app-specific setup.
---

# Web App QA — Exploratory & Functional Testing

## Purpose

Test an arbitrary web application the way a critical user would, using **Playwright MCP** to drive a real browser. Given just a URL, the skill explores the app, exercises every control, watches for broken layouts / missing feedback / console errors / dead ends, and produces an evidence-backed bug report. If a **requirements document** is supplied, it additionally verifies each requirement (functional testing with a traceability table). It is deliberately **framework-free** — no Playwright spec files, no page objects, no app-specific scaffolding — so it is reusable across many simple apps. It **never** modifies the app or fixes bugs; it documents them.

Lean on the app's title, labels, and visible structure to infer intent: a control labelled "Export CSV" should produce a CSV; a "Dashboard" should surface live data. Use that expectation to judge whether each control produced the right result.

## Inputs

| Input | Required | Notes |
| ----- | -------- | ----- |
| **URL** | **Yes** | The app under test. **If absent from the prompt, ask the user before doing anything else.** |
| **Requirements doc** | No | Path to a `.md` file of requirements / acceptance criteria. If given → **functional mode**: verify each requirement, then a light exploratory pass. If absent → **exploratory mode** only. |
| **Credentials** | No | `username` + `password` for a simple form login. If given, the qa-agent logs in first. Treated as secret — always redacted in logs/report. |

> Only the URL is mandatory. Accept the requirements path and credentials however the user phrases them (e.g. "requirements at ./reqs.md", "login as user@x.com / hunter2"). If the user provides a value that is clearly not a usable credential pair, ask for the actual username and password.

## Prerequisites

- **Playwright MCP server available** — the `qa-agent` subagent uses `mcp__plugin_playwright_playwright__browser_*`. The main agent does not drive the browser; the subagent does.
- **The app must be reachable** from this machine at the given URL. For a local app, confirm it is running first (the user starts it; this skill does not).
- The `qa-agent` agent (`.claude/agents/qa-agent.md`) does the browser work.

---

## Step 0 — Resolve inputs

1. If the prompt gave **no URL**, ask the user and stop until they answer.
2. Determine the **mode**: if a requirements `.md` path was given, this is **functional mode**; otherwise **exploratory mode**. If a requirements path was given but the file does not exist (`Read` fails), tell the user and ask whether to proceed in exploratory mode.
3. Capture **credentials** if provided (keep them only to pass to the subagent; never write them to the report).
4. Derive an **app slug** from the URL host/path (e.g. `app.example.com` → `app-example-com`) for the report folder.
5. Compute the **absolute** report + screenshots paths (see Step 4) and create one task per step below so progress is tracked.

## Step 1 — Phases (one qa-agent spawn per phase, relay after each)

Dispatch the `qa-agent` subagent **once per phase**, in order. A subagent only reports back when it finishes — it cannot stream — so after each phase returns, **relay a concise summary to the user** (what was mapped / passed / failed, screenshots) before starting the next phase. This gives progress checkpoints and lets the user redirect early.

The browser session **and any login persist across spawns** (the Playwright MCP server keeps one browser context). Tell every phase agent to first `browser_navigate` to the URL and `browser_snapshot` to confirm it is still authenticated, and to re-login only if it lands on the login page. Pass each later phase the **prior phases' findings** (the map, the requirement checklist, confirmed bugs) so it does not re-explore.

Each spawn's prompt must include: the **URL**, the **credentials** (if any), the **mode** (functional vs exploratory) and the **requirements file path** (if any), the **absolute screenshots path**, the **phase to run**, and the **prior findings**.

- **Phase 1 — Map.** qa-agent authenticates (if creds given), snapshots the app, and enumerates every screen, navigation target, and interactive control plus the data visible at rest. In functional mode it also `Read`s the requirements doc and turns it into a numbered checklist (R1, R2, …). Returns a structured map (+ checklist). **Relay the map.**
- **Phase 2 — Exercise & verify.**
  - *Functional mode:* verify each requirement R# → **PASS / FAIL / BLOCKED** with observed result + screenshot.
  - *Exploratory mode:* click every control and confirm the result matches its label/intent — visible feedback, correct screen/modal, plausible data, action completes (no infinite spinner), computed values consistent.

  **Relay PASS/FAIL per requirement or control + confirmed bugs.**
- **Phase 3 — Break it.** Boundary/malicious inputs (long, empty, `<script>`, unicode, emoji, SQL-ish, negative/overflow numbers), double-submit, refresh mid-flow, back/forward, invalid deep links, empty/no-data states, responsive at 768px & 375px, keyboard nav (Tab/Enter/Escape). **Relay edge-case + responsive + keyboard findings.**
- **Phase 4 — Report.** The main agent writes the report (Step 4) from the relayed phase results — no further browser spawn is needed.

**Continuous (every phase):** after each interaction the agent checks `browser_console_messages` (JS errors) and `browser_network_requests` (failed API calls); screenshots every bug (reproduced once) to the absolute screenshots path; applies the severity taxonomy and suppressions defined in the qa-agent.

**Autonomy:** within a phase the agent tests everything without pausing. It stops only if auth fails, the app is unreachable, or a required input is missing — the phase boundary is the only checkpoint.

## Step 2 — Severity & suppressions

Use the taxonomy embedded in the `qa-agent` (categories: Visual, Functional, UX, Content, Performance, Console, Navigation, Accessibility; severities Critical/High/Medium/Low) and honor its suppressions (dev-only React/HMR/webpack warnings, feature-flag logs, analytics/RUM noise, favicon 404s, source maps, designed empty states). Do not flag suppressed items as bugs.

## Step 3 — Report

Save a report to `./qa-reports/YYYY-MM-DD-HH-MM-<app-slug>/report.md` with a `screenshots/` subfolder. Pass the qa-agent the **absolute** screenshots path (relative paths resolve to the working directory, not the run folder).

Report structure:

```markdown
# Web App QA Report — <app-slug>

**Date:** YYYY-MM-DD HH:MM · **URL:** <url> · **Mode:** functional | exploratory
**Auth:** logged in as <username, redacted password> | none
**Requirements:** <path> | none

## Summary
- Mode: <functional/exploratory>
- Requirements verified: NN (PASS NN / FAIL NN / BLOCKED NN)   ← functional mode only
- Controls exercised: NN · Working as expected: NN · Issues: NN
- Health: <Excellent/Good/Needs Work/Critical Issues> (optional, per taxonomy weights)

## Requirements traceability   ← functional mode only
| Req | Description | Result | Evidence | Notes |
| --- | ----------- | ------ | -------- | ----- |
| R1  | …           | PASS   | ![](./screenshots/r1.png) | … |

## Issues (by severity)
### [SEVERITY] Short title
**Where:** <screen / control> · **Category:** <taxonomy>
**Steps:** 1… 2… 3…
**Expected:** … · **Actual:** …
**Evidence:** ![](./screenshots/issue-NN.png)
**Console/Network:** <relevant errors, if any>

## Controls verified OK
| Control | Result |
| ------- | ------ |

## UI/UX observations (non-blocking)

## Open questions
```

## Step 5 — Final summary to the user

Print: the app tested (URL) and mode, counts (requirements PASS/FAIL/BLOCKED in functional mode, and/or controls exercised / OK / issues by severity), the top issues, and the report path. If the run could not start (no URL, app unreachable, or auth failed), say so plainly.

---

## Key rules

- **Ask for the URL if missing** — never start a run without it. URL is the only mandatory input.
- **Mode follows the requirements doc** — doc present → functional (verify each requirement + traceability table); doc absent → exploratory only.
- **qa-agent does the browser work** — Playwright MCP tools live only in that subagent; the main agent orchestrates and writes the report.
- **Run in sequential phases, relay after each** — Map → Exercise → Break-it → Report. A subagent can't stream, so phases are the only way to give the user progress mid-run. Session + login persist across spawns; pass later phases the prior findings so they don't re-explore.
- **Framework-free & portable** — no Playwright spec files, no page objects, no app-specific scaffolding. Drive everything through Playwright MCP.
- **Credentials are secret** — pass them only to the subagent; redact in the report and repro steps.
- **Report-only** — document bugs with screenshots and repro steps; never change the app or propose code fixes.
- **Report to `./qa-reports/`** — portable, repo-agnostic; one timestamped folder per run with a `screenshots/` subfolder (absolute path passed to the agent).
