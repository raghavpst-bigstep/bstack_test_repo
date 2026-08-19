---
name: bstack:scrape
description: 'Pull structured data from a web page — read-only, returns JSON. For mutating flows use a Playwright script.'
argument-hint: '[url] [--schema=path/to/json-schema.json] [--fields=name,price,date]'
model: sonnet
---

# /bstack:scrape

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.

Read-only data extraction from a single page. Not for form fills, clicks, submissions — use a one-off Playwright script for those.

## MCP usage

| MCP | When | What for |
|---|---|---|
| Playwright | Always | `browser_navigate`, `browser_snapshot`, `browser_evaluate` to read DOM |

## Steps

1. **Intake** — URL (required) + either `--schema` (JSON Schema file) or `--fields` (comma list) or a free-text description of what to pull.
2. **Auth check** — if URL requires login: ask user how (cookie paste, existing session, or skip).
3. **Navigate + snapshot** — `browser_navigate`, wait for network idle, `browser_snapshot` to capture accessible DOM.
4. **Identify selectors** — for each requested field, find the most stable selector (semantic > role > class > nth-child). Prefer microdata / schema.org / OpenGraph if present.
5. **Extract** — `browser_evaluate` with one JS function that returns the full object. One round-trip, not field-by-field.
6. **Validate** — if `--schema` was given, validate against it. Report missing/unexpected fields.
7. **Normalize** — coerce types (dates → ISO 8601, currencies → number + ISO 4217 code, percentages → 0–100). Trim whitespace.
8. **Output** — print JSON to stdout. If `--out=path.json` given, write there. Always show the first 20 lines inline.
9. **Codify (optional)** — if this URL pattern is one we'll hit again, save the selector map to `docs/scrapers/<slug>.json` for fast re-runs.

## Output format

```json
{
  "url": "...",
  "scraped_at": "2026-06-02T...",
  "data": { ... },
  "warnings": [],
  "selectors_used": { "field": "selector" }
}
```

## Hard rules

- Robots.txt — check before scraping. If disallowed, refuse unless user explicitly overrides with reason.
- Rate limits — for any subsequent batch, add 1–3 s jitter between requests. Default to single-page only.
- PII — if the page contains user PII not directly relevant to the field list, do not include it in the output.
- No mutations — this command is `GET` only. Refuse any task that involves clicking submit, login flow chaining, etc.
