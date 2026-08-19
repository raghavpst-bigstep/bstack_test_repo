---
name: bstack:office-hours
description: 'YC-style product interrogation — challenge premises, extract real capabilities, recommend a wedge before any planning'
argument-hint: '[product idea, feature brief, or "this branch"]'
model: opus
---

# /bstack:office-hours

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.

Used **before** `/bstack:brainstorm` for anything ambiguous or big. Job: stop bad framing early. Output: a tight design doc that downstream commands consume. If `STRATEGY.md` exists, read it first — the idea must serve a current bet or it's a candidate for the not-doing list.

## Steps

1. **Intake** — restate the user's idea in one paragraph. If they framed it as a solution ("I want to build X"), restate as a problem ("the pain is Y").
2. **Forcing questions (ask 6, one at a time)**:
   1. What's the actual pain — give a concrete recent example, not a hypothetical.
   2. Who experiences it, how often, and how do they work around it today?
   3. What does "solved" look like — what would change in their behavior tomorrow?
   4. What's the narrowest version that demonstrably solves it (the **wedge**)?
   5. What's already been tried in our workspace / docs / Linear that addresses this?
   6. Why now — what changed that makes this worth doing this quarter?
3. **Reframe** — propose a new framing in the form: "You said X, but what you described is Y." Get explicit agree/disagree.
4. **Extract capabilities** — list 3–7 capabilities the user is implicitly asking for. Surface ones they didn't realize they described.
5. **Challenge premises** — list 3–5 assumptions in their framing. For each: agree / disagree / adjust.
6. **Three approaches** — for each: scope, effort (S/M/L), what compounds, what gets thrown away if wrong.
7. **Recommend** — pick one. Include the wedge: smallest demoable slice that ships in ≤ 2 weeks.
8. **Write doc** — `docs/office-hours/YYYY-MM-DD-<topic>.md`. Sections: Pain · Forcing answers · Reframe · Capabilities · Premises · Approaches · Recommendation + Wedge · Open questions.
9. **Handoff** — explicit: `/bstack:brainstorm` (if more divergence needed) OR `/bstack:spec <this-doc-path>` (if the approach is settled and only the contract needs nailing down) OR `/bstack:plan <this-doc-path>` (if both approach and contract are already clear).

## MCP usage

| MCP | When | What for |
|---|---|---|
| Linear | Always | Find related tickets / past attempts |
| Notion | Always | `notion-search` for ADRs / specs on the topic |
| Slack | If team context helps | `slack_search_public` for past discussions |

## Hard rules

- Do not propose implementation details. This command stops at "what + why + wedge".
- If the user can't give a concrete recent example of the pain (step 2 q1), the problem isn't real yet — say so and stop.
