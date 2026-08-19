---
name: bstack:design-shotgun
description: 'Generate N AI design variants for one screen/component, render side-by-side, collect structured feedback, iterate'
argument-hint: '[screen or component description] [--variants=4] [--style=tailwind|mui]'
model: sonnet
---

# /bstack:design-shotgun

> **TASK TRACKING:** Create one task per variant. Mark each complete as it renders + receives feedback.

Diverge before you converge. Generate 3–6 distinct design directions for one UI surface, open them side-by-side, take structured feedback per variant, iterate the winners.

## Steps

1. **Brief** — capture the constraint:
   - Surface: which page / component
   - Stack: MUI v5 (default — frontend-web uses it) or Tailwind / custom
   - Data shape: what fields render
   - User intent: what action are they taking
   - Hard constraints: brand colors, density, a11y level
2. **Taste profile** — `bin/bstack-learn search "design-taste"` and read recent `preference` entries; bias variant generation toward recorded preferences (recency-weighted — trust newer entries over older ones) while keeping at least one variant that deliberately breaks from the profile, so taste can evolve.
3. **Variants** — generate N (default 4) variants. Each must differ on a meaningful axis (layout, hierarchy, density, color, motion). Two near-clones = waste. AI-slop thresholds per `.claude/config/slop-scan.json` apply to every variant.
4. **Render** — write each as a standalone HTML file under `docs/design-shotgun/YYYY-MM-DD-<surface>/variant-N.html`. Inline CSS, no build step.
5. **Comparison board** — generate `index.html` that side-by-side iframes all variants with labels.
6. **Open** — `open docs/design-shotgun/YYYY-MM-DD-<surface>/index.html`. Capture the live URL.
7. **Structured feedback** — for each variant prompt:
   - What works
   - What's broken
   - Score 1–5 (clarity, hierarchy, fit-to-brand)
   - Keep / Iterate / Drop
8. **Taste capture** — for each Keep/Drop with a stated reason, log it: `bin/bstack-learn log '{"type":"preference","key":"design-taste:<axis>","insight":"<what the user kept/dropped and why>","confidence":6,"source":"user-stated"}'`. This is what step 2 reads next run; `/bstack:learn prune` retires stale taste as it ages.
9. **Iterate winners** — for any "Iterate" variants, ask ONE focused question and regenerate.
10. **Pick + handoff** — final variant → `/bstack:design-review` for the visual QA pass, or hand directly to implementation.

## MCP usage

| MCP | When | What for |
|---|---|---|
| context7 | MUI / Tailwind component API | Look up current variants + props |

## Hard rules

- Always render at the real viewport sizes used by the app (default 1440×900 desktop + 375×812 mobile).
- Brand colors from `apps/frontend-web/src/theme/` — never invent palette.
- a11y: every variant passes WCAG AA contrast minimums or is explicitly marked "draft, not a11y-checked".
