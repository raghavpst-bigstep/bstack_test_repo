---
name: bstack:plan
description: '2. Implementation plan with learnings + brainstorm lookup. Outputs a plan file + ADR if needed.'
argument-hint: '[feature/bug description or path to brainstorm]'
model: opus
---

# /bstack:plan

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.

Produce a structured plan in `docs/plans/YYYY-MM-DD-<topic>-plan.md`. The plan is the input to `/bstack:implement`.

## MCP usage

**Doc store (pick ONE — detect from prompt context):**

| Signal | Tool to use | Call |
|---|---|---|
| Confluence URL or "Confluence" mentioned | Confluence | `confluence_search`, `confluence_get_page` |
| Linear doc URL or "Linear doc" mentioned | Linear | `get_document` |
| Notion URL or "Notion" mentioned | Notion | `notion-search` |
| No signal — default | Notion | `notion-search` |

**Ticket tracker (pick ONE — detect from prompt context):**

| Signal | Tool to use | Calls |
|---|---|---|
| Jira URL / issue key (e.g. PROJ-123) | Jira | `jira_get_issue` (load), `jira_create_issue` (follow-ups) |
| Linear URL or issue ID | Linear | `get_issue` (load), `create_issue` (follow-ups) |

**Always available:**

| MCP | When | What for |
|---|---|---|
| context7 | Plan involves libraries | `resolve-library-id` → `query-docs` for current API patterns |

---

## Step 0 — Scope Gate + Scope Challenge

**0A. Scope gate (hard stop)** — confirm the planning target via AskUserQuestion (D1) before any analysis:
- A feature or bug description (typed prompt)
- A Jira ticket or Linear issue (URL or ID — fetch via MCP before proceeding)
- A Confluence page or Linear document (URL — fetch via MCP and treat as spec)
- A spec doc (`docs/specs/`)
- A brainstorm doc (`docs/brainstorms/`)
- A specific file/directory/path

If a ticket or doc link is provided, fetch it via MCP first — then treat its content as authoritative scope:
- Jira ticket → `jira_get_issue` — description + acceptance criteria
- Linear issue → `get_issue` — description + linked docs
- Confluence page → `confluence_get_page` — extract contracts and constraints; treat as spec/ADR
- Linear document → `get_document` — extract approach and decisions; treat as design doc

**0B. Scope challenge** — run these six checks before writing anything:

1. **Existing coverage** — does partial or full code already exist? Search `bin/bstack-solutions`, grep codebase. Flag if this plan rebuilds something.
2. **Minimum viable scope** — what is the smallest change that satisfies the outcome? State it explicitly.
3. **Complexity trigger** — if the plan touches 8+ files or introduces 2+ new classes/services, pause with AskUserQuestion (D2) before proceeding. Ask: "Is this complexity justified or is the scope too large?"
4. **Framework patterns** — search context7 and existing codebase for built-in solutions before proposing custom implementations.
5. **TODOS.md blockers** — check `TODOS.md` for items that would block this plan.
6. **New artifact types** — if the plan introduces a new artifact type (new queue, new event, new external call), confirm a distribution/consumer pipeline exists or is planned.

**0C. Rollback path** — state the rollback strategy before any tasks are written. Required, not optional.

---

## Steps

0. **R.I.C.E. gate (new-feature only)** — if the plan is for *new* work (new screen / feature / endpoint / component / hook / service / repository) AND a `## R — Role` / `## I — Intent` / `## C — Context` / `## E — Enforcement` block is not already in the conversation, run `bin/bstack-rice path` to resolve the SKILL.md. If one resolves, invoke `/bstack:rice` first and embed the emitted R/I/C/E block as the first section of the plan file (above Tasks). If `bin/bstack-rice path` exits non-zero, offer `/bstack:rice-init` to the user but do **not** block — continue planning without the block, noting that the protocol is absent. For *modifications* to existing code, skip this step.

1. **Resolve input** — if arg is a spec path (`docs/specs/`), load it and treat its contracts + acceptance criteria as authoritative. If arg is a brainstorm/office-hours path, load it. Otherwise search the last 14 days of `docs/specs/` then `docs/brainstorms/` for a match; offer to `/bstack:spec` or `/bstack:brainstorm` first if none found.

