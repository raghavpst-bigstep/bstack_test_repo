# Go-Live / Release Sign-Off — content spec

`scripts/build.py` renders the branded document from a single JSON object.
**Every field is optional.** Anything you omit renders as a blank line to write
on, so an empty spec (`{}`) produces the standard blank template. Pass values
only for the parts you actually know; leave the rest for signatories to fill.

```bash
python scripts/build.py spec.json out.docx      # populated
python scripts/build.py                          # blank template
```

## Top-level shape

```jsonc
{
  "meta":      { ... },   // doc ref, version, classification, purpose line
  "details":   { ... },   // the Release & Deployment Details grid (10 fields)
  "readiness": [ ... ],   // the Pre-Go-Live checklist (text + checked)
  "rollback":  "…",       // one paragraph for the Rollback & Contingency panel
  "decision":  { ... },   // Go / No-Go selection + notes
  "signoff":   { ... }    // Client + BigStep authorisation blocks
}
```

## `meta`

| key | meaning | default |
|---|---|---|
| `doc_ref` | document reference printed in the footer | `BST-GL-____` |
| `version` | document version | `1.0` |
| `classification` | e.g. Confidential / Internal | `Confidential` |
| `subtitle` | the purpose line under the title | standard purpose sentence |

## `details` (Release & Deployment Details)

Ten keys, rendered as a two-column form grid. Any omitted key renders a blank
fill line. `release_type` defaults to the printed choice list
`Major / Minor / Patch / Hotfix` when left empty.

`project_product`, `client_org`, `release_version`, `release_type`,
`bigstep_release_mgr`, `client_release_owner`, `target_environment`,
`go_live_datetime`, `deployment_window`, `expected_downtime`.

## `readiness` (Pre-Go-Live Readiness Checklist)

A list. Each item is either a string (unchecked) or `{"text": "...",
"checked": true|false}`. Omit `readiness` entirely to use the standard
14-item checklist, all unchecked. Provide your own list to add, remove, or
pre-tick items based on what the release has actually completed.

```jsonc
"readiness": [
  {"text": "UAT completed and signed off", "checked": true},
  {"text": "Integrations / dependencies confirmed ready", "checked": false}
]
```

## `rollback`

A single string describing trigger/criteria, method, estimated time, backup
recovery point, and decision owner. Rendered in the blue callout panel.
Defaults to the generic prompt text.

## `decision` (Go / No-Go)
```jsonc
"decision": {
  "selected": "go" | "conditional" | "nogo" | null,   // null = none ticked
  "notes": "free text on the conditions / rationale"
}
```
The selected option is ticked and highlighted; the others render as empty
choices. `notes` fills the "Conditions / notes" line.

## `signoff` (Sign-Off & Authorisation)

Two parties, each with `name`, `role`, `signature`, `date`. Any omitted field
renders an underline to sign on. **Never pre-fill a signature or a name that
has not actually authorised the release** — leave those blank.

```jsonc
"signoff": {
  "client":  {"name": "", "role": "Head of Product", "signature": "", "date": ""},
  "bigstep": {"name": "", "role": "Delivery Lead",   "signature": "", "date": ""}
}
```

## Design guarantees (handled by the builder — don't hand-format)

- Poppins embedded; BigStep blue/navy/cyan palette; flat, no shadows.
- Header logo + tint rule on the page; footer with website, doc ref, version,
  classification.
- Two-tone section headers with cyan underlines; tinted field grid; zebra
  checklist; blue rollback callout; highlighted Go/No-Go selection; bordered
  authorisation blocks.
- The **blank** template is tuned to fit one page. A heavily-filled form (long
  rollback text, long field values) may flow to a second page — that is normal.
