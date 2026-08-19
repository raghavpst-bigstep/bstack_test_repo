---
name: handover-access
description: >
  Produce the access & credentials transfer document for a client handover — inventory of all
  accounts/repos/cloud/third-party services, secure transfer & ownership-reassignment checklist,
  license & subscription inventory, and our-side access-revocation plan. Never stores secret
  values. Trigger on "access handover", "credentials transfer", "transfer accounts to client",
  or "access and credentials".
---

# /handover-access — Access & Credentials Transfer

Produces deliverable **05**: the controlled record of every account, repository, cloud resource, third-party service, license, and secret that must change hands — and the plan to transfer ownership securely and then revoke our access.

> **Shared contract** — output location & numbering, secrets → doc 05, actual-state-not-plan, cross-referencing, and completeness rules live in [`handover/references/handover-conventions.md`](../handover/references/handover-conventions.md). Follow it; don't restate it.

## Security rules (non-negotiable)

- **Never write actual secret values** (passwords, API keys, private keys, tokens, connection strings) into this or any handover document, the repo, or chat.
- This document is an **inventory and a transfer plan**, not a secrets store. Each secret is referenced by *name and location in a secrets manager* (1Password, Vault, AWS Secrets Manager, etc.).
- Transfer secrets only over a **secure channel**: a shared vault, the provider's native "transfer ownership" flow, or an encrypted one-time-secret link — not email, not Slack, not a doc.
- After transfer, **rotate** anything that was ever shared with our team and confirm the client has done so.
- If you discover plaintext secrets committed in the repo, flag it as a finding — they must be rotated and purged from history.

## When to use

- Ownership of accounts, domains, cloud, and third-party services moves to the client.
- You need a verifiable checklist that every credential was transferred and our access removed.

## Inputs to gather

- Source control org/repo access; cloud provider accounts/projects; CI/CD secrets.
- Third-party service accounts (payments, email, SMS, analytics, error tracking, maps, auth).
- Domain registrar, DNS, SSL, CDN accounts.
- App stores, package registries, monitoring tools.
- Licenses and paid subscriptions (and their billing owner).

## Process

1. Build the **account & access inventory** — every system, current owner, and access level.
2. For each, define the **transfer mechanism** (native ownership transfer vs. add-client-then-remove-us) and current status.
3. Build the **secrets inventory** referencing vault locations, not values.
4. Build the **license & subscription inventory** with billing owner and renewal/transfer status.
5. Define the **revocation plan**: which of our accounts/keys are removed, when (often at end of support window per doc 08), and who verifies.
6. Produce a **verification sign-off** confirming the client has access and we no longer do.

## Output template — `handover/05-access-credentials.md`

```markdown
# Access & Credentials Transfer — <Project Name>

> This document is an inventory and transfer plan. It contains NO secret values.
> Secrets are referenced by name + vault location and transferred via <vault / native flow>.

## 1. Account & access inventory

| System | URL | Current owner | Access level | Transfer mechanism | Status |
|--------|-----|---------------|--------------|--------------------|--------|
| Source control (org/repo) | | | admin | invite client → remove us | Pending |
| Cloud provider | | | owner | native ownership transfer | Pending |
| CI/CD | | | | | Pending |
| Domain registrar | | | | | Pending |
| DNS / CDN | | | | | Pending |
| Email / SMS provider | | | | | Pending |
| Payments | | | | | Pending |
| Error tracking / monitoring | | | | | Pending |
| Analytics | | | | | Pending |
| App store / registry | | | | | Pending |

## 2. Secrets inventory (references only — NO values)

| Secret name | Used by | Vault location | Rotated on transfer? | Status |
|-------------|---------|----------------|----------------------|--------|
| `DATABASE_URL` | backend | vault://<path> | required | Pending |
| `STRIPE_SECRET_KEY` | payments | vault://<path> | required | Pending |
| `...` | | | | |

## 3. License & subscription inventory

| Product | Plan | Seats | Billing owner | Renewal | Transfer to client? | Status |
|---------|------|-------|---------------|---------|---------------------|--------|
| | | | | | | Pending |

## 4. Our-side access revocation plan

| Our account / key | System | Remove by | Verified by | Status |
|-------------------|--------|-----------|-------------|--------|
| | | end of support window (doc 08) | | Pending |

## 5. Verification sign-off
- Client confirms they have owner/admin access to every system in section 1.
- All shared secrets rotated by the client after transfer.
- Our team's access revoked and verified.
- No plaintext secrets remain in the repository or its history.

| | Name | Date |
|---|------|------|
| Client technical contact | | |
| Our DevOps / security owner | | |
```

## Quality checklist

- Zero secret values anywhere in the document.
- Every system has a named transfer mechanism and a status, not just a checkbox.
- Revocation has a date tied to the support window and a verifier.
- Rotation of previously-shared secrets is explicitly required and tracked.
- Any plaintext secret found in the repo is raised as a finding for rotation + history purge.
