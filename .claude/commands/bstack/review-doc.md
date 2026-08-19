---
name: bstack:review-doc
description: 'Review a markdown doc (plan, brainstorm, ADR, README) for clarity, completeness, and downstream actionability'
argument-hint: '[path to doc, or "latest"]'
model: sonnet
---

# /bstack:review-doc

> **TASK TRACKING:** Create one task per numbered finding. Mark each complete on revision.

Quality pass on a written artifact before it drives implementation. Not a style edit — a clarity + completeness audit.

## Resolve input

- Path arg → use it.
- `latest` → most recently modified file in `docs/plans/`, `docs/brainstorms/`, `docs/adrs/`, or `docs/specs/`.
- Else ask.

## Checks

1. **One-sentence purpose** — can a stranger summarize the doc's purpose after reading the first paragraph? If no, the lede is broken.
2. **Audience named** — who reads this and what should they do? Implementers? Reviewers? Stakeholders?
3. **Decision vs option** — if this is a decision doc, the decision is explicit and reasoned. If it's an exploration, options are clearly labeled "option A / B / C", not buried in prose.
4. **Concrete > abstract** — claims have a concrete example. "Improves performance" → with what change, against what baseline?
5. **Scope** — what's in, what's out, what's deferred. A missing "out of scope" section is a red flag.
6. **Constraints** — auth/data-safety impact, DDD boundary crossings, rollback path called out.
7. **Acceptance criteria** — testable, observable, finite. Avoid "works well" / "scales".
8. **Open questions** — listed at the end with named owners + dates.
9. **Links** — Linear ticket, related ADRs, related solutions linked. No dangling references.
10. **Style** — section headings make sense as a TOC. No wall-of-text > 200 words without a break.

## Output

For each finding:

```
### [BLOCKER | FIX | NICE] [Section] — [Issue]
**Why:** one sentence
**Suggested edit:** specific text or restructuring
```

BLOCKER = the doc misleads or is unusable as-is.
FIX = clarity / completeness gap, address before handoff.
NICE = polish.

End with one-line verdict: READY / READY WITH FIXES / NEEDS REVISION.

## MCP usage

| MCP | When | What for |
|---|---|---|
| Linear | Linked ticket | Verify the doc matches the ticket's scope |
| Notion | ADR / spec referenced | Verify alignment |

## Hard rules

- Don't rewrite the doc — recommend edits the author applies.
- Don't argue with the doc's premise — review for clarity, not opinion.
- If the doc has no acceptance criteria, that's always at least a FIX.
