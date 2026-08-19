---
name: handover
description: >
  Master orchestrator for a full client handover package when closing a project — builds the
  master index + completeness checklist and drives each sub-skill (closure, tech, API, deployment,
  access, user docs, QA, support, KT, commercial). Use when asked to "prepare a handover",
  "close out this project", "hand over to the client", or "project handover". Run this first to
  plan the package, and again at the end to assemble and verify it.
---

# /handover — Client Handover (master orchestrator)

Use this skill to assemble a **complete client handover package** when a product/service-company project is being closed and ownership is transferred to the client (or to a maintenance/support team).

A handover is not a single document — it is a **package** of deliverables plus a **sign-off**. This skill produces the master index, runs the completeness checklist, and orchestrates the sub-skills that produce each part. Run it first to plan the package, and again at the end to assemble and verify it.

## When to use

- A client project is reaching completion / final delivery.
- A product is being transitioned to the client's own team or a new vendor.
- A contract is closing and you must hand over code, docs, access, and knowledge.
- An internal team is taking over a project from another team.

## The Handover suite

Each sub-skill owns one numbered deliverable. The master index (this skill) links them all.
The cross-cutting rules every sub-skill follows — output location & numbering, secrets → doc
05, actual-state-not-plan, cross-referencing, completeness — are defined once in
[`references/handover-conventions.md`](references/handover-conventions.md).

| # | Deliverable | Skill | Owner concern |
|---|-------------|-------|---------------|
| 00 | Handover Index & Checklist | `/handover` (this) | Project Manager |
| 01 | Project Closure & Acceptance | `/handover-closure` | Project Manager |
| 02 | Technical Architecture | `/handover-tech` | Tech Lead |
| 03 | API & Integrations Reference | `/handover-api` | Backend Lead |
| 04 | Deployment & Infrastructure Runbook | `/handover-deployment` | DevOps |
| 05 | Access & Credentials Transfer | `/handover-access` | DevOps / Security |
| 06 | User & Admin Guide | `/handover-user-docs` | Product / QA |
| 07 | QA Summary & Known Issues | `/handover-qa` | QA Lead |
| 08 | Support & Maintenance Plan | `/handover-support` | Account / Support |
| 09 | Knowledge Transfer Plan | `/handover-kt` | Tech Lead |
| 10 | Commercial & Legal Closure | `/handover-commercial` | Account / Legal |

## Process

1. **Confirm scope of the handover.** Ask the user (or infer from the repo) for:
   - Project / product name, client name, delivery date, version/release being handed over.
   - What is in scope: source code, infra, design assets, third-party accounts, support window.
   - Who the recipients are (client technical contact, client business owner) and who on our side owns the transition.
   - Whether this is a *full* transfer (client takes everything) or a *partial* one (we keep hosting/support).
2. **Scan the repository** for evidence to populate the docs automatically: `README`, `package.json`/`pyproject`/`go.mod`, CI configs (`.github/`, `.gitlab-ci.yml`), `Dockerfile`/compose, infra-as-code, `.env.example`, migration files, test directories, `CHANGELOG`. Note what exists so sub-skills don't re-discover from scratch.
3. **Choose the output location.** Default: a `handover/` directory at the repo root, one markdown file per deliverable using the numbering above (e.g. `handover/01-project-closure.md`). Confirm before writing outside the repo.
4. **Run the sub-skills** the project needs. Not every project needs all ten — skip the irrelevant ones and record *why* in the checklist (e.g. "03 API — N/A, no public API"). For each one run, the sub-skill produces its deliverable and reports back its status.
5. **Assemble this master document (`00`)** from the template below: the index, the completeness checklist, and the final sign-off block.
6. **Verify completeness.** Walk the checklist. Anything `Missing` or `Blocked` must have an owner and a date, or an explicit N/A justification. Do not mark the package complete with silent gaps.

## Output template — `handover/00-handover-index.md`

```markdown
# Client Handover Package — <Project / Product Name>

**Client:** <client name>
**Delivered by:** <company / team>
**Version / release handed over:** <vX.Y.Z / commit>
**Handover date:** <YYYY-MM-DD>
**Prepared by:** <name, role>     **Document status:** Draft | Final

> This package transfers the deliverables, documentation, access, and knowledge
> for <project> to <client>. Acceptance is recorded in section 01.

## 1. Contents

| # | Deliverable | File | Status |
|---|-------------|------|--------|
| 00 | Handover Index & Checklist | `00-handover-index.md` | Done |
| 01 | Project Closure & Acceptance | `01-project-closure.md` | Pending |
| 02 | Technical Architecture | `02-technical-architecture.md` | Pending |
| 03 | API & Integrations Reference | `03-api-integrations.md` | Pending / N/A |
| 04 | Deployment & Infrastructure Runbook | `04-deployment-runbook.md` | Pending |
| 05 | Access & Credentials Transfer | `05-access-credentials.md` | Pending |
| 06 | User & Admin Guide | `06-user-admin-guide.md` | Pending |
| 07 | QA Summary & Known Issues | `07-qa-known-issues.md` | Pending |
| 08 | Support & Maintenance Plan | `08-support-maintenance.md` | Pending |
| 09 | Knowledge Transfer Plan | `09-knowledge-transfer.md` | Pending |
| 10 | Commercial & Legal Closure | `10-commercial-legal.md` | Pending |

## 2. Completeness checklist

Legend: Done · Missing · In progress · Blocked · N/A

| Item | Status | Owner | Due / Notes |
|------|--------|-------|-------------|
| Source code repository transferred / access granted | Missing | | |
| All branches merged or documented; main is the source of truth | Missing | | |
| Architecture & tech-stack documentation delivered | Missing | | |
| API / integration reference delivered | Missing | | |
| Deployment runbook validated by a dry run | Missing | | |
| All credentials & accounts transferred via secure channel | Missing | | |
| Third-party licenses / subscriptions reassigned to client | Missing | | |
| User & admin documentation delivered | Missing | | |
| QA summary, coverage, and known-issues register delivered | Missing | | |
| Support & maintenance terms agreed and signed | Missing | | |
| Knowledge-transfer sessions scheduled / completed | Missing | | |
| Final invoice issued; commercials closed | Missing | | |
| IP / ownership transfer documented | Missing | | |
| Our internal access revoked after the support window | Missing | | |
| Client acceptance / sign-off obtained | Missing | | |

## 3. Recipients & contacts

| Role | Name | Email | Side |
|------|------|-------|------|
| Client business owner | | | Client |
| Client technical contact | | | Client |
| Delivery / account manager | | | Us |
| Tech lead | | | Us |
| Support contact (post-handover) | | | Us / Client |

## 4. Final sign-off

By signing, the client confirms receipt of this handover package and acceptance
of the delivered product, subject to the terms in sections 01, 08, and 10.

| | Name | Signature | Date |
|---|------|-----------|------|
| Client representative | | | |
| Delivery lead (us) | | | |
```

## Quality checklist (definition of done)

- Every deliverable is either present with a link or marked N/A **with a reason**.
- No credential, secret, or password appears in any handover document — section 05 references a secure vault, never inline values (see `/handover-access`).
- Owners and dates exist for every open checklist item.
- The package reflects the *actual* delivered state, not the plan — if tests fail, the QA doc says so; if a feature was descoped, closure says so.
- The master index links resolve to files that exist.

## Notes

- Prefer driving the sub-skills rather than duplicating their content here. This document is the table of contents and the sign-off, not the encyclopedia.
- If the user only wants a subset (e.g. "just the technical handover"), run only those skills and trim the index accordingly.
