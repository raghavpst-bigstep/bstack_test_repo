---
name: bstack:design-review
description: 'Designer-eye visual QA — finds spacing, hierarchy, AI-slop patterns, alignment, density; proposes specific fixes'
argument-hint: '[--url=http://localhost:4200/<route>] [--component=<path>]'
model: sonnet
---

# /bstack:design-review

> **TASK TRACKING:** Create one task per finding. Mark each complete with PASS / FIX-APPLIED / DEFERRED.

Visual QA against a running surface. Surfaces issues a sharp designer would catch but linting won't: spacing rhythm, hierarchy, density, AI-slop patterns (rounded everything, generic shadows, lorem-ipsum-looking content).

## MCP usage

| MCP | When | What for |
|---|---|---|
| Playwright | Always | `browser_navigate`, `browser_snapshot`, `browser_take_screenshot`, `browser_evaluate` for computed styles |
| context7 | MUI component override question | Current MUI v5 styling API |

## Pre-flight

- Frontend up (default `http://localhost:4200`). If down, refuse and ask user to start `npm run local`.
- Capture viewport sizes: 1440×900 desktop AND 375×812 mobile. Both required.

## Per-surface checklist

1. **Spacing rhythm** — gaps are a multiple of the base unit (4 or 8 px). One-off paddings = flag.
2. **Hierarchy** — primary CTA is visually unambiguous. Secondary/tertiary actions don't compete.
3. **Alignment** — text baselines line up. Icons centered to their labels. Form field widths consistent.
4. **Density** — list rows / table cells: not cramped, not floating. Compare to MUI defaults; deviations need a reason.
5. **Color** — colors come from the theme. Rogue hex codes = flag.
6. **Type scale** — font sizes come from the theme scale. Mid-scale "just slightly bigger" = AI slop.
7. **Empty states** — every list / table / chart has a real empty state, not a blank box.
8. **Loading states** — every async surface has a skeleton, not a spinner over blank.
9. **AI slop patterns** — rounded-on-everything, generic gradient backgrounds, "lorem-ipsum"-shaped copy, emoji as icons in production UI, identical card layouts for different content types.
10. **a11y quick pass** — focus rings visible, tab order sane, alt text present, contrast meets AA.
11. **Mobile** — repeat the above at 375 wide. Common failures: text wrap, button truncation, overlapping FABs.

## Output

For each finding:

```
### [SEVERITY] [Surface] — [Issue]
**Where:** route + selector
**Evidence:** screenshot path
**Why it's wrong:** one sentence
**Fix:** specific code change (file:line if known)
```

Severity: HIGH (blocks ship) · MEDIUM (fix in this PR) · LOW (follow-up).

After triage, attempt HIGH fixes inline. MEDIUM → write to TaskCreate. Report to `docs/design-reviews/YYYY-MM-DD-<surface>.md`.

## Hard rules

- Compare against theme tokens — never invent values.
- A "fix" that just adds padding without rationale is rejected.
- Mobile is not optional.
