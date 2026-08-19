# Sync Protocol

The mechanics of keeping a brain current: the verified-facts gate, change
detection against watermarks, conflict handling, and how to make the update
automatic. Read this when running SYNC mode or wiring a trigger.

---

## The gate (runs on setup AND every sync)

Before any statement enters a fact module, route it:

```
CONFIRMED  (client / project lead said so)        → fact module · cite who + when
DECIDED    (a choice was made)                     → decision log · date + who
OBSERVED   (measured / shipped / in a real log /   → fact module · cite the source
            the current content of a source doc)
none of the above                                  → Open Items · flagged
```

The current content of a Drive doc counts as **observed** — it's the real,
current artifact — so a doc edit legitimately produces an updated fact (via
supersession, below). But an idea, a "maybe", or anything contradicting a
recorded decision is **not** a fact. When unsure: Open Item. It is never wrong
to flag something unverified; it is always wrong to record a guess as fact.

---

## Change detection (the delta)

A sync never re-scans everything. It asks each source "what changed since the
watermark in Sync State?"

**Drive:**
- List files in the project folder with their `modifiedTime`.
- The delta = files whose `modifiedTime` is after the Drive watermark, plus any
  file present last run but missing now (a removal).
- Process only those. Advance the watermark to the newest `modifiedTime`
  processed — only after reconciliation succeeds.

**Jira (if the project tracks work there):**
- Query issues `updated >= <Jira watermark>`.
- The delta = created or updated issues since then.
- Advance the watermark to the newest `updated` processed.

If both deltas are empty → write a no-op Sync Log entry and stop. This is what
makes a daily (or more frequent) automatic run cheap.

---

## Reconciliation

For each item in the delta, after the gate:

| Situation | Action |
|---|---|
| New verified fact | Add to the right module. |
| Existing fact changed | Append a **superseded** entry, add the new fact. Never overwrite. |
| Source doc/ticket removed | **Flag** affected facts for review in Open Items `[BLOCKED]`. Don't auto-delete — a missing source isn't proof the fact is false. |
| New info contradicts a recorded **decision** | **Do not auto-resolve.** Raise a `[BLOCKED]` Open Item for a human at the next sync. |
| Still unverified | Open Items, flagged with owner + priority. |

Then update **Current State**, advance **watermarks**, append a **Sync Log**
entry. Always in that order — Current State and the registers reflect the new
truth; the watermark records that you've consumed the delta; the log makes it
auditable.

### Why contradictions go to a human

The verified-facts rule means the brain only holds confident facts. If a new
source says X and a recorded decision says not-X, the brain can no longer be
confident about either — so neither is auto-written as fact. Flagging it is the
correct, conservative behaviour. Auto-picking a winner is exactly the
"AI confusion from contradictory input" that the verified-facts rule was made to prevent.

---

## Idempotency

The delta + watermark design makes a sync safe to run repeatedly:
- No source change → no-op.
- Watermarks advance only after successful reconciliation, so an interrupted run
  re-processes its delta next time rather than skipping it.
- Supersession is append-only, so re-processing the same change doesn't corrupt
  history (and a duplicate-detection check on the change id avoids a duplicate
  superseded entry).

Running the sync twice in a row with nothing new must leave the brain identical.
If it doesn't, the sync isn't idempotent — fix that before trusting automation.

---

## Triggering — how the sync runs automatically

The skill defines the logic; a trigger invokes it in SYNC mode. Pick per
project; the recommended default is the scheduled run.

### 1. Scheduled run (recommended default)

A job runs the sync on a fixed cadence (e.g., daily, early morning).
- Lines up with the daily / alternate-day tracking cadence.
- Guarantees the Tuesday sync opens against a current brain.
- Wire it with whatever runner the team uses (a cron in the bstack runner, a
  scheduled task that invokes the skill against the project folder). The runner,
  not the Markdown, owns the schedule.

### 2. On-demand

Someone says "sync the brain" (or it's run before a status report). Always
available regardless of any schedule; the same SYNC logic runs.

### 3. Event-driven (V2 direction)

A Drive change notification (push/watch on the folder) or a Jira webhook fires a
sync the moment a source changes. Closest to "real-time," but needs the
connector to emit change events. Document as the V2 target; don't block V1 on it
— scheduled + on-demand cover the need.

> Be honest with users about this boundary: a `.md` skill cannot poll Drive by
> itself. "Automatic" means a scheduler or event source has been wired to invoke
> this skill. Until that wiring exists, the brain updates whenever someone runs
> the sync on-demand — which is still correct, just not hands-free.

---

## Sync checklist (quick)

1. Read Sync State watermarks.
2. Pull Drive + Jira deltas; empty → no-op log, stop.
3. Gate every delta item.
4. Reconcile (new / changed→supersede / removed→flag / contradiction→flag /
   unverified→Open Item).
5. Update Current State + registers.
6. Advance watermarks.
7. Append Sync Log entry.
