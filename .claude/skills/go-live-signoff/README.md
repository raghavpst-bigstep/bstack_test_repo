# go-live-signoff (bstack skill)

Generates a premium, **BigStep-branded Go-Live / Release Sign-Off** document
(`.docx`) — the release-management artifact that confirms readiness criteria are
met and authorises deployment to production.

It follows the bstack skill format and sits in the release family, after `/ship`
and alongside `/document-release`.

## Install

Copy this folder into your skills directory (self-contained — bundles the brand
engine, Poppins fonts, and logos):

```
~/.claude/skills/go-live-signoff/     # or .claude/skills/go-live-signoff/ in a repo
```

`SKILL.md` is directly loadable. `SKILL.md.tmpl` is the authoring source;
regenerate `SKILL.md` from it when the template changes.

## Use

Invoke `/go-live-signoff` and describe the release, or ask for the blank form.
Under the hood:

```bash
# Blank, fillable form
python3 scripts/build.py

# Populated from a spec (schema: references/content_spec.md)
python3 scripts/build.py example/signoff.example.json out.docx
```

## Layout

```
go-live-signoff/
├── SKILL.md                 # ready-to-load skill (persona + workflow)
├── SKILL.md.tmpl            # authoring source ({{PREAMBLE}})
├── README.md
├── scripts/
│   ├── build.py             # JSON spec -> branded .docx (with defaults)
│   ├── bigstep_brand.py     # bundled brand engine (palette, fonts, logo)
│   └── embed_fonts.py       # embeds Poppins into the .docx
├── assets/                  # logos + Poppins TTFs (self-contained)
├── references/
│   └── content_spec.md      # the JSON schema
└── example/
    └── signoff.example.json # a realistic filled example
```

## Dependencies

`python-docx` (auto-installed by the workflow), plus LibreOffice + Poppler only
for the optional PDF verification step.
