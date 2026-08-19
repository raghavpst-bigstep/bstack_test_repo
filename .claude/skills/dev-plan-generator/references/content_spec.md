# Development Plan — content spec (JSON schema)

`scripts/build.py` renders a BigStep-branded `.xlsx` from a JSON **content spec** — the
same engine and block model as the design-plan generator (see its
`references/content_spec.md` for the full reference). You produce content; the script owns
the brand (BigStep blue `#1C62EC`, Poppins, borders, zebra rows, computed totals).

```bash
python3 scripts/build.py spec.json out.xlsx
```

## Shape

```jsonc
{
  "meta": { "title": "Development Plan", "doc_ref": "BST-DEV-2026-041", "version": "1.0" },
  "sheets": [ { "name": "Tech Stack", "title": "Proposed Tech Stack", "blocks": [ /* ... */ ] } ]
}
```

Each of the plan's sheets (Tech Stack, MVP Development Plan, Design Plan, Engagement Model,
Team Structure, Delivery Timeline, Dependencies, Assumptions, QA & Testing, Infrastructure
Cost, Post-MVP) is one `sheets[]` entry. Include only the sheets that apply.

## Blocks

`table` (`headers`, `rows`, `widths?`, `total?`), `note` (`title?`, `text`), `kv`
(`pairs`), `subhead` (`text`). Identical to the design-plan engine.

## Totals & effort — deterministic, not fragile

- Man-days / counts / cost are JSON **numbers**.
- For a column sum, add `total: {"label": "Total", "sum_cols": [<1-based col>]}`. The engine
  computes the `=SUM(...)` range from the real rendered rows — **do not** author
  `=SUM(C2:C6)` (a title band offsets positions; authored refs break — P-2.2 / P-4.5).
- Man-months = man-days / 20: compute the value in the spec (a number), for reproducibility.

See `example/dev.example.json` for a worked multi-sheet spec with a totals row.
