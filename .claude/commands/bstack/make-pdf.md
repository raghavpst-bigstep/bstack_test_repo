---
name: bstack:make-pdf
description: 'Markdown → publication-quality PDF — 1" margins, page breaks, TOC, page numbers, optional cover, DRAFT watermark'
argument-hint: '[markdown path] [--out=path.pdf] [--cover=title:subtitle] [--draft]'
model: haiku
---

# /bstack:make-pdf

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.

Turn any markdown into a finished PDF artifact. Not a draft preview — real margins, page numbers, clickable TOC, curly quotes, em dashes.

## Pre-flight

Check renderer is available — prefer `pandoc` + a LaTeX engine (`xelatex` or `tectonic`):

```bash
command -v pandoc && command -v tectonic
```

If missing, suggest:

```bash
brew install pandoc tectonic
```

(Fallback: `npx md-to-pdf` for quick render — less control, no LaTeX needed.)

## Steps

1. **Resolve input** — path arg, or ask. Confirm file exists.
2. **Output path** — `--out` or default `<input-basename>.pdf` next to the source.
3. **Cover page** — if `--cover=title:subtitle` passed, render: title (large), subtitle (medium), date, author (from `git config user.name`).
4. **Frontmatter pass** — if the markdown has YAML frontmatter (`title:`, `author:`, `date:`), feed it to pandoc as metadata.
5. **Render** — `pandoc <in> -o <out> --pdf-engine=tectonic --toc --toc-depth=3 -V geometry:margin=1in -V mainfont="Inter" -V linkcolor=blue --highlight-style=tango`. Add `--metadata-file=cover.yaml` if cover requested.
6. **DRAFT watermark** — if `--draft`, post-process to overlay diagonal "DRAFT" text on every page (LaTeX `draftwatermark` package via custom header file).
7. **Verify** — open the PDF, confirm page count > 0, file size reasonable. `open <out>` if on macOS.
8. **Report** — one line: output path, page count, size.

## Quality bar

- Margins: 1 inch on all sides (US Letter default; `--paper=a4` switches to A4 with metric margins).
- Page numbers: bottom-center, starting at the first content page.
- TOC: clickable, page-numbered, 3 levels deep.
- Curly quotes + em dashes: pandoc handles via `--from=markdown+smart`.
- Code blocks: monospace, light background, no overflow.
- Images: scaled to fit, never cropped.

## Hard rules

- Never silently strip frontmatter — use it for metadata.
- If TOC is empty (no `##` headers), skip it rather than render an empty page.
- If the source has fewer than ~2 pages of content, skip the cover unless explicitly requested.
