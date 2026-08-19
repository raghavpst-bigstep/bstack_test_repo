---
name: bstack:retro
description: 'Weekly engineering retrospective — what shipped, what broke, what to repeat, what to change'
argument-hint: '[--since=7d] [--team=<name>]'
model: sonnet
---

# /bstack:retro

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.

Weekly (or on-demand) team retro. Pulls from git, Linear, Datadog, and `docs/solutions/` to surface real signal, not vibes.

## MCP usage

| MCP | When | What for |
|---|---|---|
| GitHub | Always | PR list, merges, reverts since the window |
| Linear | Always | Closed issues, in-progress, blocked, hotfixes |
| Datadog | If observability data exists | Incident count, error rate trend, top noisy services |
| Slack | Always | Surface decisions / debates that happened in-channel |

## Steps

1. **Window** — default last 7 days from now. Override with `--since=14d` or `--since=YYYY-MM-DD`.
2. **Pulls** (in parallel):
   - `git log --since=<window> --oneline --no-merges` — what landed
   - `gh pr list --state=merged --search "merged:>=<date>"` — by author
   - Linear: closed issues, hotfix tickets, new ones opened
   - Datadog: error-rate trend, incident count, top failing services
   - `docs/solutions/` diff in window — knowledge captured
3. **Synthesis** — write to `docs/retros/YYYY-MM-DD-retro.md` with sections:
   - **Shipped** — features, fixes, breaking changes (with PR links)
   - **Incidents** — hotfixes + resolution time + root cause category
   - **Learning** — new entries in `docs/solutions/` + what they prevent next time
   - **Trends** — error rate ↑/↓, perf ↑/↓, throughput
   - **What worked** — 2–4 patterns to repeat
   - **What didn't** — 2–4 patterns to change next week
   - **Asks** — concrete next-week commitments (each has an owner + Linear ticket)
4. **Post-action** — share the doc in Slack; offer to file the "asks" as Linear tickets.

## Hard rules

- Every "what didn't work" must have a proposed change AND an owner — no orphan complaints.
- Every "ask" must be a Linear ticket by the end of the session.
- Do not invent metrics — if Datadog says no data, say "no data" and move on.
