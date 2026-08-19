# Project Completion Certificate — content spec

`scripts/build.py` renders the branded certificate from a single JSON object.
**Every field is optional.** Anything omitted renders as a blank line, so an
empty spec (`{}`) produces the standard blank certificate.

```bash
python scripts/build.py spec.json out.docx      # populated
python scripts/build.py                          # blank certificate
```

## Top-level shape

```jsonc
{
  "meta":         { ... },   // version, classification, statement override
  "details":      { ... },   // Project & Stakeholder Details grid (8 fields)
  "deliverables": [ ... ],   // Deliverables & Milestones table rows
  "confirmation": "…",       // the Confirmation of Completion panel text
  "warranty":     { ... },   // Warranty, Support & Handover grid (6 fields)
  "signoff":      { ... }     // Acceptance & Authorisation (2 parties)
}
```

## `meta`

| key | meaning | default |
|---|---|---|
| `version` | certificate version | `1.0` |
| `classification` | e.g. Confidential / Internal | `Confidential` |
| `statement` | the centered certification sentence under the title | standard statement |

## `details` (Project & Stakeholder Details)

Eight keys, two-column grid. Omitted keys render a blank fill line.
`certificate_no` defaults to `BST-PCC-____`.

`project_product`, `client_org`, `project_ref`, `certificate_no`,
`bigstep_pm`, `client_sponsor`, `start_date`, `completion_date`.

## `deliverables` (Deliverables & Milestones Completed)

A list of rows for the branded table `# | Deliverable / Milestone | Status |
Date Delivered`. Omit `deliverables` to render three blank numbered rows.

```jsonc
"deliverables": [
  {"deliverable": "Tenant portal (web) — full build & UAT", "status": "Accepted", "date": "30 May 2026"},
  {"deliverable": "Payments & KYC integration",            "status": "Accepted", "date": "20 Jun 2026"}
]
```
Row numbers are assigned automatically; `n` may be supplied to override.

## `confirmation`

A single string of the completion statement, shown in the blue callout under a
bold "As of the completion date" lead. Defaults to the standard confirmation
(all in-scope deliverables handed over; UAT signed off; deployed & operational;
Critical/High defects resolved; docs, source & KT provided).

## `warranty` (Warranty, Support & Handover)

Six keys, two-column grid. Omitted keys render blank fill lines.

`warranty_liability`, `warranty_dates`, `post_completion_support`,
`support_escalation`, `outstanding_issues`, `final_payment_status`.

## `signoff` (Acceptance & Authorisation)

Two parties (client acceptance + BigStep authorisation), each with `name`,
`role`, `signature`, `date`. Omitted fields render an underline to sign on.
**Never pre-fill a name, signature, or date that has not actually accepted or
authorised the completion** — roles may be pre-filled; identities are left
blank.

```jsonc
"signoff": {
  "client":  {"name": "", "role": "Head of Product", "signature": "", "date": ""},
  "bigstep": {"name": "", "role": "Delivery Lead",   "signature": "", "date": ""}
}
```

## Design guarantees (handled by the builder — don't hand-format)

- Poppins embedded; BigStep blue/navy/cyan palette; flat, no shadows.
- Centered certificate header: "CERTIFICATE OF" kicker + two-tone "Project
  Completion" + centered cyan rule + centered statement.
- Header logo + tint rule; footer with version, classification, and
  "Issued by BigStep Technologies".
- Two-tone section headers with cyan underlines; tinted field grids; branded
  deliverables table (blue header, blue zebra); blue confirmation callout;
  bordered acceptance blocks.
- The **blank** certificate is tuned to fit one page. A certificate with many
  deliverables or long field values may flow to a second page — that is normal;
  the signature block simply moves with it.
