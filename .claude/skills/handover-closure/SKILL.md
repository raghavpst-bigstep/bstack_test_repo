---
name: handover-closure
description: >
  Produce the project closure & acceptance document for a client handover — scope-vs-delivered
  matrix, deliverables list, milestones, acceptance criteria sign-off, descoped/deferred items,
  and formal closure sign-off. Trigger on "project closure", "client acceptance document",
  "closure report", or "project sign-off".
---

# /handover-closure — Project Closure & Acceptance

Produces deliverable **01** of the Handover package: the document that formally closes the project and records the client's acceptance of what was delivered. This is the project-management spine of the handover — it states what was agreed, what was delivered, what changed, and obtains sign-off.

> **Shared contract** — output location & numbering, secrets → doc 05, actual-state-not-plan, cross-referencing, and completeness rules live in [`handover/references/handover-conventions.md`](../handover/references/handover-conventions.md). Follow it; don't restate it.

## When to use

- The project is complete and you need a formal closure / acceptance record.
- You must reconcile the original scope/SOW against what shipped.
- The client needs an acceptance document to sign before final billing.

## Inputs to gather

- Original scope / SOW / proposal, agreed milestones, acceptance criteria.
- The final delivered feature set (scan `CHANGELOG`, release notes, issue tracker, `README`).
- Any change requests, descoped items, or deferred work and the reason for each.
- Outstanding items at closure and how they are dispositioned (warranty, next phase, won't-do).

## Process

1. Reconstruct the **agreed scope** from the SOW/proposal. List each committed deliverable.
2. Map each to **delivered status**: Delivered / Delivered-with-changes / Descoped / Deferred. Cite where it lives (URL, module, screen).
3. Capture **change history** — change requests approved during the project and their impact.
4. State **acceptance criteria** and whether each is met; attach evidence (QA doc 07, demo, UAT result).
5. List **open items at closure** with disposition and owner.
6. Produce the sign-off block. Acceptance here is what unblocks final invoice (doc 10).

## Output template — `handover/01-project-closure.md`

```markdown
# Project Closure & Acceptance — <Project Name>

**Client:** <name>  ·  **SOW / contract ref:** <id>  ·  **Closure date:** <YYYY-MM-DD>
**Project duration:** <start> → <end>  ·  **Final release:** <vX.Y.Z>

## 1. Executive summary
<2–4 sentences: what was built, the outcome, and the state at handover.>

## 2. Scope delivered vs. agreed

| # | Agreed deliverable (per SOW) | Status | Where it lives | Notes |
|---|------------------------------|--------|----------------|-------|
| 1 | | Delivered | | |
| 2 | | Delivered with changes | | CR-### |
| 3 | | Descoped | | reason / agreement |
| 4 | | Deferred to next phase | | |

## 3. Milestones

| Milestone | Planned | Actual | Status |
|-----------|---------|--------|--------|
| | | | |

## 4. Change requests

| CR | Description | Date approved | Scope/cost/timeline impact |
|----|-------------|---------------|----------------------------|
| | | | |

## 5. Acceptance criteria

| Criterion | Met? | Evidence (QA / UAT / demo) |
|-----------|------|----------------------------|
| | Yes / No | |

## 6. Open items at closure

| Item | Severity | Disposition (warranty / next phase / won't-fix) | Owner | Target |
|------|----------|--------------------------------------------------|-------|--------|
| | | | | |

## 7. Acceptance & sign-off
The client confirms the deliverables in section 2 have been received and accepted,
subject to the open items in section 6 and the support terms in document 08.

| | Name | Signature | Date |
|---|------|-----------|------|
| Client business owner | | | |
| Delivery / account manager (us) | | | |
```

## Quality checklist

- Every SOW deliverable appears in section 2 — no silent omissions.
- Descoped/deferred items name the agreement or CR that authorized the change.
- Acceptance criteria link to real evidence, not assertions.
- Open items each have a disposition and owner; "TBD" is not a disposition.
- Section 7 acceptance is consistent with the billing trigger in document 10.
