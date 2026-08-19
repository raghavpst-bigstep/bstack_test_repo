# uat-signoff (bstack skill)

Generates a premium, **BigStep-branded UAT (User Acceptance Testing) Sign-Off**
(`.docx`) — the artifact by which a client formally accepts that a solution meets
the agreed acceptance criteria and is fit for production.

Follows the bstack skill format; sits in the delivery family before
`/go-live-signoff` and alongside `/project-completion-certificate`.

## Install

Copy this folder into your skills directory (self-contained — bundles the brand
engine, Poppins fonts, and logos):

```
~/.claude/skills/uat-signoff/
```

`SKILL.md` is directly loadable. `SKILL.md.tmpl` is the authoring source;
regenerate `SKILL.md` from it when the template changes.

## Use

Invoke `/uat-signoff` and describe the UAT cycle, or ask for the blank form.

```bash
python3 scripts/build.py                            # blank form
python3 scripts/build.py example/uat.example.json out.docx   # populated
```

## Layout

```
uat-signoff/
├── SKILL.md / SKILL.md.tmpl
├── README.md
├── scripts/  build.py · bigstep_brand.py · embed_fonts.py
├── assets/   logos + Poppins TTFs
├── references/content_spec.md
└── example/  uat.example.json
```
