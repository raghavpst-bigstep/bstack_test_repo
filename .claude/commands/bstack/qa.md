---
name: bstack:qa
description: 'Diff-aware QA against the running frontend — 4 modes, health score, screenshot-evidenced issues'
argument-hint: '[--mode=diff|full|quick|regression] [--url=http://localhost:4200] [--baseline=path]'
model: sonnet
---

# /bstack:qa

> **TASK TRACKING:** Create one task per page tested. Mark each complete with PASS / FAIL + screenshot path.

Systematic Playwright-driven QA of the frontend. Produces a health score and a list of issues with evidence.

## MCP usage

| MCP | When | What for |
|---|---|---|
| Playwright | Always | `browser_navigate`, `browser_snapshot`, `browser_click`, `browser_take_screenshot`, `browser_fill_form`, `browser_wait_for`, `browser_evaluate` |
| context7 | MUI component behavior question | `resolve-library-id` → `query-docs` for MUI |

## Pre-flight

1. **Dev server up?** `curl -s -o /dev/null -w "%{http_code}" <url>`. If down, offer: A) start full stack via `npm run local` (NEVER `npx nx serve <service>` — auth pages need backend-api, ai-agent, workflow-engine all up), B) different URL, C) abort.
2. **Auth state** — confirm test user is logged in via the existing session, or run the dev-login flow.

## Modes

| Mode | Scope |
|---|---|
| `diff` (default) | Pages affected by `git diff main...HEAD` in `apps/frontend-web/` |
| `full` | All routes in the app's route registry |
| `quick` | 5 top critical paths only (login, dashboard, primary workflow) |
| `regression` | Re-run last failures from `.claude/.last-qa-failures.json` |

## Per-page checklist

For each page:
1. Navigate, wait for load.
2. Snapshot DOM + take screenshot.
3. Console error check — any error / warning is a finding.
4. Network failures (4xx, 5xx).
5. Visual: layout broken, overlapping, missing data states, empty state shown when data exists.
6. Interaction smoke — click primary CTA, confirm next state.
7. Data binding: confirm user-scoped data renders correctly (names, IDs).

## Health score

```
raw   = (pages_passed / pages_tested) * 100 - (5 * console_error_pages) - (10 * critical_failures)
score = max(0, min(100, raw))          # always reported in [0, 100]
```

- `console_error_pages` — pages with ≥ 1 console error/warning (count pages, not messages).
- `critical_failures` — pages where a primary CTA/interaction failed or a 5xx was returned.

## Output

1. Markdown report at `docs/qa-reports/YYYY-MM-DD-qa.md`.
2. `.claude/.last-qa-failures.json` updated for next `regression` run.
3. Post Slack summary if score < 90.
