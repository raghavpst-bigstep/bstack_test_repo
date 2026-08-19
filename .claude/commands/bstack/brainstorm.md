---
name: bstack:brainstorm
description: '1. Structured problem exploration before planning — produces a brainstorm doc with approaches, trade-offs, and a recommendation'
argument-hint: '[topic or problem description]'
model: opus
---

# /bstack:brainstorm

> **TASK TRACKING:** Create one task per numbered step before starting. Mark each complete as you go.

Explore the problem space before jumping to implementation. Output: `docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md`.

## MCP usage

**Doc store (pick ONE — detect from prompt context):**

| Signal | Tool to use | Call |
|---|---|---|
| Confluence URL or "Confluence" mentioned | Confluence | `confluence_search` |
| Linear doc URL or "Linear doc" mentioned | Linear | `get_document` |
| Notion URL or "Notion" mentioned | Notion | `notion-search` |
| No signal — default | Notion | `notion-search` |

**Ticket tracker (pick ONE — detect from prompt context):**

| Signal | Tool to use | Call |
|---|---|---|
| Jira URL / issue key (e.g. PROJ-123) | Jira | `jira_search_issues`, `jira_get_issue` |
| Linear URL or issue ID | Linear | `list_issues`, `get_issue` |

**Always available:**

| MCP | When | What for |
|---|---|---|
| Slack | Team context needed | `slack_search_public` for past discussions |
| context7 | Library/framework involved | Verify current capabilities and limitations |

## Steps

### Step 0 — Premise Challenge + Mode Selection

**0A. Premise challenge** — answer these three before exploring approaches:
- Is this the right problem to solve? What is the actual user/business outcome?
- What happens if we ship nothing?
- Is there an existing solution in the codebase that partially or fully covers this?

**0B. Existing code leverage** — `bin/bstack-solutions search "<topic>"` + `grep -r` for related patterns. Flag if this plan rebuilds something that already exists.

**0C. Mode selection** — ask the user via AskUserQuestion (D1):

> **D1 — Brainstorm posture**
> This sets how aggressively we explore scope. EXPAND generates ambitious variants and asks for opt-in on each. FOCUSED stays within the stated scope and picks the cleanest path. MINIMAL strips to minimum viable and defers everything else.
> Stakes: wrong mode wastes time or leaves better options unexplored.
> Recommendation: EXPAND for greenfield topics; FOCUSED for enhancements; MINIMAL for bug workarounds.
>
> - EXPAND — dream big; every scope addition requires explicit opt-in
> - FOCUSED — hold stated scope; explore approaches within it (Recommended for most)
> - MINIMAL — ruthless cut to minimum viable; identify follow-up work

### Step 1 — Intake

Restate the problem in one paragraph. If vague after Step 0, ask ONE clarifying question.

### Step 2 — Search history + Landscape

- Search doc store for prior ADRs, specs, and design docs (Confluence via `confluence_search`, Notion via `notion-search`, or Linear documents via `get_document` — whichever is configured) + last 14 days of `docs/brainstorms/`. If a near-duplicate exists, surface it and stop.
- `bin/bstack-solutions search "<topic>"`
- WebSearch: `"[problem area] alternatives [year]"` and `"[approach keyword] tradeoffs production"`

Synthesize three layers: prior internal learnings, current search results, first-principles reasoning. Flag any eureka — a differentiation opportunity or a trap to avoid.

### Step 3 — Explore 3 approaches

For each approach, write in this order:

1. **Felt experience** — what does the user or developer experience when this ships? Lead here, not with tech.
2. **ASCII diagram** — data flow, state machine, or dependency graph. Required.
3. **Bezos door test** — is this reversible (two-way door) or a commitment (one-way door)?
4. **Completeness score** — `Completeness: X/10` (10 = all edge cases handled, 7 = happy path, 3 = shortcut)
5. **Standard fields** — scope, effort estimate, risks, what compounds vs. what gets thrown away.

Framing guide:

- Weak: "Add caching. Faster responses. Effort: 1 day."
- Strong: "Imagine the cache miss never reaches the DB — the developer never writes another N+1. Redis + cache-aside + TTL policy. Effort: 1 day. Cache invalidation risk: medium."

### Step 4 — Challenge premises (CEO lenses)

List assumptions the user is making. Apply these lenses to each:

- **Inversion reflex** — how does each approach fail, not just how does it win?
- **Leverage obsession** — which approach has an input where small effort produces massive output?
- **Temporal depth** — which decision must be made NOW vs. can be deferred? Think 6-month arc.
- **Proxy skepticism** — are any success metrics self-referential rather than tied to user outcomes?

Mark each assumption: confirm before planning / safe to assume.

### Step 5 — Temporal interrogation

Map decisions by urgency across the implementation horizon:

- **NOW (foundation)** — architecture, data model, contracts. Can't start without these.
- **WEEK-1 (core)** — key integrations, error strategy, critical paths.
- **LATER (polish)** — UI tuning, observability, edge case handling, docs.

This becomes the "Open questions" section with priority labels in the output doc.

### Step 6 — Recommend

Pick one approach and say why. State the non-obvious trade-off — the thing most engineers wouldn't anticipate. Include the **wedge**: narrowest version that ships first and proves value.

### Step 7 — Self-review

Before writing the doc, run an adversarial review on the draft across 4 dimensions:
- **Completeness** — are all 3 approaches covered fairly with equal rigor?
- **Consistency** — does the recommendation follow from the trade-offs shown?
- **Premise challenge** — was the right problem explored, or did we drift?
- **Actionability** — can an engineer start from this without a synchronous meeting?

Fix and re-evaluate up to 2 iterations. If the same issues repeat, note them as "Reviewer concerns" in the doc.

### Step 8 — Write doc

Output to `docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md` with this structure:

```
# Brainstorm: <topic>

## Problem
## Premise Challenge
## Landscape
## Mode: EXPAND | FOCUSED | MINIMAL
## Approaches
  ### Approach 1: <name>
  ### Approach 2: <name>
  ### Approach 3: <name>
## Trade-offs (matrix)
## CEO Lenses
## Recommendation
  - Chosen approach + why
  - Wedge
  - Non-obvious trade-off
## Open Questions
  - NOW: ...
  - WEEK-1: ...
  - LATER: ...
```

### Step 9 — Post-action

Offer to: save ADR to doc store (Confluence / Notion / Linear document — whichever is configured), file a Jira or Linear ticket, post recap to Slack.

---

## Decision format (all AskUserQuestion calls)

```
D<N> — <short title>
ELI10: <2-4 sentence plain-English explanation>
Stakes: <what breaks if we choose wrong>
Recommendation: <option> — <reason>
- Option A: pros / cons
- Option B: pros / cons
Net: <one-sentence tradeoff synthesis>
```

---

## Conventions

- Topic is a few words, kebab-case.
- Recommendation must include the **wedge** — narrowest version that ships first.
- Do not jump to planning — explicit handoff is `/bstack:spec <brainstorm-path>` to pin the contract, then `/bstack:plan`. Skip straight to `/bstack:plan <brainstorm-path>` only when the contract is already unambiguous.
- Lead with the point — name files, functions, approaches, outputs.
- Tie technical choices to user or developer outcomes.
- Be direct about risks; don't soften.
- Avoid: "comprehensive," "robust," "nuanced," "holistic," "delve," "leverage" (as verb), em dashes, filler transitions.
