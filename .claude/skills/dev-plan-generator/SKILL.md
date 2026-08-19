---
name: dev-plan-generator
description: >
  Generate professional development plans in Excel format for software projects. Use this skill whenever a user
  provides project scope, requirements, tech stack preferences, features, timeline, and team composition. The skill
  structures this information into a comprehensive, multi-sheet Excel workbook that covers technical design,
  development roadmap, team structure, delivery timeline, infrastructure costs, and QA strategy. Trigger on phrases
  like "create a dev plan", "generate development plan", "build the development scope", "I need a dev plan for",
  "structure this project into a plan", or whenever the user describes features and effort they want planned.
  Always use this skill — do not just output the content as text or markdown.
---

# Development Plan Generator

This skill creates professional development plans in Excel format by structuring project requirements into a standardized, multi-sheet template. The output is a fully formatted workbook suitable for client communication, stakeholder alignment, and project execution.

## Input Requirements

When the user provides a development plan request, expect them to supply:

1. **Project Overview**
   - Project name
   - High-level description
   - Client/stakeholder context

2. **Requirements & Scope**
   - Core features/modules to be built
   - Specific functionality per module
   - Design deliverables (screens, flows, prototypes)
   - Integration requirements (with existing systems, third-party APIs)

3. **Technical Preferences**
   - Preferred technology stack (frontend, backend, databases, DevOps, AI/ML if applicable)
   - Rationale for each tech choice (scalability, performance, integration, team expertise)
   - Any constraints or non-negotiables

4. **Effort & Timeline**
   - Estimated man-days per role per feature (or complexity indicators)
   - Target timeline/deadline
   - Phase preferences (design duration, development duration, UAT duration)

5. **Team Information**
   - Roles needed (e.g., Frontend Dev, Backend Dev, AI Engineer, QA, DevOps, etc.)
   - Team composition or expected team size
   - Any specialized skills required

6. **Assumptions & Dependencies**
   - External dependencies (client systems, APIs, data, infrastructure access)
   - Key assumptions about project execution
   - Risk factors or constraints

## Output Structure

The skill generates an Excel workbook with the following sheets:

### 1. **Proposed Tech Stack**

- Development areas (Frontend, Backend, AI Layer, Database/State, DevOps, Design/UX)
- Technology choices with rationale and additional comments
- Project tools and their purposes
- Best practices for software development
- (Optional) Links to detailed documentation

### 2. **MVP Development Plan** (or Primary Development Phase)

- Structured task breakdown by phase (Design, Technical Prep, Development)
- Each task includes: Feature/Module, Sub-Feature, Assumptions, Deliverables, Notes, and effort in man-days per role
- Roles across columns: UI Designer, Frontend Dev, Backend Dev, Data Engineer, AI Engineer, Tech Architect, QA Engineer, DevOps, PM
- Totals by role in man-days and man-months
- Team structure summary with durations per role

### 3. **Design Plan**

- Design activities (Analysis, UX Workshops, Information Architecture, Wireframes, etc.)
- Description of each activity
- Client involvement requirements
- Screens list: modules, screen names, and implementation notes
- Buffer screens for unknown/emergent requirements

### 4. **Proposed Engagement Model**

- Engagement approach (e.g., Team-as-a-Service, Agile methodology)
- Key principles and benefits
- Flexibility and scaling approach

### 5. **Team Structure**

- Role definitions
- Key responsibilities per role
- Duration expectations

### 6. **Delivery Timeline (MVP or Project)**

- Gantt-style timeline showing phases across months/weeks
- Team member allocation per time period
- Total weeks and man-months per role

### 7. **Dependencies**

- External dependencies required from client
- Responsible teams (Client, BigStep, or Shared)
- Descriptions and timing

### 8. **Project Assumptions**

- Scope boundaries
- System integration assumptions
- Data handling assumptions
- Scalability and future integration considerations

### 9. **QA & Testing**

- Test phases (Planning, Functional, Automation, Evaluation)
- Test data requirements
- Phase-specific objectives, scenarios, and tools
- Evaluation metrics (Accuracy, Relevance, Completeness, etc.)

### 10. **Infrastructure Cost**

- Resource breakdown (databases, compute, hosting, monitoring, AI services, etc.)
- Providers (AWS, GCP, third-party SaaS)
- Estimated monthly/project costs
- Free tier eligibility where applicable

### 11. **Post-MVP Features** (if applicable)

- Future features/enhancements
- Phase, feature, sub-feature, and assumptions
- Low detail compared to MVP—roadmap only

## How to generate

Rendered by a **bundled deterministic engine** — assemble a JSON content spec, run
`scripts/build.py` (shared with the design-plan generator). Styling, borders, zebra rows,
and correct SUM totals are the engine's job — you supply content only. Schema:
[`references/content_spec.md`](references/content_spec.md) (identical block model).

```bash
python3 scripts/build.py spec.json "Development-Plan-[ClientName].xlsx"
```

Map the sheets above onto `sheets[]` (each a `name`, `title`, and content `blocks` —
`table` / `note` / `kv`).

- **Effort cells are JSON numbers** so column sums work. Add `total {label, sum_cols}` to a
  table for a totals row — the engine writes the correct `=SUM(...)` from the real data-row
  span. **Never author absolute `=SUM(C2:C6)` refs** — a title band offsets positions, so
  authored refs break (standards P-2.2 / P-4.5).
- **Man-months = man-days / 20:** compute the value in the spec (a number) rather than an
  absolute-ref formula, to stay reproducible.
- No hand-formatting, no Arial/grey — the brand (BigStep blue `#1C62EC`, Poppins) is fixed.

## Key Principles

1. **Layperson-Friendly Language**: Technical terms are explained in context. The plan should be understandable to non-technical stakeholders while remaining precise for developers.

2. **Specificity**: Every task includes assumptions, deliverables, and notes. Generic descriptions are avoided.

3. **Effort Clarity**: Man-days are broken down by role. Totals show both man-days and man-months for easy interpretation.

4. **Client Involvement**: The Design Plan and Dependencies sheets explicitly call out what the client needs to provide or approve.

5. **Scalability Mindset**: The plan acknowledges future phases and integrations, even if detailed roadmaps (Post-MVP) are high-level.

6. **Transparency**: Assumptions, constraints, and buffer items (e.g., contingency, buffer screens) are documented to manage expectations.

## How to Use This Skill

1. **User provides project details**: Scope, requirements, tech stack, timeline, team info, assumptions
2. **Claude uses the skill**: Structures the information into the standard Excel sheets
3. **Excel generation**: Creates a fully formatted workbook with formulas, styling, and professional formatting
4. **Output**: User downloads the .xlsx file ready for stakeholder review

## Common Variations

- **MVP vs. Full Product**: Some plans focus only on MVP; others include phased rollouts (MVP -> Post-MVP). Adjust sheet detail accordingly.
- **Team Size**: Small teams may combine roles; large teams may split them. Adjust the Team Structure sheet as needed.
- **Technology Complexity**: AI-heavy projects include more detail in AI Engineer rows; traditional web apps focus on Frontend/Backend balance.
- **Timeline**: Aggressive timelines may compress phases; relaxed timelines may extend them. Adjust the Delivery Timeline accordingly.

## Notes

- Do not invent requirements or make assumptions about features not explicitly provided by the user.
- When man-day estimates are not provided, ask the user for clarification rather than inferring.
- Ensure all formulas (totals, conversions) are correct before finalizing the Excel.
