# Design Plan — content spec (JSON schema)

`scripts/build.py` renders a BigStep-branded `.xlsx` from a JSON **content spec**. You
produce the content; the script owns the brand (BigStep blue `#1C62EC`, Poppins, borders,
zebra rows, computed totals). The **Development Plan** generator uses the same engine.

```bash
python3 scripts/build.py spec.json out.xlsx
```

## Shape

```jsonc
{
  "meta": { "title": "Design & Content Scope", "doc_ref": "BST-DSN-2026-030", "version": "1.0" },
  "sheets": [
    { "name": "Design Scope",              // Excel tab name (auto-trimmed to 31 chars)
      "title": "Design Scope — <client>",  // blue title band across the widest table
      "blocks": [ /* ... */ ] }
  ]
}
```

## Block types

| `type` | Fields | Renders |
|---|---|---|
| `table` | `headers[]`, `rows[][]`, `widths[]?`, `total?` | Blue header + zebra rows + borders. |
| `note` | `title?`, `text` | A tinted, wrapped note block (assumptions, out-of-scope). |
| `kv` | `pairs`: `[[label,value], ...]` | Two-column label/value metadata. |
| `subhead` | `text` | A bold navy heading row. |

### Totals — let the engine compute them

Do **not** put `=SUM(C2:C6)` in a row: a title band offsets the table, so authored cell
refs point at the wrong cells. Instead add `total` to the table; the engine writes the
correct `=SUM(...)` from the real data-row span:

```jsonc
{ "type": "table",
  "headers": ["Activity", "Pages", "Effort (days)"],
  "rows": [ ["UX audit", "All", 3], ["Wireframes", "12", 8] ],   // numbers, not "8"
  "total": { "label": "Total", "sum_cols": [3] } }               // 1-based column numbers
```

Any cell value that itself starts with `=` is still written as a literal formula, so
cross-cell formulas are possible — but prefer `total` for column sums.

## Conventions

- Numeric cells (effort, counts, cost) are JSON **numbers**, so SUM works.
- Gantt/timeline: ordinary table cells; `"●"` marks an active week/period.
- Brand is fixed: BigStep blue `#1C62EC`, Poppins. Do not parameterise colour.

See `example/design.example.json` for a complete 4-sheet worked spec.
