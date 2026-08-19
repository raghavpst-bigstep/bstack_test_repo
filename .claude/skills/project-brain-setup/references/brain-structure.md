# Brain Structure

The layout of a project brain, the registers it must contain, and a blank
copy-ready `00_FOUNDATION.md`. Read this before scaffolding in SETUP mode, or
when adding a module.

---

## Folder layout

```
<project>-brain/
├── 00_FOUNDATION.md     ← the spine: registers + sync machinery
├── 01_<domain>.md       ← verified facts, one coherent domain per module
├── 02_<domain>.md
└── ...                  ← (modules >~300 lines get a table of contents on top)
```

One domain per module (architecture, data model, a product area, a workstream).
A module growing past readability is two modules — split it.

---

## The registers in `00_FOUNDATION.md`

Seven sections, in this order. The first four are the standing registers; the
last two (Sync State, Sync Log) are what the auto-update runs on.

1. **Authority hierarchy** — which docs are canonical + the conflict rule
   (higher tier wins). Resolves disagreements without a meeting.
2. **Current state** — live snapshot: phase, what's active now, hard dates,
   what's been ingested. If stale, the brain is lying.
3. **Open Items** — everything unverified: `[ACTIVE]` / `[BLOCKED]` /
   `[SUSPENDED]`, owner, priority. The valve that keeps guesses out of the fact
   modules.
4. **Decisions** — append-only: decision + date + who.
5. **Superseded / Retired** — append-only: what changed and what replaced it.
6. **Sync State** — the watermarks that make each sync a delta.
7. **Sync Log** — append-only record of every run.

---

## Sync State format

The brain's memory of "where did I get to last time." Without it, every sync
re-scans everything.

```markdown
## Sync State
- Last sync: <ISO timestamp>
- Sources:
  | Source | Identifier | Watermark (last seen) |
  |---|---|---|
  | Drive folder | <folder id / link> | <latest file modifiedTime processed> |
  | Jira project | <project key> | <latest issue updated timestamp processed> |
```

The watermark is the high-water mark of what's already been ingested. A sync
asks each source "what changed after this?" and advances the watermark only
after the changes are reconciled — so an interrupted run re-processes rather than
skips.

---

## Sync Log format

Append-only. One entry per run, including no-ops. This is what makes the brain
auditable.

```markdown
## Sync Log
- **<timestamp> — <mode>** — <summary>
  - Ingested: <N facts from M sources, or "none">
  - Changed (superseded): <list or none>
  - Flagged for review: <list or none>  ← removed sources, contradictions
  - New Open Items: <list or none>
  - Watermarks advanced to: <values>
```

Example:
```markdown
- **2026-06-12T09:00Z — sync** — daily run
  - Ingested: 2 facts from 1 modified Drive doc (architecture.md)
  - Changed (superseded): D3 (datastore choice) → D7
  - Flagged for review: none
  - New Open Items: "p95 latency target not confirmed" [ACTIVE], owner Prakhar
  - Watermarks advanced to: Drive 2026-06-12T08:51Z
```

---

## Blank `00_FOUNDATION.md` (copy this on setup)

```markdown
# <Project> — FOUNDATION
*Phase: Initiation · Lead: <name> · Brain created: <date>*

## Authority hierarchy
```
TIER 1 — ALWAYS GOVERNS (conflict resolution authority)
  <canonical doc>    → <module file>
TIER 2 — REFERENCE
  <doc>              → <module file>

CONFLICT RULE: Tier 1 always wins.
```

## Current state
- Phase: <...>
- Active now: <...>
- Hard dates: <...>
- Ingested so far: <...>

## Open Items
| Item | Status | Owner | Priority | Notes |
|---|---|---|---|---|
|  | `[ACTIVE]` |  |  |  |

## Decisions
- (append-only — decision · date · who)

## Superseded / Retired
- (append-only — old → new · date · who)

## Sync State
- Last sync: <none yet>
- Sources:
  | Source | Identifier | Watermark (last seen) |
  |---|---|---|
  | Drive folder |  |  |
  | Jira project |  |  |

## Sync Log
- **<date> — setup** — initial scaffold, no ingest yet
```

Fill the sources and watermarks at the end of SETUP. Every section exists from
day one even if empty — an absent register is a brain that can't be synced.
