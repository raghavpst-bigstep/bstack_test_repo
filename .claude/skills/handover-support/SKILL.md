---
name: handover-support
description: >
  Produce the support & maintenance plan for a client handover — warranty/defect-liability terms,
  SLA & response/resolution targets, support channels & hours, escalation matrix, maintenance
  scope (and what's out of scope), transition/hypercare period, and end-of-support exit plan.
  Trigger on "support plan", "maintenance plan", "sla document", or "support and maintenance
  handover".
---

# /handover-support — Support & Maintenance Plan

Produces deliverable **08**: the agreement for what happens *after* go-live — who fixes what, how fast, through which channel, for how long, and what falls outside the deal. This is where most post-handover disputes are prevented.

> **Shared contract** — output location & numbering, secrets → doc 05, actual-state-not-plan, cross-referencing, and completeness rules live in [`handover/references/handover-conventions.md`](../handover/references/handover-conventions.md). Follow it; don't restate it.

## When to use

- You're defining warranty, SLA, support, and maintenance terms for the delivered product.
- There is a transition / hypercare window before the client fully self-supports.

## Inputs to gather

- Contract/SOW support and warranty terms; agreed SLA if any.
- The support model: do we host/support post-handover, or does the client self-support?
- Support hours, channels, and the team handling tickets.
- Severity definitions and target response/resolution times.
- Length of warranty/defect-liability and hypercare period.

## Process

1. State the **warranty / defect-liability** terms: what's covered, for how long, what's excluded.
2. Define **severity levels** and the **SLA** targets for each (response and resolution).
3. Document **support channels, hours, and the ticket process**.
4. Build the **escalation matrix** — who to contact at each tier and when to escalate.
5. Define **maintenance scope**: what ongoing maintenance includes — and explicitly what it does not (new features, third-party cost, content).
6. Define the **transition / hypercare** period and what changes when it ends.
7. Define the **exit plan**: when our access is revoked (ties to doc 05) and how the client fully self-supports.

## Output template — `handover/08-support-maintenance.md`

```markdown
# Support & Maintenance Plan — <Project Name>

**Effective:** <go-live date>  ·  **Warranty period:** <e.g. 60 days>  ·  **Plan ref:** <contract id>

## 1. Warranty / defect liability
- **Covered:** defects in delivered scope reproducible in production.
- **Period:** <duration> from <acceptance date (doc 01)>.
- **Excluded:** new features, changes to scope, issues from client modifications, third-party outages, data/content.

## 2. Severity levels & SLA

| Severity | Definition | Response target | Resolution target |
|----------|------------|-----------------|-------------------|
| S1 — Critical | Production down / data loss | <e.g. 1 business hour> | <e.g. 1 business day> |
| S2 — High | Major feature broken, no workaround | | |
| S3 — Medium | Feature impaired, workaround exists | | |
| S4 — Low | Cosmetic / minor | | |

> Targets apply during support hours (section 3) and within the warranty/contract scope.

## 3. Support channels & hours
| Channel | Use for | Hours | Response within |
|---------|---------|-------|-----------------|
| Ticket system <url> | All issues | <Mon-Fri 9-6 TZ> | per SLA |
| Email <addr> | | | |
| Emergency phone | S1 only | | |

**Ticket process:** <how to raise, required info, triage flow.>

## 4. Escalation matrix

| Tier | Contact | Role | When to engage |
|------|---------|------|----------------|
| L1 | | Support engineer | First response |
| L2 | | Tech lead | L1 cannot resolve / S1-S2 |
| L3 | | Engineering manager | Breach risk / unresolved S1 |
| Account | | Account manager | Commercial / relationship |

## 5. Maintenance scope
**Included:** <bug fixes in scope, dependency/security patches, minor config help.>
**Not included (chargeable / next phase):** <new features, redesigns, third-party fees, data entry, training beyond doc 09.>

## 6. Transition / hypercare
- **Hypercare period:** <e.g. first 30 days> with <heightened response / daily check-ins>.
- **What changes after hypercare:** <standard SLA applies; channels narrow; etc.>

## 7. Exit / end-of-support
- **End date:** <date or "ongoing per renewal">.
- **At end:** our access revoked per doc 05; client self-supports using docs 02-07; optional renewal terms in doc 10.

## 8. Sign-off
| | Name | Date |
|---|------|------|
| Client | | |
| Account manager (us) | | |
```

## Quality checklist

- Severity definitions are concrete enough to classify a real ticket without argument.
- "Not included" is explicit — the biggest source of post-handover disputes.
- The warranty clock is anchored to the acceptance date in doc 01.
- The exit/revocation date is consistent with doc 05's revocation plan.
- Renewal/commercial terms cross-reference doc 10 rather than inventing numbers.
