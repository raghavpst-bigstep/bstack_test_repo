# Handover suite — shared conventions

Single source for the cross-cutting rules every `/handover-*` sub-skill follows. Cited by
the orchestrator and each sub-skill so the contract lives once and can't drift across the
ten deliverables (standards P-3.1 — reference, don't restate).

## Output location & numbering

- Default output: a `handover/` directory at the repo root, **one markdown file per
  deliverable**, numbered per the master index — `handover/NN-<slug>.md`
  (e.g. `handover/02-technical-architecture.md`). Confirm before writing outside the repo.
- The numbering is fixed (00–10); it is how deliverables cross-reference each other.

## Secrets — never inline

- No credential, secret, password, token, or private key appears in **any** handover
  document. Deliverable **05 (Access & Credentials Transfer)** references a secure vault /
  transfer channel; every other doc that needs a value points to doc 05, never the value.

## Reflect actual state, not the plan

- Every deliverable documents the **as-delivered** reality, not the intended design. If
  tests fail, the QA doc says so; if a feature was descoped, closure says so; if a runbook
  step is unverified, mark it unverified. Silent gaps are a defect.

## Cross-referencing

- Link related deliverables **by number** (e.g. "full schema in doc 03", "env-var sources
  in doc 05"). Don't duplicate another deliverable's content — reference it.

## Scope, evidence & completeness

- **Scan the repo first** for evidence (README, manifests, CI, IaC, `.env.example`,
  migrations, CHANGELOG) so the doc is populated from reality, not invented.
- **Not every project needs every deliverable.** Skip an irrelevant one and record *why*
  in the master checklist (e.g. "03 API — N/A, no public API") — never silently omit.
- Every open checklist item carries an **owner and a date**, or an explicit N/A reason.
