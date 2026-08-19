---
name: sow-generator
description: >
  Use this skill whenever the user wants to generate a Statement of Work (SOW) document for
  a software or services project. Trigger on phrases like: "generate a SOW", "create a statement
  of work", "draft an SOW for [project]", "write up the scope of work", "build an SOW from the
  RFP", "turn these requirements into an SOW", "create a project SOW", "draft the engagement
  document", or any time the user wants to convert RFP documents, meeting notes, or pre-sales
  materials into a structured SOW Word document. Also trigger when the user says things like
  "we have the RFP, let's write the SOW" or "summarise the project into a formal document".
  This skill uses Google Drive MCP to discover source documents, performs a structured analysis
  and conflict-detection pass, then produces a downloadable .docx Word document in the BigStep
  brand format (BigStep blue, BigStep logo, Poppins, matching table styles) via a bundled renderer.
  Always use this skill for SOW generation — don't attempt it without the structured workflow below.
---

# SOW Generator Skill — BigStep Brand Format

Generates a full SOW (.docx) from pre-sales RFP documents and meeting notes, rendered by a
bundled deterministic engine in the BigStep brand: BigStep blue (`#1C62EC`), the BigStep logo,
Poppins (embedded), and consistent table/heading/callout styles with a branded header + footer.

---

## Step 0 — Confirm the renderer

This skill ships its own deterministic renderer under `scripts/` — you build a JSON
content spec, `scripts/build.py` produces the branded `.docx`. Requires `python-docx`
(+ `Pillow`), auto-installed by the workflow. The brand engine (`bigstep_brand.py`,
`bigstep_docx.py`) and Poppins fonts are bundled — nothing external is needed. Read
[`references/content_spec.md`](references/content_spec.md) for the spec schema before
generating. Do **not** hand-build the docx; the whole point is that the engine owns the
brand (Step 8).

---

## Step 1 — Collect project context

Extract from the user's message (or ask if missing):

| Field | How to get it |
|---|---|
| `project_name` | From user message — required |
| `client_name` | From user message or RFP docs |
| `vendor_name` | Default: "BigStep Technologies Pvt. Ltd." |
| `engagement_type` | e.g. Fixed-price build, T&M, Managed Services, or combination |
| `sow_version` | Default to `1.0` unless user specifies |

If the user hasn't provided a project name, ask before proceeding.

---

## Step 2 — Discover source documents via Google Drive

Search Google Drive for RFP documents and meeting notes. Use the project/client name as the
primary keyword. Run all queries and deduplicate results.

### Search queries (run in order, collect all results)

```
1. "[project_name] RFP"
2. "[project_name] requirements"
3. "[project_name] brief"
4. "[project_name] proposal"
5. "[project_name] meeting notes"
6. "[project_name] discovery"
7. "[client_name] requirements"
8. "[client_name] meeting"
```

### For each document found:

1. Read its full content
2. Note: filename, type (RFP / meeting notes / brief / proposal / other), and date if visible
3. Present the list to the user with a brief one-line summary of each file:

> "I found these documents in Google Drive. Please confirm these are the right ones, or let
> me know if any should be replaced or if there are additional files I should include:"
>
> - `[filename]` — [type], [date if found] — [one-line summary]

**Wait for user confirmation before continuing.** The user may say "replace X with Y" or
"also add this file [link]". Re-fetch any replacements or additions before proceeding.

**If no documents found:** Ask the user to share file links, paste content directly, or
confirm the project name to search under.

---

## Step 3 — Extract structured information from all confirmed documents

Read every confirmed document thoroughly and extract into these categories:

### A. Project & engagement fundamentals

- Product/platform vision and purpose; problem being solved; target market
- Engagement type, rough duration, success criteria or goals stated by client

### B. Scope — In scope

- Every feature, module, platform layer, or workstream mentioned
- Integrations, third-party services, APIs, platforms (web/iOS/Android/etc.)
- AI/ML components; quality, testing, and delivery work

