---
name: bstack:preset-e2e
description: 'Autonomous preset E2E — run the preset flow, interrogate DB + every output (PDF, Excel, email, artifacts) with domain expertise, fix loop'
argument-hint: '[--email=<addr>] [--preset=<CODE>]'
model: opus
---

> **TASK TRACKING:** Create one task per numbered step and one per finding. Mark each complete as you go.

# /bstack:preset-e2e

> **Role:** Senior CRE PropTech analyst (multifamily, office, retail, industrial, lease/loan abstraction, rent rolls, deal management, proformas, comps). Apply domain judgment to outputs — surface anything a sharp analyst would push back on.
>
> **Autonomy contract:** Run end-to-end without asking permission, **with one exception: Step 1 (input resolution) requires explicit user confirmation.** Beyond Step 1, "silence = consent" for local actions (reading files, downloading artifacts, querying local DB, re-seeding dev). Ask only when (a) a required input cannot be inferred or (b) services are down and you lack authority to fix.

## Input resolution (minimize prompts)

- **Email** ← `--email` → `E2E_TEST_EMAIL` → `git config user.email` → memory → ask.
- **Preset** ← `--preset` → single modified preset on the branch (`git diff --name-only $(git merge-base HEAD dev) -- libs/db/assets/presets/`) → conversation context → numbered menu of all presets.

**Confirm both with the user before proceeding.**

## Steps

1. **Confirm inputs** (only mandatory pause).
2. **Local seed** — if preset has changed, `npm run db:seed:presets` for the target.
3. **Run the preset flow** — drive via Playwright through the full pipeline (upload, extract, transform, generate outputs).
4. **DB interrogation** — query the database for produced rows. Check: row counts, NULL ratios, FK integrity.
5. **Output interrogation** — every artifact (PDF, XLSX, email, JSON). Open and read. Apply CRE judgment:
   - Lease abstracts: dates sane, escalations math, square footage tally.
   - Rent rolls: occupancy %, rent/SF in band, no obvious OCR drift.
   - Box scores: WoW deltas, leasing pace.
   - Proformas: cap rate, NOI growth, expense ratios.
6. **Cross-output drift** — same datapoint should match across PDF + Excel + email. Flag any drift.
7. **Fix loop** — for each finding, propose minimal fix → apply → re-run only the failing slice. Bound it: **at most 2 fix cycles per finding, then stop with evidence** (standards P-2.9) — do not loop indefinitely.
8. **Final report** — Markdown summary at `docs/preset-e2e-reports/YYYY-MM-DD-<preset>.md`.

## Output

- Findings table: severity · datapoint · expected · actual · evidence path.
- Recommended follow-ups: code fixes, preset config changes, data-source issues.
- Post Slack summary if any HIGH finding.
