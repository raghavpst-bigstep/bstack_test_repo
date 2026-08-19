# Scope Reconciliation — content spec (JSON schema)

`scripts/build.py` renders a BigStep-branded `.docx` from a JSON **content spec** — the
same engine and schema as the SOW generator. You produce the content; the script owns the
brand (palette, Poppins, tables, header/footer).

```bash
python3 scripts/build.py spec.json out.docx
```

## Shape

```jsonc
{
  "meta": {
    "title": "Scope Reconciliation Report",
    "subtitle": "Acme Loyalty · prepared by BigStep · SOW v1.0 + Gmail evidence Apr–Jun 2026",
    "doc_ref": "BST-SCR-2026-014", "version": "1.0", "classification": "Confidential"
  },
  "sections": [ { "heading": "...", "blocks": [ /* content blocks */ ] } ]
}
```

## Block types

| `type` | Fields | Use for |
|---|---|---|
| `para` (default) | `text` | Prose, per-thread assessments. |
| `subhead` | `text` | Per-thread sub-heading (`[subject] — [date]`). |
| `bullets` | `items[]`, `level` | In-scope by area, exclusions, CR activity, observations. |
| `table` | `headers[]`, `rows[][]`, `widths_in[]?` | The Summary Flags table (`# / Item / Source / Classification`). |
| `callout` | `title?`, `body` | The scope-guard lock-in clauses. |
| `fields` | `pairs[[label,value]]` | Optional header metadata grid. |

## Conventions

- Put the **classification** (e.g. "Out of Scope — CR Needed", "In Scope — Defect") in its
  own column in the flags `table` — readable and unambiguous without colour coding.
- **Critical conflicts** surfaced in Step 4 → a `callout`; unresolved items are noted in the
  Overarching Observations section.
- `[TBD]` values stay literal and are surfaced in the observations — the build never invents.
- Brand is fixed: BigStep blue `#1C62EC`, Poppins (embedded). Do not parameterise colour.

See `example/scope.example.json` for a complete worked spec, and the SOW generator's
`references/content_spec.md` for the full block reference (identical engine).
