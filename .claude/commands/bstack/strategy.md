---
name: bstack:strategy
description: '0. Establish or refresh product direction in STRATEGY.md — the bet, the wedge, what we are NOT doing. Feeds office-hours, brainstorm, plan.'
argument-hint: '[initiative, quarter, or "refresh"]'
model: opus
---

# /bstack:strategy

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.

Sits at the **top of the loop**, before `/bstack:office-hours`. Produces or refreshes a single living direction doc: `STRATEGY.md` (repo root). Every downstream command reads it — a sharp strategy makes every brainstorm, plan, and review narrower.

This command decides **direction**, never implementation. It stops at "what bet, for whom, why now, and what we are explicitly not doing."

## MCP usage

| MCP | When | What for |
|---|---|---|
| Notion | Always | `notion-search` for prior strategy docs, OKRs, ADRs that constrain direction |
| Linear | Always | `list_initiatives` / `list_projects` — what's already committed this cycle |
| Slack | If team context helps | `slack_search_public` for past direction decisions and their rationale |
| Datadog | If validating traction | usage / adoption metrics that confirm or kill a bet |

## Steps

1. **Intake** — restate what we're setting direction for in one paragraph: a product, a quarter, or a single initiative. If `arg` is `refresh`, load the existing `STRATEGY.md` and treat this as an update pass.
2. **Search prior direction** — read existing `STRATEGY.md`, Notion strategy/OKR docs, Linear initiatives, `workspace/governance/`. Surface anything that already commits us — strategy must reconcile with what's in flight, not contradict it silently.
3. **Situation** — where are we honestly: who uses this, what's the traction signal (cite a Datadog/Linear number, not a vibe), what constraints are real (team size, deadlines, dependencies).
4. **The bet** — state the single highest-leverage direction in one sentence. Then the **wedge**: the narrowest slice that proves the bet within one cycle.
5. **Not-doing list** — 3–7 things we are explicitly declining this cycle, each with the reason. This list is the most valuable part — strategy is what you say no to.
6. **Pillars** — 3–5 strategic pillars that follow from the bet. For each: the rationale, and the one metric that tells us it's working.
7. **Risks to the bet** — top 3, each with the leading indicator that would tell us the bet is wrong early.
8. **Write `STRATEGY.md`** (repo root) — sections: Situation · The Bet · Wedge · Not Doing · Pillars · Success Metrics · Risks · Last reviewed (date). Keep it under two pages; a strategy nobody re-reads is dead.
9. **Handoff** — explicit next step: `/bstack:office-hours <pillar>` to interrogate a specific bet, or `/bstack:brainstorm <pillar>` if framing is already clear.

## Conventions

- `STRATEGY.md` is **one living file**, not dated snapshots — overwrite and bump the "Last reviewed" date. History lives in git.
- Every pillar must name its kill metric. A pillar you can't measure is an opinion, not a strategy.
- Direction only. The moment you're listing files or APIs, you've left this command — hand off to `/bstack:office-hours` or `/bstack:plan`.
- Reconcile, never contradict: if the bet conflicts with a committed Linear initiative, surface the conflict and ask the user (Ethos #3 — User Sovereignty).
