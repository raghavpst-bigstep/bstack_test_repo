---
name: project-brain-setup
description: >
  Stand up a project's "brain" — the verified knowledge base the rest of bstack
  queries — and keep it continuously current. Use this skill whenever someone
  wants to create a brain for a project, point a brain at a Drive folder or Jira
  project, ingest source material into a brain, or refresh/sync an existing
  brain. Trigger on phrases like "set up the brain", "create a brain for
  <project>", "ingest this Drive folder", "sync the brain", "the brain is out of
  date", "re-ingest", or whenever new project material has landed and the brain
  needs to reflect it. This skill does TWO things: (1) cold-start setup —
  scaffold a brain and ingest existing material once; (2) sync — detect what
  changed in the sources and update the brain automatically, processing only the
  delta. Use this skill even if the user only says "the brain" without saying
  "set up" or "sync" — figure out from context whether it's a cold start or a
  refresh, and run the right mode.
---

# Project Brain Setup

A **brain** is the verified knowledge base for one project — the thing anyone
(PM, dev, QA, a new joiner) queries to learn "what is true about this project
right now." This skill builds it and keeps it true.

It does exactly two jobs:

- **Setup (cold start):** scaffold an empty brain and ingest whatever already
  exists, once.
- **Sync (warm, automatic):** detect what changed in the sources since the last
  run and update the brain — only the delta, never a full re-ingest.

The whole skill exists to protect one locked rule:

> **The brain holds verified, confident project facts only.**

Vague or contradictory material degrades every downstream query, so nothing
enters the brain as fact unless it is **confirmed**, **decided**, or
**observed**. Everything else is logged as an Open Item, not a fact. This rule
applies identically on setup *and* on every automatic sync — an update is not a
licence to relax it.

---

## Decide the mode first

```
Does a brain already exist for this project?
  NO  → SETUP mode  (scaffold + initial ingest)
  YES → SYNC mode   (delta update)
```

If unsure, check for `00_FOUNDATION.md` in the brain folder. Present → SYNC.
Absent → SETUP. Never run SETUP over an existing brain — it would clobber the
registers and history.

---

## What the brain looks like

A folder of Markdown modules. `00_FOUNDATION.md` holds the spine; topic modules
hold the verified facts. The full skeleton and a blank, copy-ready template are
in `references/brain-structure.md` — read it before scaffolding.

```
<project>-brain/
├── 00_FOUNDATION.md     ← authority hierarchy · current state · sync state ·
│                          Open Items · decisions · superseded · sync log
├── 01_<domain>.md       ← verified facts, one coherent domain per module
├── 02_<domain>.md
└── ...
```

`00_FOUNDATION.md` carries the standing registers, including the two the
auto-update depends on:
- **Sync State** — the watermarks (last-seen Drive revision / Jira timestamp)
  that make each sync a delta, not a re-scan.
- **Sync Log** — append-only record of what each run ingested, changed, or
  flagged.

---

## SETUP mode (cold start)

Run once, when there is no brain yet.

1. **Confirm the sources.** Get the project's Drive folder (the source of truth)
   and, if it tracks work there, the Jira project. Record their IDs — they go
   into Sync State.
2. **Scaffold.** Create the brain folder and `00_FOUNDATION.md` from the
   template in `references/brain-structure.md`. All four registers exist from
   day one, even if empty.
3. **Ingest existing material.** Pull from the sources and distil to verified
   facts, running every statement through the verified-facts gate
   (`references/sync-protocol.md` → "The gate"). Organise facts into topic
   modules — one coherent domain each; split anything growing past readability.
4. **Seed the registers.**
   - Confirmed/observed facts → topic modules (each cites its source).
   - Decisions already made → decision log (with date + who).
   - Everything unverified → Open Items, flagged with owner and priority.
5. **Set the watermarks.** Record the current Drive revision / Jira timestamp in
   Sync State so the first sync knows where to start.
6. **Write the first Sync Log entry:** "Initial setup — ingested <N> sources."

**Done when:** a new joiner can read `00_FOUNDATION.md` and the modules and
correctly state what the project is, what's decided, and what's still open —
without asking anyone.

---

## SYNC mode (the automatic update)

Run on every trigger after setup. The full procedure — change detection,
distillation, conflict handling, watermark advance — is in
`references/sync-protocol.md`. The shape:

1. **Read Sync State** — the last-seen watermarks.
2. **Detect the delta** — ask each source what changed since its watermark
   (files added/modified/removed in Drive; tickets created/updated in Jira).
   Nothing changed → log "no-op" and stop. This is what makes frequent
   automatic runs cheap.
3. **Distil the delta** through the verified-facts gate — exactly as in setup.
4. **Reconcile** into the brain:
   - New fact → add to the right module.
   - Changed fact → **supersede** the old one (append a superseded entry, add the
     new fact); never silently overwrite.
   - Source removed → flag the affected facts for review; don't auto-delete.
   - New information contradicts a recorded **decision** → do **not** auto-resolve.
     Flag it as a `[BLOCKED]` Open Item for a human at the next sync. A
     contradiction means something is no longer verified.
   - Still-unverified material → Open Items.
5. **Update Current State** and the registers.
6. **Advance the watermarks** to the new source state.
7. **Append a Sync Log entry** — what was ingested, changed, superseded, flagged.

**Done when:** the brain reflects the sources as of this run, the watermarks have
moved forward, and the Sync Log says exactly what happened — so the run is
auditable and the next run starts from the right place.

---

## How "automatic" actually happens

A Markdown skill defines the *logic* above; it can't schedule itself. To make
updates automatic, a **trigger** invokes this skill in SYNC mode. Three options,
in `references/sync-protocol.md` → "Triggering":

- **Scheduled run (recommended default)** — a daily job runs the sync. This lines
  up with the daily / alternate-day tracking cadence and means the Tuesday sync
  always opens against a current brain.
- **On-demand** — someone says "sync the brain."
- **Event-driven (V2 direction)** — a Drive change notification or Jira webhook
  fires a sync. Needs the connector to emit events; document now, wire later.

Whatever the trigger, the delta + watermark design means an automatic run does
the minimum work and stays idempotent — running it twice with no source change
is a safe no-op.

---

## Hard rules (do not bend on a sync)

1. **Verified facts only** — on setup and on every sync. Unsure → Open Item.
2. **Delta, not re-scan** — always work from the watermark; never re-ingest the
   whole source on a routine sync.
3. **Supersede, never overwrite** — changed facts and decisions are append-only
   history.
4. **Contradictions go to a human** — never auto-resolve a conflict with a
   recorded decision; flag it.
5. **Every run writes a Sync Log entry** — even a no-op. An unlogged sync is an
   unauditable brain.
6. **Drive is the source of truth** — ingest from it; don't paste content the
   folder already holds, reference it.

---

## Reference files

- `references/brain-structure.md` — the brain skeleton, the four registers,
  Sync State and Sync Log formats, and a blank copy-ready `00_FOUNDATION.md`.
- `references/sync-protocol.md` — the verified-facts gate, change detection,
  conflict handling, watermark mechanics, and the three triggering options.
