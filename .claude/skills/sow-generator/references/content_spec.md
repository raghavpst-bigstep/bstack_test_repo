# SOW content spec — JSON schema

`scripts/build.py` renders a BigStep-branded `.docx` from a JSON **content spec**. You
produce the content; the script owns the brand (palette, Poppins, tables, header/footer).
The same engine renders the Scope Reconciliation report — only the spec differs.

Run:

```bash
python3 scripts/build.py spec.json out.docx      # populated
python3 scripts/build.py                          # blank sample -> ./Statement-of-Work.docx
```

## Top-level shape

```jsonc
{
  "meta": {
    "title": "Statement of Work",       // rendered two-tone; or split via title_lead/title_tail
    "subtitle": "One-line purpose.",     // optional
    "doc_ref": "BST-SOW-2026-014",       // footer
    "version": "1.0",                    // footer
    "classification": "Confidential"     // footer (default: Confidential)
  },
  "sections": [
    { "heading": "Engagement Summary", "blocks": [ /* content blocks */ ] }
    // sections auto-number 1..N in order (override with "n": <int>)
  ]
}
```

## Block types

Each entry in a section's `blocks[]` is one of:

| `type` | Fields | Renders |
|---|---|---|
| `para` (default) | `text` | A body paragraph. A bare string is treated as `para`. |
| `subhead` | `text` | A bold navy sub-heading within the section. |
| `bullets` | `items[]`, `level` (0/1) | A bulleted list (level 1 = nested dash). |
| `table` | `headers[]`, `rows[][]`, `widths_in[]?` | Branded table: blue header + zebra rows. `widths_in` are column widths in inches (content width ≈ 6.9"); omit for equal columns. |
| `callout` | `title?`, `body` (string or `[...]`) | Tinted panel with a blue left rule — use for commercials, key notes, flagged conflicts. |
| `fields` | `pairs`: `[[label,value], ...]` | A label/value form grid (2 pairs per row). Good for the engagement summary. |

Unknown block types degrade to their `text` (never crash the build).

## Conventions

- **Keep content in the spec, styling in the engine.** Never emit raw docx/colour/DXA —
  that is the anti-pattern this schema exists to remove (P-2.2 / P-4.5).
- **Flagged conflicts** (SKILL Step 4) → `callout` blocks; the **Clarification Log** →
  a `table` section that is always present.
- **`[TBD]`** values are literal strings in the spec and are logged in the Clarification
  Log — the build never invents content.
- Brand is fixed: BigStep blue `#1C62EC`, Poppins (embedded). Do not parameterise colour.

See `example/sow.example.json` for a complete worked spec.
