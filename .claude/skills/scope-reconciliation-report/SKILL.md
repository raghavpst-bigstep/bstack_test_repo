---
name: scope-reconciliation-report
description: >
  Use this skill whenever the user wants to generate a Scope, Feedback & Change Order
  Reconciliation Report for a software or services project. Trigger on phrases like:
  "generate a scope report", "reconcile scope for [project]", "what's in scope vs out of scope",
  "flag change requests for [project]", "scope feedback report", "CR analysis", "change order report",
  "what's drifted from the SOW", "scope reconciliation", or any time the user wants to compare
  actual work / client feedback against a signed contract or SOW. Also trigger when the user says
  something like "go through emails and flag anything out of scope" or "check what should be a CR".
  This skill uses Gmail MCP + Google Drive MCP to gather evidence, then produces a downloadable
  .docx Word document. Always use this skill for scope analysis tasks — don't attempt them without
  the structured workflow below.
---

# Scope, Feedback & Change Order Reconciliation Report

Generates a structured Word document (.docx) that maps a project's email-based feedback and
change communications against the original signed Scope of Work (SOW) / contract and development
plan — classifying every item as **In Scope**, **Out of Scope (CR needed)**, **Post-MVP**, or
**In Scope — Defect** and surfacing a clean summary flags table.

---

## Step 0 — Confirm the renderer

This skill ships its own deterministic renderer under `scripts/` — you build a JSON
content spec, `scripts/build.py` produces the branded `.docx` (shared with the SOW
generator). Requires `python-docx` (+ `Pillow`), auto-installed by the workflow; the
brand engine and Poppins fonts are bundled — nothing external is needed. Read
[`references/content_spec.md`](references/content_spec.md) for the schema before
generating. Do **not** hand-build the docx (Step 6).

---

## Step 1 — Collect project context from the user

Ask the user (or extract from their message) the following. Items marked * are required; others
can be discovered from documents.

| Field | How to get it |
|---|---|
| `project_name` * | From user message |
| `sow_file` | Search Google Drive (Step 2); ask if not found |
| `dev_plan_file` | Search Google Drive (Step 2); ask if not found |
| `project_start_date` | Extract from SOW or dev plan; ask user if not found |
| `key_stakeholders` | Extract from SOW (client contacts, vendor contacts); refine from emails |

If the user has already provided file links or names, skip asking and proceed directly to Step 2.

---

## Step 2 — Discover source documents via Google Drive

Search Google Drive for the SOW and development plan. Use the project name as your primary
search keyword. Try multiple queries if the first doesn't return results.

```
Search queries to try (in order):
1. "[project_name] SOW"
2. "[project_name] Statement of Work"
3. "[project_name] Development Plan"
4. "[project_name] scope"
5. "[project_name] contract"
```

For each document found, read its content fully using the Google Drive read tool.

**Extract and store:**
- Contract/SOW signed date
- Project start date (use for email date filter in Step 3)
- In-scope items list (often in a section titled "In Scope", "Deliverables", or "Section 3")
- Out-of-scope / exclusions list (often titled "Exclusions", "Out of Scope", or "Section 1.4")
- Post-MVP / future phase items
- Change control clause: rate, process, form references, sprint cap on minor refinements
- Acceptance criteria / quality standards clauses
- Key stakeholder names and email addresses (for Gmail search in Step 3)

**If no documents are found:** Ask the user to share or link them before continuing.

---

## Step 3 — Gather email evidence via Gmail

Search Gmail for all project-related threads from the project start date to today.

### Search strategy

Run multiple Gmail searches to ensure full coverage:

```
Search queries (run all, deduplicate threads):
1. subject:[project_name]
2. "[project_name]" (body search)
3. from:[client_email_domain] after:[project_start_date_YYYY/MM/DD]
4. to:[client_email_domain] after:[project_start_date_YYYY/MM/DD]
5. from each key stakeholder name identified in Step 2
```

For each thread found:
- Read the full thread content
- Note: thread subject, date range, participants, and key statements

### What to look for in emails

Flag any email content that contains:
- New feature requests or functionality descriptions
- Design feedback that goes beyond the signed-off design
- Requests for new integrations, exports, or data formats
- Timeline change requests or acceptances
- Out-of-scope acknowledgements (from either party)
- Quality complaints about items that should have been in scope (potential defects)
- Informal agreements to absorb extra work without a formal CR

---

## Step 4 — Classify every item

For each piece of feedback or change request found in emails, classify it against the
source documents from Step 2.

### Classification taxonomy

