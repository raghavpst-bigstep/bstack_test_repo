---
name: design-plan-generator
description: >
  Generate a professional UX/UI design scope and plan as a formatted Excel workbook for fixed-scope website design projects — including redesigns, brand revamps, and new builds.
  Use this skill whenever a user provides project requirements for a website design engagement, mentions pages, design activities (UX audit, IA, wireframes, moodboards, style guide),
  team structure, or a timeline for a client project. Trigger on phrases like "create a design plan", "generate scope for", "build the design scope", "I need a design plan for",
  "new project for [client]", or whenever the user describes pages and design activities they want scoped. Always use this skill — do not just output the content as text or markdown.
---

# Design Plan Generator

Generates a professional multi-sheet Excel workbook that documents the full design scope, content scope, delivery timeline, and project assumptions for a fixed-scope UX/UI website project.

## When to use

The user gives you project inputs: client name, list of pages (with basic/unique classification), design activities, number of hotels/destinations/flows if applicable, team composition, and project duration. You output a formatted `.xlsx` file matching the structure below.

## Required inputs to collect (ask if missing)

Before generating, confirm you have:
1. **Client name** and **parent brand** (e.g., "Claridges for IHCL")
2. **List of pages** — name, type (Unique or Basic), count, sub-features or notes
3. **Flows** — e.g., Booking Flow, My Account Flow, with approximate screen counts
4. **Design activities** — from the standard list below; confirm which apply
5. **Out-of-scope items** specific to this client
6. **Content scope** — unique pages, basic pages, hotels, destinations, their sub-page counts
7. **Team structure** — roles and names/levels if known
8. **Project duration** — number of months; phases and what happens in each

If the user says "I'll give you the details", wait. Do not guess or hallucinate page names or counts.

---

## Output: 4-Sheet Excel Workbook

### Sheet 1 — Design Scope

**Title row:** `Design Scope for [Client] for [Brand/Parent]`

**Columns:**
| Column | Header | Notes |
|--------|--------|-------|
| A | Page Name | Activity or page title |
| B | Sub-Features | Description of what the activity/page entails |
| C | Number of Pages | Count or range (e.g., 15-20) |
| D | Type of Page | "Unique" or "Basic" |
| E | (spacer) | Empty |
| F | Out of Scope Tasks | Right-side summary block |
| G | Count | Counts for out-of-scope summary |

**Sections in Column A (in order):**

**Discovery & UX Activities block** (no page type or count — these are activities):
Standard activities to include unless told otherwise:
- Discovery Calls + Kick Off Calls
- Understanding New Requirements
- Analysis and UX Workshops
- Style Guide
- Wireframes for Unique Pages
- Image Selection
- Information Architecture
- Functional Requirement Documents

**Page List block** (rows with Unique/Basic type and counts):
- List all pages the user provides
- "Basic" = adapted/reskinned from existing design, no new wireframes
- "Unique" = new wireframes created, new structure
- Note "Adaptation of [source brand]" in Sub-Features for Basic pages where applicable

**Hotel Pages sub-section** (if hotels are in scope):
Group hotel-level pages under a "Hotel Pages" header row

**Out of Scope block** (columns F–G, aligned to the activity rows):
Standard out-of-scope items (confirm with user):
- Design Implant Resource
- UAT or QA after Development is done
- Design Iterations after 6-7 Iterations
- Unique Screens (count)
- Basic Screens (count)
- My Account Flow (range)
- Booking Flow (range)
- Number of Destinations (count)
- Number of Hotels (count)

---

### Sheet 2 — Content Scope

**Structure:**
- Row 1: Narrative paragraph describing the full content scope (write this from the inputs)
- Summary table below:

| Label | Value |
|-------|-------|
| Unique Screens | [count] |
| Basic Screens | [count] |
| My Account Flow | [range] |
| Booking Flow | [range] |
| Number of Hotels | [count] |
| Number of Hotel Pages (Overview, Rooms and Suites, Venues etc) | [N] (For Each Hotel) |
| Number of Destinations | [count] |
| Number of Destination Landing Pages (Experience, Hotels, Dining etc) | [N] (For each Destination) |

- Footer paragraph: Explain the content approach — unique screens written from scratch; basic pages tweaked from existing content; flows adapted from existing Taj/Vivanta (or relevant brand) content.

