---
name: bstack:deploy
description: 'Deploy to staging or production — pre-flight, deploy, canary checks, rollback procedure ready'
argument-hint: '[--env=staging|production] [--service=<app>] [--canary-window=15m]'
model: opus
---

# /bstack:deploy

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.
>
> **Use when:** PR merged and you need to ship to an environment. Production deploys ALWAYS require explicit user confirmation at Step 3.

## MCP usage

| MCP | When | What for |
|---|---|---|
| GitHub | Always | PR status, deploy workflow trigger |
| Datadog | Always | `search_datadog_logs`, `get_datadog_metric`, dashboards for canary window |
| Slack | Always | Pre-deploy + post-deploy notifications |
| Linear | If deploy ships a ticket | Transition status |

## Steps

1. **Pre-flight**
   - Arm careful mode for the session: `mkdir -p .claude/state && touch .claude/state/careful-active` (destructive-command guard stays on through the deploy; `/bstack:careful off` afterwards if unwanted).
   - CI green on the target commit (`get_pull_request_status`).
   - VERSION matches `CHANGELOG.md` top entry.
   - No outstanding hotfix PRs for the same area.
   - If migration in this deploy → confirm it ran in lower env first.
2. **Env resolution** — `--env=staging` defaults if unset for non-main branches; `--env=production` requires explicit flag.
3. **Confirm (production only)** — show: commit SHA, version, services affected, expected blast radius, rollback command. Wait for user "yes".
4. **Pre-deploy Slack** — post: environment, version, who's deploying, expected window.
5. **Trigger deploy** — GitHub Actions workflow or whatever the service's deploy path is. Capture the workflow run URL.
6. **Watch the deploy** — stream the workflow status. Fail loud if any step errors.
7. **Canary checks** (default 15m window after deploy completes):
   - Error rate vs. baseline (Datadog metric).
   - p95 latency vs. baseline.
   - Log scan for new ERROR-level entries since deploy.
   - Synthetic check: hit the primary health endpoint per service.
8. **Decide** — PASS: post Slack success + Linear transition. FAIL: trigger rollback (Step 9).
9. **Rollback (if needed)** — invoke the documented rollback procedure for the service. Post Slack. Open Linear incident ticket. Trigger `/bstack:hotfix`.

## Hard rules

- Production deploy without explicit user confirmation = aborted.
- Canary window cannot be skipped on production.
- Rollback path must be known and documented BEFORE the deploy starts. If it isn't, stop and document it first.
