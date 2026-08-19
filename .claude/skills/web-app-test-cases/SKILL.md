---
name: web-app-test-cases
description: Generate comprehensive E2E test cases for any web app via Jira + code + live exploration. Use when asked to "write/generate test cases for <url>", "create E2E test cases for this feature", "author test cases from these Jira tickets", or "produce test cases for <app> against these requirements". Takes an app URL (required), a feature/scenario, optional credentials, and optional requirements (Jira issue keys/JQL, a requirements .md, or pasted text). Drives a qa-agent subagent in mapping mode to map screens + capture selectors, optionally researches source code, and writes a self-contained TC-NNN test-case document ready for Playwright scripting. Report-only and portable — no Playwright framework, page objects, or app-specific setup. NOT for executing tests (use web-app-qa or /outcome:e2e-*), NOT for the Outcome App Builder (use app-builder-qa).
---

# Web App Test Cases — E2E Test Case Authoring

## Purpose

Generate detailed, self-contained E2E **test cases** for a feature or flow of any
web application. This is the authoring counterpart to the `web-app-qa` skill
(which executes/explores): here the deliverable is a `TC-NNN` test-case document
detailed enough that a developer can write Playwright scripts from it without
opening the app.

It is modeled on `/outcome:e2e-test-cases` but **generalized**: requirements come
from **Jira** (or any source), the **app URL and credentials are provided in the
prompt**, and all browser work is done by the **`qa-agent`** subagent. It is
deliberately **framework-free** — no Playwright spec files, no page objects, no
`.env`, no app-specific scaffolding — so it is reusable across apps.

It is **report-only**: it never modifies the app under test and never writes test
code. Credentials are always redacted.

## When to use vs. not

- **Use** for: "generate E2E test cases for `<url>`", "author test cases from
  Jira `PROJ-123, PROJ-124`", "write test cases for this feature against
  `requirements.md`".
- **Don't use** for: executing tests or running specs (`web-app-qa`,
  `/outcome:e2e-test-execution`), generating Playwright code
  (`/outcome:e2e-script-creation`), the Outcome App Builder apps
  (`app-builder-qa`), or building reusable presets (`building-outcome-presets`).

## Inputs

| Input | Required | Notes |
| ----- | -------- | ----- |
| **App URL** | **Yes** | The app under test. **If absent from the prompt, ask the user before doing anything else.** |
| **Feature / scenario** | Yes (or inferred) | What to focus the test cases on. If too vague to identify the area, ask one clarifying question, then proceed. |
| **Credentials** | No | `username` + `password` for a form login, or a token / token endpoint. Passed only to the qa-agent; **always redacted** in the document and repro steps. |
| **Requirements** | No | **Jira MCP if present** (issue keys or JQL). Fallbacks, in order: a requirements `.md` path → pasted requirements text → Jira REST via WebFetch (base URL + token from the prompt/env). If none, expected behavior is inferred from app intent + code. |
| **Repo / code access** | No | When a relevant repo is reachable, the code-research stream reads it; otherwise it degrades gracefully. |

