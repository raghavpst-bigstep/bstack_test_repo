# UAT Sign-Off — content spec

`scripts/build.py` renders the branded UAT Sign-Off from a single JSON object.
**Every field is optional.** Anything omitted renders as a blank line, so an
empty spec (`{}`) produces the standard blank form.

```bash
python scripts/build.py spec.json out.docx      # populated
python scripts/build.py                          # blank form
```

## Top-level shape

```jsonc
{
  "meta":             { ... },   // doc ref, version, classification, purpose line
  "details":          { ... },   // Project & Stakeholder Details grid (8 fields)
  "acceptance_basis": "…",       // the Acceptance Basis panel text
  "test_summary":     { ... },   // Test Execution Summary row
  "defects":          { ... },   // Defect Summary by Severity (Open / Closed)
  "decision":         { ... },   // Acceptance decision + notes
  "signoff":          { ... }     // Sign-Off & Authorisation (2 parties)
}
```

## `meta`

| key | meaning | default |
|---|---|---|
| `doc_ref` | reference printed in the footer | `BST-UAT-____` |
| `version` | document version | `1.0` |
| `classification` | e.g. Confidential / Internal | `Confidential` |
| `subtitle` | the purpose line under the title | standard purpose sentence |

## `details` (Project & Stakeholder Details)

Eight keys, two-column grid. Omitted keys render a blank fill line.

`project_product`, `client_org`, `project_ref`, `uat_environment`,
`bigstep_pm`, `client_sponsor`, `release_build`, `uat_period`.

## `acceptance_basis`

A single string shown in the blue callout under a bold "Accepted when" lead.
Defaults to the standard basis (all in-scope requirements delivered &
demonstrated; all planned test cases executed; no open Critical/High defects;
remaining defects documented with an agreed plan; data & documentation
validated).

## `test_summary` (Test Execution Summary)

A row of metrics rendered as a branded table. Any omitted metric renders blank.

```jsonc
"test_summary": {
  "planned": 142, "executed": 142, "passed": 137,
  "failed": 4, "blocked": 1, "pass_pct": "96.5%"
}
```
Columns: Planned · Executed · Passed · Failed · Blocked · Pass %.

## `defects` (Defect Summary by Severity)

A matrix with two rows, **Open** and **Closed**, across the severities
Critical (S1) · High (S2) · Medium (S3) · Low (S4) · Total.

```jsonc
"defects": {
  "open":   {"critical": 0, "high": 0, "medium": 2, "low": 3, "total": 5},
  "closed": {"critical": 3, "high": 7, "medium": 12, "low": 9, "total": 31}
}
```
Any omitted cell renders blank. `total` is not computed — supply it (this keeps
the artifact a faithful record rather than a calculator).

## `decision` (Acceptance Decision)
```jsonc
"decision": {
  "selected": "accepted" | "conditions" | "rejected" | null,   // null = none ticked
  "notes": "free text on conditions / rationale"
}
```
The selected option is ticked and highlighted; the others render empty.
`notes` fills the "Conditions / notes" line.

## `signoff` (Sign-Off & Authorisation)

Two parties (client acceptance + BigStep authorisation), each with `name`,
`role`, `signature`, `date`. Omitted fields render an underline to sign on.
**Never pre-fill a name, signature, date, or an "Accepted" decision that has not
actually been given** — roles may be pre-filled; acceptances and identities stay
blank for real people to sign.

## Design guarantees (handled by the builder — don't hand-format)

- Poppins embedded; BigStep blue/navy/cyan palette; flat, no shadows.
- Header logo + tint rule; footer with doc ref, version, and classification.
- Two-tone section headers with cyan underlines; tinted field grid; blue
  acceptance-basis callout; branded metrics table; branded severity matrix
  (blue header, blue zebra); highlighted acceptance decision; bordered
  authorisation blocks.
- The **blank** form is tuned to fit one page. A form with long notes or long
  field values may flow to a second page — that is normal.
