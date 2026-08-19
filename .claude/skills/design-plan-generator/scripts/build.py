#!/usr/bin/env python3
"""
Build a BigStep-branded **Design Plan** workbook (.xlsx) from a JSON content spec.

Usage:
    python build.py                     # blank sample -> ./Design-Plan.xlsx
    python build.py spec.json           # populated    -> ./Design-Plan.xlsx
    python build.py spec.json out.xlsx  # populated    -> out.xlsx

The renderer is generic and spec-driven (see ../references/content_spec.md): the model
produces the CONTENT (sheets → tables/notes/kv), the script produces the branded WORKBOOK
— reproducible, on-brand, no hand-built cells or formulas (standards P-2.2 / P-4.5). The
same engine renders the Development Plan; only the spec differs. Table cells beginning
with '=' are written as Excel formulas (use for SUM totals).
"""
import sys, os, json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bigstep_xlsx as bx


def render_sheet(wb, sheet):
    ws = bx.add_sheet(wb, sheet.get("name", "Sheet"))
    row = 1
    # widest table in the sheet sets the title-band span
    ncols = 1
    for b in sheet.get("blocks", []):
        if b.get("type") == "table":
            ncols = max(ncols, len(b.get("headers", [])))
    if sheet.get("title"):
        row = bx.title_band(ws, row, sheet["title"], ncols)
        row += 1
    for b in sheet.get("blocks", []):
        t = b.get("type", "table")
        if t == "table":
            row = bx.table(ws, row, b.get("headers", []), b.get("rows", []),
                           b.get("widths"), total=b.get("total"))
        elif t == "note":
            row = bx.note(ws, row, b.get("title", ""), b.get("text", ""), ncols=max(2, ncols))
        elif t == "kv":
            row = bx.kv(ws, row, b.get("pairs", []))
        elif t in ("subhead", "heading"):
            c = ws.cell(row=row, column=1, value=b.get("text", ""))
            from openpyxl.styles import Font
            c.font = Font(name=bx.FONT, size=11, bold=True, color=bx.C.NAVY)
            row += 2
        else:
            if b.get("text"):
                row = bx.note(ws, row, "", b["text"], ncols=max(2, ncols))
    ws.sheet_view.zoomScale = 100


def build(spec, out_path):
    wb = bx.new_workbook()
    for sheet in spec.get("sheets", []):
        render_sheet(wb, sheet)
    if not wb.sheetnames:              # never save an empty workbook
        bx.add_sheet(wb, "Sheet")
    return bx.save(wb, out_path)


SAMPLE = {
    "meta": {"title": "Design Plan"},
    "sheets": [{
        "name": "Design Scope", "title": "Design Plan — Sample",
        "blocks": [
            {"type": "table", "headers": ["Activity", "Pages", "Effort (days)"],
             "rows": [["UX audit", "All", 3], ["Wireframes", "12", 8]],
             "total": {"label": "Total", "sum_cols": [3]}, "widths": [30, 12, 14]},
            {"type": "note", "title": "Assumptions",
             "text": "Replace with a real spec — see references/content_spec.md."}
        ]}],
}


def main():
    args = sys.argv[1:]
    spec = SAMPLE
    out = os.environ.get("OUT", "Design-Plan.xlsx")
    if args:
        if args[0].endswith(".json"):
            with open(args[0]) as f:
                spec = json.load(f)
            if len(args) > 1:
                out = args[1]
        else:
            out = args[0]
    print("saved:", build(spec, out))


if __name__ == "__main__":
    main()
