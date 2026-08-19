---
name: bstack:debug
description: 'Structured debugging with institutional memory — past solutions first, then trace, then hypothesize'
argument-hint: '[bug description, Linear ticket, or error message]'
model: opus
---

# /bstack:debug

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.

Diagnose bugs using `docs/solutions/` and Datadog **before** code reading. Evidence before hypotheses.

## Knowledge-first (do this BEFORE writing code)

1. Run `bin/bstack-solutions search "<symptom keywords>"` — it returns ranked compact hits. `Read` the single top hit, not the whole store.
2. Read `.claude/rules/critical-patterns.md`.
3. Read the relevant per-app `CLAUDE.md`.

## MCP usage

| MCP | When | What for |
|---|---|---|
| Datadog | **Always for runtime/prod bugs** | `search_datadog_logs` / `get_datadog_trace` by `requestId`, `workflowId`. Evidence before hypotheses. |
| context7 | Library-related | Known issues, breaking changes, migration guides |
| Linear | Ticket exists | `get_issue` for full context |
| Slack | Reported in Slack | `slack_search_public` for original report + screenshots |
| Notion | Architecture context useful | ADRs / design docs |

## Steps

1. **Intake** — extract: Symptom · Area (app/domain/file) · Repro · Context (when started, what changed). If vague, ask ONE clarifying question.
2. **Evidence** — Datadog logs + trace for the relevant IDs. Get the real stack trace and request scope.
3. **Solutions search** — spawn `learnings-researcher`. If a match exists, apply or adapt it. Stop here if solved.
4. **Trace the code** — follow the failing path. Note every assumption.
5. **Hypothesis** — state in one sentence with a confidence level (LOW / MEDIUM / HIGH).
6. **Smallest experiment** — the single change / log / query that confirms or kills the hypothesis.
7. **Confirm** — run the experiment. If hypothesis was wrong, go back to step 4.
8. **Propose fix** — minimal scope. Safety check: any auth, data-loss, or migration risk in the fix?
9. **Compound** — once fix lands, run `/bstack:compound` to capture the solution.

## Anti-patterns

- Reading code without first reading the logs (when a runtime bug).
- Multiple speculative changes in one pass.
- Skipping `docs/solutions/` because "it's a new bug" — most bugs aren't.