2. **Knowledge-first** — run `bin/bstack-solutions search "<topic keywords>"` for ranked hits (`Read` only the top match), then read `.claude/rules/critical-patterns.md` and the relevant per-app `CLAUDE.md`. If a prior decision is being reversed, surface it explicitly — do not silently re-litigate.

3. **Identify affected apps / libs** — list each, note DDD boundary crossings, flag any new `api-interfaces` types needed. Apply EM patterns to each:
   - **Blast radius** — what breaks if this change goes wrong? How many users / services / teams?
   - **Reversibility** — is this a one-way door (data migration, API removal, schema drop) or two-way? One-way decisions require explicit sign-off in the plan.
   - **Two-week smell test** — would this code embarrass you at code review in two weeks? Flag shortcuts now.
   - **Ownership in production** — who is on call for this code path? Name the team.

4. **Architecture diagram** — required for any change that touches more than one service or adds a new data flow. ASCII art: show request path, data writes, async triggers, failure paths.

   ```
   Example:
   Client → API → [Service A] → DB
                             → Queue → [Worker B] → External API
                                                  → (retry / DLQ on failure)
   ```

5. **Tasks** — numbered, each with:
   - Files to create / Files to modify
   - Tests required
   - Dependencies on other tasks
   - Parallelizable vs. sequential
   - **Completeness score** for the task: `Completeness: X/10` (10 = all edge cases, 7 = happy path, 3 = shortcut)

6. **Data layer plan** — if migrations needed, link to `/bstack:migrate`. Note reversibility and locking strategy for large tables. One-way schema changes require a separate rollback strategy.

7. **Unit test table** — one row per public behavior change:

   | Behavior | File | Type | Edge cases covered |
   |---|---|---|---|
   | ... | ... | unit/integration/e2e | ... |

   Completeness is non-negotiable. AI makes full coverage cheap — prefer complete over shortcut.

8. **ADR check** — if the plan changes a system contract, domain boundary, or reverses a prior decision, write an ADR draft and save to the team's doc store (Confluence via `confluence_create_page`, or Notion via `notion-create-page`, whichever is configured).

9. **Risks** — top 3, each with:
   - What could go wrong
   - Blast radius if it does
   - Mitigation
   - Detection (how will we know it went wrong in production?)

10. **Write plan file** — output to `docs/plans/YYYY-MM-DD-<topic>-plan.md` with this structure:

    ```
    # Plan: <topic>

    ## Input
    ## Rollback Path
    ## Scope Decisions (min viable + complexity justification if triggered)
    ## Affected Apps / Libs
    ## Architecture Diagram
    ## Tasks (numbered)
    ## Data Layer
    ## Test Coverage Table
    ## Auth & Data-Safety Impact (if applicable)
    ## Risks
    ```

    Post-actions: link or update Jira/Linear ticket, post Slack summary.

---

## Decision format (all AskUserQuestion calls)

```
D<N> — <short title>
ELI10: <2-4 sentence plain-English explanation>
Stakes: <what breaks if we choose wrong>
Recommendation: <option> — <reason>
- Option A: ✅ pros / ❌ cons
- Option B: ✅ pros / ❌ cons
Net: <one-sentence tradeoff synthesis>
```

---

## Conventions

- Tasks are sized so each can be implemented by one agent in ≤ 30 min.
- Never plan without stating the **rollback path** (Step 0C).
- Auth & data-safety impact is a required section if the change touches user-facing data.
- One-way / irreversible decisions (schema drops, API removals, data migrations) must be explicitly labeled and require sign-off.
- ASCII diagrams are required for multi-service changes. Stale diagrams are actively misleading — update them as part of the plan.
- Name files, functions, line numbers, commands — not abstract descriptions.
- Tie technical choices to user or developer outcomes.
- Avoid: "comprehensive," "robust," "holistic," "nuanced," "delve," "leverage" (as verb), em dashes, filler transitions.