| Classification | Definition |
|---|---|
| **In Scope — Defect** | Feature exists in the SOW/plan but is broken, missing, or doesn't meet acceptance criteria. Vendor to fix at no cost. |
| **In Scope — Pending** | Feature is contractually included but not yet delivered. |
| **Out of Scope — CR Needed** | Request adds new functionality, logic, data, or integration not described in the SOW/plan. |
| **Out of Scope — Post-MVP** | Request maps to an item explicitly listed in the post-MVP / future phase section of the plan. |
| **Out of Scope — Major Change** | Architectural change or significant rework likely requiring a formal mini-SOW (use when the change is clearly large). |
| **Post-Approval Design Change** | Design change requested after design sign-off gate; subject to change control or buffer allowance. |
| **Process Flag** | Procedural issue (e.g. CRs being absorbed without formal paperwork, missing sign-offs). |
| **Borderline — Small CR** | Ambiguous item; could be a minor refinement or a small CR depending on effort. Note the ambiguity explicitly. |

### Classification rules

1. **Default to the SOW/plan as the source of truth.** If a feature is described there, even
   briefly, it is in scope and a failure to deliver it is a defect — not a change request.
2. **Flag defects firmly.** If vendor communications acknowledge the gap was vendor-created (e.g.
   "enhancements we added"), classify as defect regardless of how the client framed it.
3. **Be specific about the scope clause.** Reference the exact SOW section or plan sheet that
   puts an item in or out of scope (e.g. "SOW Section 1.4 excludes advanced analytics").
4. **Catch informal CR absorption.** If emails show work being absorbed into sprints without
   formal CR paperwork, flag this as a process flag even if the individual items are small.
5. **Cumulative minor refinements.** If multiple small items have been absorbed, note the
   cumulative risk against any sprint cap defined in the change control clause.

---

## Step 5 — Determine report author

Retrieve the authenticated Google account name using Gmail (e.g. from the profile/signature
in sent emails, or from the Google Drive account metadata). Use this as the "Prepared by"
field in the report header. If it cannot be determined, leave it as "Prepared by: [Author]"
and note this to the user.

---

## Step 6 — Generate the Word document

Rendered by the **bundled deterministic engine** — you assemble a JSON content spec,
`scripts/build.py` produces the branded `.docx` (BigStep blue `#1C62EC`, Poppins
embedded). Do **not** hand-build the docx (standards P-2.2 / P-4.5). Schema:
[`references/content_spec.md`](references/content_spec.md). Run:

```bash
python3 scripts/build.py spec.json "<project>-Scope-Reconciliation-Report.docx"
```

Map the analysis onto `sections[]` (each a `heading` + content `blocks`):

- **Header context** → `meta.title` + `meta.subtitle` (project · prepared-by · source docs · email-evidence summary).
- **Section 1 — MVP / Contracted (In Scope)** → `para` + `bullets` by functional area; the scope-guard lock-in clauses → a `callout` block.
- **Section 2 — Out-of-Scope / Post-MVP** → `bullets` (post-MVP items; SOW exclusions).
- **Section 3 — Feedback & Email Evidence** → one `subhead` per thread (`[subject] — [date]`) + a `para` assessment naming the classification and the scope clause it maps to.
- **Section 4 — Change Order Activity** → `bullets` (formal CRs, informal absorptions, timeline changes, process-gap flags).
- **Section 5 — Summary Flags Table** → a `table` block, columns `# | Item | Source (doc/email + date) | Classification` — put the classification label in its own column (e.g. "Out of Scope — CR Needed").
- **Overarching Observations** → a final section of `bullets` (3–5 themes).

`[TBD]` values stay literal in the spec and are surfaced in the observations. Save as
`[project]-Scope-Reconciliation-Report.docx` (kebab-case). See
[`example/scope.example.json`](example/scope.example.json).

## Step 7 — Offer to save to Google Drive

After presenting the file, ask the user:
> "Would you like me to also save this to Google Drive? If so, which folder should I put it in?"

If they confirm, upload the file to the specified Drive folder using the Google Drive create tool.

---

## Quality checklist (before presenting the file)

- [ ] All email threads from project start date to today have been searched
- [ ] Every feedback item has an explicit classification with a scope clause reference
- [ ] Defects are clearly distinguished from change requests
- [ ] Informal CR absorptions are flagged as process issues
- [ ] The summary table has one row per flagged item, colour-coded
- [ ] Author name is populated from the Google account
- [ ] Source documents are listed in the header
- [ ] docx validates without errors

---

## Error handling

| Situation | Action |
|---|---|
| SOW / dev plan not found in Drive | Ask user to share the file link or upload it |
| Project start date not in documents | Ask user: "What date did the project officially kick off?" |
| No emails found for project | Broaden search: try just the client company domain, or ask user for key email addresses to search |
| Author name cannot be determined | Leave as `[Author]` and note it to the user |
| Gmail returns partial results | Paginate — keep fetching until no more results for the date range |
