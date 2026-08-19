---
name: handover-kt
description: >
  Produce the knowledge-transfer plan for a client handover — KT session schedule & agendas,
  walkthrough scripts, recordings/index, code & domain ownership map, "tribal knowledge" capture,
  and a post-KT readiness checklist. Trigger on "knowledge transfer", "kt plan", "kt sessions",
  or "knowledge transfer handover".
---

# /handover-kt — Knowledge Transfer Plan

Produces deliverable **09**: the plan to move knowledge from the heads of the original team into the receiving team — through scheduled sessions, walkthroughs, and captured tribal knowledge. Documents (02-08) cover the *what*; KT covers the *understanding*.

> **Shared contract** — output location & numbering, secrets → doc 05, actual-state-not-plan, cross-referencing, and completeness rules live in [`handover/references/handover-conventions.md`](../handover/references/handover-conventions.md). Follow it; don't restate it.

## When to use

- A receiving team (client's engineers or new vendor) must be brought up to speed.
- You need to schedule and structure live KT sessions and capture what isn't written down.

## Inputs to gather

- Who is receiving knowledge (names, roles, current familiarity).
- The areas that need transfer (frontend, backend, infra, domain logic, ops).
- Availability for sessions and how they'll be recorded.
- The non-obvious "tribal knowledge" only the original team holds.

## Process

1. Define **KT objectives** and the **audience** with their starting knowledge level.
2. Build a **session plan**: a sequenced set of sessions, each with topic, owner, audience, duration, and prerequisites.
3. Write **agendas / walkthrough scripts** for each session so they're repeatable.
4. Plan **recording & artifact capture** — where recordings, notes, and Q&A logs are stored.
5. Build the **ownership map**: who currently owns each area and who takes it over.
6. Capture **tribal knowledge**: gotchas, history, "why it's like this," people to ask — the stuff not in any doc.
7. Define a **readiness checklist** — how you'll know KT succeeded (receiving team can do X unaided).

## Output template — `handover/09-knowledge-transfer.md`

```markdown
# Knowledge Transfer Plan — <Project Name>

## 1. Objectives & audience
**Goal:** by end of KT, the receiving team can <deploy, debug, extend> without us.

| Receiver | Role | Current familiarity | Focus areas |
|----------|------|---------------------|-------------|
| | | low/med/high | |

## 2. Session schedule

| # | Session | Topic | Owner (us) | Audience | Duration | Prereqs | Date |
|---|---------|-------|------------|----------|----------|---------|------|
| 1 | Architecture overview | doc 02 | | | 60m | read doc 02 | |
| 2 | Codebase walkthrough | key modules | | | 90m | session 1 | |
| 3 | Deploy & ops | doc 04 | | | 60m | | |
| 4 | Data & integrations | doc 03 | | | 60m | | |
| 5 | Admin & support | docs 06, 08 | | | 45m | | |
| 6 | Q&A / shadowing | open | | | 60m | all above | |

## 3. Session agendas / walkthrough scripts
### Session 2 — Codebase walkthrough
- Modules to cover: <list>
- Live demo: clone → run → make a trivial change → test (per doc 02 section 7)
- Hands-on: receiver implements a small change with us watching
- Outcome: receiver can navigate the repo and run it locally

<Repeat per session.>

## 4. Recordings & artifacts
| Session | Recording | Notes / Q&A | Location |
|---------|-----------|-------------|----------|
| | | | |

## 5. Ownership map

| Area | Current owner (us) | New owner (client) | Transferred? |
|------|--------------------|--------------------|--------------|
| Frontend | | | Pending |
| Backend / API | | | Pending |
| Infrastructure / deploy | | | Pending |
| Data / migrations | | | Pending |
| Domain / business logic | | | Pending |

## 6. Tribal knowledge
- <Gotcha / historical decision / "don't touch X because Y" / who to ask about Z.>

## 7. Readiness checklist
- Receiving team ran the app locally unaided.
- Receiving team deployed to staging unaided.
- Receiving team resolved a sample issue unaided.
- All sessions delivered and recorded.
- Open questions logged and answered.
```

## Quality checklist

- Sessions are sequenced with prerequisites — architecture before code before ops.
- Each session has a concrete outcome and at least one hands-on element, not just a lecture.
- The ownership map leaves no area without a named new owner.
- Tribal knowledge captures the things deliberately *not* in the formal docs.
- Readiness is demonstrated by the receiver *doing*, not by attendance.