---

### Sheet 3 — Delivery Timeline

**Title:** `Delivery Timeline & Gantt Chart`

**Structure:**
- Row 1: Phase column + Month 1, Month 2... headers (spanning 4 columns each = 4 weeks)
- Row 2: Week numbers 1–4 repeated per month
- Gantt rows for each phase — use filled cells (solid color fill) to indicate active weeks

**Standard phases (adapt based on user input):**
1. Discovery & Planning Phase 1 — Understanding requirements, workshops, benchmarking
2. Discovery & Planning Phase 2 — IA, sitemap, moodboard, homepage + 1–2 key pages, design system init
3. UI/UX Design of all other Pages
4. Final Feedback Implementation

**Gantt fill logic:**
- Use a solid brand-appropriate color (e.g., dark navy or charcoal) for active weeks
- Leave inactive weeks unfilled
- Map phases to realistic week ranges based on the total project duration given

**Project Assumptions note** (bottom of this sheet or separate sheet):
Include the standard assumptions paragraph (see Sheet 4).

---

### Sheet 4 — Project Assumptions

**Two-column table:**
| Category | Assumption |
|----------|------------|

**Standard categories and assumptions to include:**

**General Assumptions:**
- Client will provide timely approvals and feedback at each stage to avoid delays.
- All required branding assets (logo, color scheme, typography, images) will be provided by the client before development starts.
- Cost for any 3rd party service will be managed by client.
- Any page/feature not mentioned in the proposal will be considered out of scope.
- Travel & Accommodation: For in-person meetings/presentations, travel and accommodation will be arranged or reimbursed by the client with prior written approval.
- The estimation and scope do not include a dedicated design implant resource. UAT sessions after design and development are completed are not included in this fixed scope. These will be provided separately under a retainer model.

**UI/UX & Features:**
- The design will be responsive, ensuring optimal performance across desktop and mobile devices.
- The estimation includes only mobile responsive and web designs — wireframes and final designs only. Other design types are out of scope.
- All brand guidelines, assets, images and content will be provided by client team.
- The proposal includes up to 6-7 design iterations at both wireframing and visual design stages. Additional iterations may incur extra costs.
- Professional licenses (paid fonts, images, assets) will be covered by the client with prior written approval.
- The client must provide high-quality images and videos for the homepage and other relevant pages.
- A logo optimized for both mobile and desktop views is required.
- Visual design to be developed based on brand guidelines and assets provided by the client.
- User personas and journeys are based on initial client inputs. Additional research or testing will be costed separately.
- Client feedback and approvals are expected within 2-4 days of submission. Delays may result in timeline adjustments.
- Any changes in scope, additional features, or extra rounds of feedback will be considered a change request and may affect timeline and budget.
- Client will provide timely access to stakeholders, materials, and resources needed.
- Wireframes will be created only for unique pages, not for reskinning/basic pages.
- If a single page includes subpages, each subpage will be treated as an individual page and considered out of scope.

Adjust any assumptions if the user specifies client-specific conditions.

---

## How to generate

Rendered by a **bundled deterministic engine** — assemble a JSON content spec, run
`scripts/build.py`. Styling is the engine's job (BigStep blue `#1C62EC`, Poppins, borders,
zebra rows, correct SUM totals), not yours. Schema:
[`references/content_spec.md`](references/content_spec.md).

```bash
python3 scripts/build.py spec.json "Design_and_Content_Scope_for_[ClientName].xlsx"
```

Map the 4 sheets above onto `sheets[]`, each with a `name`, a `title`, and content `blocks`:

- **table** — `headers[]`, `rows[][]`, optional `widths[]`, and optional
  `total {label, sum_cols}` for a computed totals row. **Never hardcode `=SUM(...)` cell
  refs** — the engine computes the range from the actual rendered rows (a title band
  offsets positions, so authored refs break). Numeric effort/count cells should be numbers.
- **note** — `{title, text}` for out-of-scope / assumptions blocks.
- **kv** — `{pairs:[[label,value]]}` for assumptions metadata.

Gantt/timeline cells are ordinary table cells (`"●"` marks an active week). See
[`example/design.example.json`](example/design.example.json). Do not hand-format cells
(standards P-2.2 / P-4.5).

## Reference

See `references/example-structure.md` for a worked example of how pages and activities map to rows.
