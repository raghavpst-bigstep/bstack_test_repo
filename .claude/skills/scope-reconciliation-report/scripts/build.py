#!/usr/bin/env python3
"""
Build a BigStep-branded **Statement of Work** (.docx) from a JSON content spec.

Usage:
    python build.py                     # blank sample -> ./Statement-of-Work.docx
    python build.py spec.json           # populated    -> ./Statement-of-Work.docx
    python build.py spec.json out.docx  # populated    -> out.docx
    OUT=/path/out.docx python build.py spec.json

The renderer is generic and spec-driven (see ../references/content_spec.md): the
model produces the CONTENT (a JSON spec), the script produces the branded DOCUMENT.
This keeps every run reproducible and on-brand without the model hand-building docx
(standards P-2.2 deterministic pre-pass, P-4.5 codify the transform). The same
engine renders the Scope Reconciliation report — only the spec differs.
"""
import sys, os, json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bigstep_docx as bd
from bigstep_brand import C


def _title_parts(meta):
    if meta.get("title_lead") or meta.get("title_tail"):
        return meta.get("title_lead", ""), meta.get("title_tail", "")
    title = meta.get("title", "Statement of Work")
    words = title.split()
    if len(words) == 1:
        return "", title
    return " ".join(words[:-1]) + " ", words[-1]


def render_block(doc, block):
    """Dispatch one content block. A bare string is treated as a paragraph."""
    if isinstance(block, str):
        bd.para(doc, [(block, 9.5, C.SLATE, False)], after=4)
        return
    t = block.get("type", "para")
    if t in ("para", "paragraph", "text"):
        bd.para(doc, [(block.get("text", ""), 9.5, C.SLATE, False)], after=4)
    elif t in ("subhead", "subheading"):
        bd.subhead(doc, block.get("text", ""))
    elif t in ("bullets", "list"):
        bd.bullets(doc, block.get("items", []), level=block.get("level", 0))
    elif t == "table":
        bd.branded_table(doc, block.get("headers", []), block.get("rows", []),
                          widths_in=block.get("widths_in"))
    elif t == "callout":
        body = block.get("body")
        if body is None:
            body = [block.get("text", "")]
        elif isinstance(body, str):
            body = [body]
        bd.callout(doc, block.get("title", ""), body)
    elif t in ("fields", "form"):
        flat = block.get("pairs", [])
        pairs = []
        for i in range(0, len(flat), 2):
            left = tuple(flat[i])
            right = tuple(flat[i + 1]) if i + 1 < len(flat) else ("", "")
            pairs.append((left, right))
        if pairs:
            bd.field_grid(doc, pairs)
    else:
        # unknown block type: render its text if any, never crash the build
        if block.get("text"):
            bd.para(doc, [(block["text"], 9.5, C.SLATE, False)], after=4)


def build(spec, out_path):
    meta = spec.get("meta", {})
    doc = bd.new_document(meta)

    lead, tail = _title_parts(meta)
    bd.two_tone_title(doc, lead, tail, size=18, before=0, after=1)
    bd.accent_rule(doc, 1.6)
    if meta.get("subtitle"):
        bd.spacer(doc, 1)
        bd.para(doc, [(meta["subtitle"], 9.5, C.SLATE, False)], after=4, line=1.15)

    for idx, section in enumerate(spec.get("sections", []), start=1):
        n = section.get("n", idx)
        bd.section_head(doc, n, section.get("heading", ""))
        for block in section.get("blocks", []):
            render_block(doc, block)

    return bd.finalize(doc, out_path)


SAMPLE = {
    "meta": {"title": "Statement of Work", "subtitle": "Sample document — replace with a real spec.",
             "doc_ref": "BST-SOW-____", "version": "1.0"},
    "sections": [{"heading": "Overview", "blocks": [
        {"type": "para", "text": "This is a blank Statement of Work rendered from an empty spec."},
        {"type": "bullets", "items": ["Provide a JSON spec to populate real content.",
                                      "See references/content_spec.md for the schema."]}]}],
}


def main():
    args = sys.argv[1:]
    spec = SAMPLE
    out = os.environ.get("OUT", "Statement-of-Work.docx")
    if args:
        if args[0].endswith(".json"):
            with open(args[0]) as f:
                spec = json.load(f)
            if len(args) > 1:
                out = args[1]
        else:
            out = args[0]
    path = build(spec, out)
    print("saved + fonts embedded:", path)


if __name__ == "__main__":
    main()
