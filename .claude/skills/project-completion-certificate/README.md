# project-completion-certificate (bstack skill)

Generates a premium, **BigStep-branded Project Completion Certificate** (`.docx`)
— the formal artifact certifying a project was delivered per the agreed scope and
acceptance criteria and accepted by the client.

Follows the bstack skill format; sits in the delivery/close-out family alongside
`/go-live-signoff` and `/document-release`.

## Install

Copy this folder into your skills directory (self-contained — bundles the brand
engine, Poppins fonts, and logos):

```
~/.claude/skills/project-completion-certificate/
```

`SKILL.md` is directly loadable. `SKILL.md.tmpl` is the authoring source;
regenerate `SKILL.md` from it when the template changes.

## Use

Invoke `/project-completion-certificate` and describe the delivered project, or
ask for the blank certificate.

```bash
python3 scripts/build.py                                   # blank certificate
python3 scripts/build.py example/certificate.example.json out.docx   # populated
```

## Layout

```
project-completion-certificate/
├── SKILL.md / SKILL.md.tmpl
├── README.md
├── scripts/  build.py · bigstep_brand.py · embed_fonts.py
├── assets/   logos + Poppins TTFs
├── references/content_spec.md
└── example/  certificate.example.json
```