> Accept the requirements and credentials however the user phrases them
> ("tickets PROJ-12, PROJ-13", "requirements at ./reqs.md", "login as
> user@x.com / hunter2"). Only the URL is mandatory.

## Prerequisites

- **Playwright MCP server available** — the `qa-agent` subagent uses
  `mcp__plugin_playwright_playwright__browser_*`. The main agent does not drive
  the browser; the subagent does.
- **The app must be reachable** from this machine at the given URL.
- The `qa-agent` agent (`.claude/agents/qa-agent.md`) does the browser work in
  its **Mapping mode**.
- **Jira MCP (optional)** — detected at runtime via `ToolSearch`. Not required;
  fallbacks cover the no-MCP case.

---

## Step 0 — Resolve inputs

1. If the prompt gave **no URL**, ask the user and stop until they answer.
2. Parse the **feature/scenario**. If too vague to identify the area to test, ask
   one clarifying question, then proceed.
3. Capture **credentials** if provided (keep only to pass to the qa-agent; never
   write them to the document).
4. Determine the **requirements source**:
   - If Jira issue keys / a JQL query are given, plan to use a Jira MCP (detect in
     Step 1). If none is configured, fall back to a requirements `.md`, pasted
     text, or Jira REST via WebFetch.
   - If a requirements `.md` path is given but the file does not exist (`Read`
     fails), tell the user and ask whether to proceed in inference mode.
5. Derive an **app slug** from the URL host (e.g. `app.example.com` →
   `app-example-com`) and a **feature slug** (kebab-case of the scenario).
6. Compute the **absolute** output + screenshots paths (see Step 4) and create
   one task per step below so progress is tracked.

## Step 1 — Launch research streams (parallel)

Spawn the research streams in the **background** (`run_in_background: true`) so
they run concurrently, then synthesize in Step 2 once all complete. Streams that
have no input (no requirements source, no repo) return a short "not available"
note instead of failing.

### Stream A — Requirements (Jira or fallback)

Run this yourself (main agent) or via a `general-purpose` subagent:

1. **Detect a Jira MCP** with `ToolSearch` (query e.g. `jira atlassian issue
   ticket`). If matching tools appear, load their schemas via
   `ToolSearch({ query: "select:<tool>,<tool>" })`, then fetch the issues named
   in the prompt (by issue key or JQL): description, acceptance criteria,
   comments, linked items.
2. **If no Jira MCP:** read the requirements `.md` if given; else use pasted
   requirements text; else, if a Jira base URL + API token were provided, fetch
   issues via WebFetch against the Jira REST API
   (`<base>/rest/api/3/issue/<KEY>`), redacting the token.
3. **If no requirements source at all:** proceed without one (inference mode).
4. Output a numbered requirement checklist (`R1, R2, …`) and a list of any
   contradictions/ambiguities for the main agent to resolve with the user.

### Stream B — Code research (`general-purpose` subagent, Bash only)

Same shape as `/outcome:e2e-test-cases` Subagent 2. **Use Bash for all file ops**
(`cat`, `grep -r`, `find`, `head`, `tail`) and `gh` for GitHub. Do NOT use Read /
Grep / Glob in this subagent.

- Locate and read the feature's frontend components and backend endpoints; review
  related PRs with `gh pr list/view/diff` when GitHub is authenticated.
- Extract UI elements, state/validation, error handling, endpoint contracts, auth
  rules, existing test coverage, and candidate selectors (best locator strategy
  per element).
- Note discrepancies between code and requirements — these become negative test
  cases.
- If no relevant repo or `gh` is reachable, return "no code access" and stop.

### Stream C — App exploration (`qa-agent`, Mapping mode)

Dispatch the `qa-agent` **once per phase**, in order, and **relay a concise
summary to the user after each phase** before starting the next (a subagent
cannot stream; phase boundaries are the only progress checkpoints).

The browser session and any login **persist across spawns** (one Playwright MCP
browser context). Tell each phase agent to first `browser_navigate` to the URL
and `browser_snapshot` to confirm it is still authenticated, and to re-login only
if it lands on the login page. Pass each later phase the prior phase's findings so
it does not re-map.

Each spawn's prompt must include: the **URL**, the **credentials** (if any), the
phrase **"Run in Mapping mode (test-case authoring)"**, the **absolute
screenshots path**, the **phase to run**, the **feature/scenario**, and the
**prior findings**.

- **Phase 1 — Map + selectors.** Authenticate (if creds given), snapshot the app,
  enumerate every screen/route/control, and **capture the best Playwright locator
  per interactive element** (role + name → label → placeholder → test-id → text).
  Note data/empty/error states and what each control is intended to do. Returns a
  structured map + selector table. **Relay the map.**
- **Phase 2 — Happy-path + state walkthrough.** Walk the primary flow end to end;
  record state transitions, validation feedback, and light edge observations
  (things that should become negative/edge test cases). Returns the flow + edge
  notes + screenshots. **Relay the flow and edge findings.**

Mapping mode keeps bug-hunting to a light pass — the goal is coverage and
selectors, not a full adversarial sweep.

## Step 2 — Synthesize (main agent)

Wait for all streams, then synthesize yourself — do **not** use
`e2e-test-planner` (it is coupled to this repo's page objects).

1. Merge the three streams; deduplicate; map each requirement `R#` and each
   mapped control to one or more test cases.
2. **Stop and ask the user immediately** on any contradiction (requirements vs.
   code vs. observed behavior). Never defer questions to the end.
3. Identify coverage gaps and ensure every category below is represented.

## Step 3 — Generate test cases (main agent)

Emit `TC-NNN` test cases across these categories: **Happy path**,
**Validation/Negative**, **Authorization**, **State management**, **UI/UX**,
**Error handling**, **Edge cases**, **API verification**.

Each test case must be self-contained:

- `TC-NNN` id, title, priority (P1–P4), type (Positive/Negative/Edge/UI-UX/API).
- Preconditions (user role, required state, test data).
- Exact steps with specific values.
- Verifiable expected results (specific assertions, not "it works").
- Selectors for key elements (from Stream B/C — the actual locators captured,
  not guesses).
- API verification endpoint/contract where applicable.

Rules:

- Every feature needs at least one **negative/error** test case and at least one
  **UI/UX** test case (layout, responsiveness, keyboard, accessibility).
- For any CRUD operation, include an **API verification** test case.
- Each test case is independent — state preconditions; assume nothing from prior
  tests.
- Do not pre-label test cases as "known issue"/GTF — write them asserting the
  correct expected behavior.

Then build a **Test Data Requirements** section: data to create before testing,
existing data assumed, and data created during testing (with cleanup notes).

## Step 4 — Write the output file

Portable, timestamped, repo-agnostic:

```
./test-cases/YYYY-MM-DD-HH-MM-<app-slug>/<feature>-test-cases.md
./test-cases/YYYY-MM-DD-HH-MM-<app-slug>/screenshots/   (from exploration)
```

Pass the qa-agent the **absolute** screenshots path (relative paths resolve to
the working directory, not the run folder).

Document structure:

```markdown
# E2E Test Cases: <Feature Name>

**Generated:** YYYY-MM-DD HH:MM · **App URL:** <url>
**Auth:** <username, redacted password> | none
**Requirements:** Jira <KEYS> | <path> | pasted | none (inferred)

## Summary
| Metric | Count |
| ------ | ----- |
| Total test cases | NN |
| Positive | NN |
| Negative | NN |
| Edge cases | NN |
| UI/UX | NN |
| API | NN |
| P1 / P2 / P3 / P4 | NN / NN / NN / NN |

## Research Sources
### Requirements
- <Jira KEY> Title — status — summary   (or requirements doc / inference note)
### Code References
- `path/to/component` — what it does   (or "no code access")
### App Exploration
- Screens mapped: NN · Controls captured: NN

## Selector Reference
| Element | Screen | Recommended locator |
| ------- | ------ | ------------------- |

## Test Cases
### Category 1: Happy Path
[TC-001, …]
### Category 2: Validation & Negative
### Category 3: Authorization
### Category 4: State Management
### Category 5: UI/UX
### Category 6: Error Handling
### Category 7: Edge Cases
### Category 8: API Verification

## Test Data Requirements
### Data to Create Before Testing
### Existing Data Assumed
### Data Created During Testing

## Notes for Playwright Implementation
- Selectors captured during exploration (see Selector Reference)
- API endpoints to verify
```

## Step 5 — Final summary to the user

Print: the app + feature, the counts (total / by type / by priority), the
research sources used (Jira/doc/inference, code access yes/no, screens mapped),
and the output file path. Then offer next steps:

```
What's next?
A) Review and refine test cases
B) Add more scenarios
C) Convert to Playwright scripts
D) Done
```

If the run could not start (no URL, app unreachable, or auth failed), say so
plainly instead.

---

## Key rules

- **Ask for the URL if missing** — it is the only mandatory input.
- **Requirements source is flexible** — Jira MCP if present, else requirements
  doc / pasted text / Jira REST; else inference mode (note it in the document).
- **qa-agent does the browser work in Mapping mode** — Playwright MCP tools live
  only in that subagent; the main agent orchestrates, synthesizes, and writes.
- **Run exploration in phases, relay after each** — Map+selectors → Happy-path.
  Session + login persist across spawns; pass later phases the prior findings.
- **Main agent synthesizes** — do not use `e2e-test-planner` (repo-coupled).
- **Self-contained test cases** — full preconditions, steps, expected results,
  and real selectors so a developer can script without the app.
- **Both positive AND negative; UI/UX and API are not optional.**
- **No deferred questions** — resolve contradictions with the user immediately.
- **Credentials are secret** — pass only to the subagent; redact everywhere.
- **Report-only & portable** — never modify the app or write test code; output to
  `./test-cases/`, repo-agnostic, one timestamped folder per run.
