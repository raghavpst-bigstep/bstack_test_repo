---
name: handover-commercial
description: >
  Produce the commercial & legal closure document for a client handover — final billing/invoice
  summary, IP & ownership transfer, license/data ownership, contract closure & deliverable
  acceptance reference, data-protection/NDA obligations, renewal/next-phase options, and a project
  retrospective. Trigger on "commercial closure", "final invoice handover", "ip transfer", or
  "contract closure".
---

# /handover-commercial — Commercial & Legal Closure

Produces deliverable **10**: the commercial and legal wrap-up — money, ownership, obligations, and the relationship's next step. Pairs with the project-management closure (doc 01): 01 records *acceptance of the work*; 10 records *settlement of the deal*.

> This skill drafts business/legal documentation. It is **not legal advice** — flag that
> contract, IP, and data-protection terms should be reviewed by the company's legal owner
> before sending. Use the actual contract as the source of truth, not assumptions.

> **Shared contract** — output location & numbering, secrets → doc 05, actual-state-not-plan, cross-referencing, and completeness rules live in [`handover/references/handover-conventions.md`](../handover/references/handover-conventions.md). Follow it; don't restate it.

## When to use

- Final billing and commercial settlement at project close.
- IP/ownership of the delivered work transfers to the client.
- You need to record remaining legal obligations (NDA, data protection) and renewal options.

## Inputs to gather

- The contract/SOW: payment schedule, IP clauses, NDA, data-protection terms, renewal terms.
- Invoices issued/paid and any outstanding amount.
- What IP transfers vs. what we retain (our pre-existing tools, open-source components and their licenses).
- Data-protection obligations (e.g. who holds personal data, deletion duties).

## Process

1. Summarize the **commercials**: contract value, invoices issued/paid, final/outstanding amount, and the trigger for final payment (usually acceptance in doc 01).
2. Document the **IP & ownership transfer**: what becomes the client's, what we retain, and third-party/open-source components with their licenses (so the client knows their obligations).
3. Record **license & data ownership**: who owns the data, accounts, and content (ties to doc 05).
4. State **remaining legal obligations**: NDA survival, confidentiality, data-protection/retention/deletion duties, post-project data handling.
5. Reference **contract closure**: deliverables accepted (doc 01), warranty (doc 08), and formal contract completion.
6. Present **renewal / next-phase options** if the relationship continues.
7. Add a short **retrospective** — what went well, what to improve — for internal learning and the client relationship.

## Output template — `handover/10-commercial-legal.md`

```markdown
# Commercial & Legal Closure — <Project Name>

**Client:** <name>  ·  **Contract / SOW ref:** <id>  ·  **Closure date:** <date>

> Not legal advice. To be reviewed by <legal owner> before issue. Contract is the source of truth.

## 1. Commercial summary
| Item | Amount | Status |
|------|-------:|--------|
| Contract value | | |
| Invoiced to date | | |
| Paid to date | | |
| Final invoice | | trigger: acceptance (doc 01) |
| Outstanding | | due <date / terms> |

## 2. IP & ownership transfer
- **Transferred to client:** <source code, designs, deliverables in scope> upon <final payment / acceptance>.
- **Retained by us:** <pre-existing IP, internal tools, reusable frameworks>.
- **Third-party / open-source components:**

| Component | License | Obligation on client |
|-----------|---------|----------------------|
| | MIT / Apache-2.0 / ... | attribution / copyleft / none |

## 3. License & data ownership
- **Data owner:** <client>.  **Hosting/accounts:** transferred per doc 05.
- **Content / media licenses:** <stock assets, fonts — transferable? per-seat?>.

## 4. Remaining legal obligations
- **Confidentiality / NDA:** <survives for X / ongoing>.
- **Data protection:** <our deletion duties, retention period, sub-processor list>.
- **Post-project data handling:** <we delete client data by <date>; confirmation to be sent>.

## 5. Contract closure
- Deliverables accepted: see doc 01 sign-off.
- Warranty / support: see doc 08.
- Contract status: Complete / Pending final payment / Rolling into <renewal>.

## 6. Renewal / next-phase options
| Option | Scope | Commercial model | Decision by |
|--------|-------|------------------|-------------|
| Support retainer | per doc 08 | <monthly> | |
| Phase 2 | <features> | <T&M / fixed> | |

## 7. Retrospective (internal + shareable summary)
- **Went well:** <...>
- **To improve:** <...>
- **Reusable assets created:** <...>

## 8. Sign-off
| | Name | Date |
|---|------|------|
| Client (commercial) | | |
| Account manager (us) | | |
| Legal reviewed (us) | | |
```

## Quality checklist

- The final-payment trigger matches the acceptance event in doc 01.
- IP section distinguishes what transfers from what we retain, and lists OSS license obligations.
- Data-protection/deletion duties have concrete dates, not vague intentions.
- The "not legal advice / legal review required" caveat is present and a reviewer is named.
- Numbers come from actual invoices/contract, never invented.