### C. Scope — Explicitly out of scope or post-phase

- Anything the client or meeting notes explicitly deferred or excluded

### D. Timeline signals

- Dates, deadlines, durations, phase names, milestones, hard go-live dates

### E. Team & resource signals

- Roles mentioned or implied; named individuals on either side; FTE language

### F. Client requirements & dependencies

- Access, credentials, assets the client must provide
- Approvals, sign-offs, UAT participation expected from client

### G. Acceptance & quality signals

- Performance targets, SLAs, uptime, browser/device compatibility
- Security or compliance requirements; defect severity language

### H. Commercial & change control signals

- Rates, fixed fees, payment milestones; change request process; warranty period

### I. Risk signals

- Technical uncertainties, data quality concerns, timeline pressure, scope creep patterns

---

## Step 4 — Inconsistency and gap detection

Compare all extracted information across documents. Flag every issue in one of three tiers:

### CRITICAL — Pause and ask the user before continuing

Stop and ask the user to resolve before generating the document if you find:
- Directly contradictory scope statements
- Conflicting timelines with no resolution
- Contradictory decisions on a named integration or third-party dependency
- Client and vendor assumptions that are mutually exclusive

Present each critical flag clearly:
> **Critical conflict found — input needed before I continue:**
> - **Source A says:** [quote or paraphrase]
> - **Source B says:** [quote or paraphrase]
> - **My question:** [specific question to resolve it]
>
> How would you like me to proceed? (Or say "proceed anyway" and I'll note it as unresolved.)

### IMPORTANT — Surface in document as flagged callout

Flag in the document body AND collect in the Clarification Log (Section 12) if:
- A feature is mentioned in one document but absent from others
- A timeline is implied but never confirmed
- A client dependency is implied but never formally stated

### INFORMATIONAL — Collect in Clarification Log only

Collect in Section 12 only (not inline) if minor phrasing differences, missing boilerplate
details, or nice-to-have context that was discussed but not confirmed as scope.

---

## Step 5 — Team structure confirmation

After resolving any critical flags from Step 4, present a suggested team structure based on
the documents. Use the role suggestion guide below.

Present to the user as:
> "Based on the project scope, here's a suggested team. Please confirm, adjust roles, add
> people, or change allocations:"

### Role suggestion guide (use what fits the project)

| Role | Typical FTE | Notes |
|---|---|---|
| Solution Lead / Project Manager | 1.0 | Always suggest — owns delivery |
| Backend Engineer | 0.5-1.0 | Suggest if any API, data, or server work in scope |
| Frontend Engineer (Web) | 0.5-1.0 | Suggest if web application in scope |
| Mobile Engineer (iOS/Android) | 0.5-1.5 | Suggest if native mobile in scope |
| AI/ML Engineer | 0.5-1.0 | Suggest if AI, LLM, or ML work in scope |
| Platform / DevOps Engineer | 0.25-0.5 | Suggest if cloud infrastructure or CI/CD in scope |
| QA Engineer | 0.5-1.0 | Always suggest for any build engagement |
| UX/UI Designer | 0.5-1.0 | Suggest if design work is in scope |
| Solution Architect | 0.25-0.5 | Suggest for complex or multi-system engagements |

Collect from the user:
- Confirmed roles and FTE allocations
- Named resources where known (leave as TBC if not yet confirmed)
- Vendor-side contacts (name, role, email)
- Client-side contacts (name, role, email)

---

## Step 6 — Section presence check

Before generating, go through each section. For any section with insufficient data, ask:
> "I don't have enough information to generate Section X ([name]). Would you like to:
> (a) provide more detail now, (b) include a [TBD] placeholder, or (c) skip this section?"

---

## Step 7 — Pre-generation summary

Show the user a brief readiness summary before writing the document:
> "Ready to generate the SOW. Here's what I'll include:"
> Per section with a note on completeness

Wait for a "yes" / "proceed" / "go ahead" before generating.

---

## Step 8 — Generate the Word document

The branded `.docx` is produced by a **deterministic renderer** — you assemble a JSON
**content spec**, the script renders the BigStep-branded document. Do **not** hand-build
the docx (colours, fonts, tables, cover); the engine owns the brand so every SOW is
identical and on-brand (BigStep blue `#1C62EC`, Poppins embedded). This is the
standards P-2.2 / P-4.5 pattern — codify the mechanical transform, don't re-derive it.

1. **Assemble a JSON spec** per [`references/content_spec.md`](references/content_spec.md):
   a `meta` block (`title`, `subtitle`, `doc_ref`, `version`, `classification`) and an
   ordered `sections[]`, each with a `heading` and a list of content `blocks`
   (`para`, `subhead`, `bullets`, `table`, `callout`, `fields`). Map everything extracted
   in Steps 3–7 onto the sections below. `[TBD]` values stay as literal text and are
   logged in the Clarification Log section.
2. **Render it:**
   ```bash
   python3 scripts/build.py spec.json "<project>-SOW-v<version>.docx"
   ```
   Run with no argument to emit a blank sample; see
   [`example/sow.example.json`](example/sow.example.json) for a full worked spec. The
   script embeds Poppins, applies the palette + table/callout/field styles, and writes
   the logo header + doc-ref footer automatically.
3. **Flagged conflicts** (Step 4) render as `callout` blocks; the **Clarification Log** is
   a `table` section (always include it).

### DOCUMENT SECTIONS & CONTENT

Map these to `sections[]` in the JSON spec (one entry each, in order). Include the
sections that apply to the engagement — Sections 2–6 are app-project-shaped; omit or
adapt them for non-app SOWs. Section 12 is always included.

#### Section 1 — Project Overview & Objectives
#### Section 2 — User Roles & Access Matrix
#### Section 3 — Functional Requirements
#### Section 4 — Workflow & Validation Rules Engine
#### Section 5 — Technical Architecture & UX Design
#### Section 6 — Core Data Model
#### Section 7 — Implementation Roadmap
#### Section 8 — Assumptions & Exclusions
#### Section 9 — Glossary
#### Section 10 — Next Steps
#### Section 11 — Risk Register
#### Section 12 — Clarification Log (always include)

---

### File output

Save the file with a descriptive name like `[project_name]-SOW-v[version].docx`
(use kebab-case, no spaces in filename).

---

## Quality checklist (before presenting)

Styling is the engine's job — these check the **content** you put in the spec:

- [ ] `meta` complete: title, subtitle, `doc_ref`, `version`, `classification`
- [ ] Every applicable section present; Section 12 (Clarification Log) always included
- [ ] Important flags rendered as `callout` blocks in the body
- [ ] Every critical conflict resolved, or carries a `callout` + a Clarification Log entry
- [ ] Every `[TBD]` is intentional and logged in the Clarification Log
- [ ] Tables have consistent column counts; no empty forced sections
- [ ] Spec is valid JSON; `scripts/build.py` runs without error and the `.docx` opens

---

## Error handling

| Situation | Action |
|---|---|
| No Drive documents found | Ask user to share links or paste content directly |
| User confirms wrong files were found | Re-search with revised keywords; ask user to share correct links |
| Logo/assets missing | The logo + Poppins ship in `assets/` — no download. If the dir is incomplete, re-vendor the skill; the build errors clearly rather than half-rendering |
| Critical conflict — user says "proceed anyway" | Note as unresolved in Section 12.1; insert red callout at point of conflict |
| Section has no source data | Ask user: provide detail / use [TBD] placeholder / skip section |
| Team structure not confirmed | Do not generate team section until Step 5 is complete |
| Document exceeds expected length | Do not truncate — SOWs are long documents; generate in full |
