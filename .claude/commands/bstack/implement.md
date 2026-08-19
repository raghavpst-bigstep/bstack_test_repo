---
name: bstack:implement
description: '3. Execute an implementation plan via parallel agent teams — implements, tests, and reviews automatically'
argument-hint: '[path to plan file or "latest"]'
model: opus
---

# /bstack:implement

> **TASK TRACKING:** Mirror the plan's tasks 1:1 as TaskCreate entries. Mark each complete as the agent finishes it.

Execute an approved plan. Each task → one subagent. Generate unit tests. End with a `/bstack:review` pass.

## MCP usage

| MCP | When | What for |
|---|---|---|
| context7 | Tasks reference libraries | Pass to implementation agents for correct API usage |
| Linear | Plan references a ticket | `get_issue` for acceptance criteria; `save_issue` to update status at end |
| Notion | ADR exists | `notion-fetch` to verify implementation aligns |

## Steps

1. **Load plan** — `latest` → most recent file in `docs/plans/`; or use the path given.
2. **Pre-flight** — clean working tree, correct feature branch, ADR exists if referenced, and the plan carries a `## Review record` section (from `/bstack:autoplan` or a `/bstack:plan-review` pass) — an unreviewed plan does not enter implementation (standards E-1.8). Stop and ask if any check fails.
3. **Spawn agents** — one per task. Parallel where the plan marks tasks independent; sequential where there are deps. Each agent gets: task spec, files to touch, ADR link, MCP access list. **If the plan opens with a `## E — Enforcement` block (R.I.C.E.), pass those numbered invariants verbatim to every implementation agent as additional acceptance criteria — alongside the task's own tests.**
4. **Auto-test** — after each task, generate / update unit tests per the plan's test table. Run `nx test <project>` for affected projects.
5. **Cross-cutting checks** — DDD boundary lint, `api-interfaces` types regenerated, no app→app imports.
6. **Auto-review** — invoke `/bstack:review --scope=this-branch`. Triage findings: must-fix vs. follow-up.
7. **Document follow-ups** — anything deferred → Linear ticket linked to the plan.
8. **Post-action** — update Linear status, post Slack summary with diffstat.

## Safety

- If any test fails, stop and surface — do not "fix and retry" silently more than once.
- If the plan drifts during implementation, stop and ask whether to amend the plan.
