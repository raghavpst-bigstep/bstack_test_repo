---
name: go-live-signoff
preamble-tier: 2
version: 1.0.0
description: |
  Generate a premium, BigStep-branded Go-Live / Release Sign-Off document
  (.docx) — the release-management artifact that confirms a release has met its
  readiness criteria and authorises deployment to production. Use when asked for
  a "go-live sign-off", "release sign-off", "deployment approval / authorisation
  form", "go/no-go form", or to turn a release's current status into the branded
  sign-off. Pre-fills the readiness checklist, go/no-go decision, rollback plan,
  and release details from what is known about the release, and leaves the rest
  as a clean fillable form. Sits in the release family after /ship and alongside
  /document-release. (bstack)
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
triggers:
  - go-live sign-off
  - release sign-off
  - go/no-go form
  - deployment approval form
  - release authorisation
---

# Go-Live / Release Sign-Off

You are running the `/go-live-signoff` workflow. You act as **BigStep's Release
Manager**: you produce the one-page, BigStep-branded document that a client and
BigStep co-sign to authorise a production deployment. Your job is to assemble
the release facts, reflect the true readiness state, and hand back a document
that is premium, accurate, and safe to circulate — never to invent approvals.

The workflow is fixed: **gather the release facts → write a JSON spec → run the
build script → verify the rendered PDF → present the `.docx`.** You never
hand-place formatting; the builder renders every section in brand style from the
spec.

---

## Step 1: Locate the skill and set paths

The build script and bundled brand engine live in this skill's directory. Do not
copy assets around — run in place.

```bash
SKILL_DIR="$(dirname "$(readlink -f "$0" 2>/dev/null)")" 2>/dev/null || true
# Fallback: this skill is installed under the skills root.
[ -d "$SKILL_DIR/scripts" ] || SKILL_DIR="$HOME/.claude/skills/go-live-signoff"
[ -d "$SKILL_DIR/scripts" ] || SKILL_DIR=".claude/skills/go-live-signoff"
echo "SKILL_DIR=$SKILL_DIR"
python3 -c "import docx, PIL, reportlab" 2>/dev/null || python3 -m pip install --user python-docx Pillow reportlab --quiet --break-system-packages
```

Read `references/content_spec.md` in the skill directory before writing the
spec. If it cannot be read, STOP and report the error — do not guess the schema.

---

## Step 2: Gather the release facts

Collect what you can from the current context before asking the user — a
release/PR, a `VERSION` file, changelog, deploy config, or a prior `/ship` /
`/document-release` run often already contains most of this. Aim to fill:

- **Details:** project/product, client/org, release version, release type
  (major/minor/patch/hotfix), BigStep release manager, client release owner,
  target environment, go-live date & time, deployment window, expected downtime.
- **Readiness:** for each of the standard checklist items, is it actually done?
  Only tick items you have evidence for. Leave the rest unticked.
- **Rollback:** trigger/criteria, method, estimated time, backup recovery point,
  decision owner.
- **Decision:** Go / Conditional Go / No-Go, plus any conditions. If it is not
  your call to make, leave it unselected for the signatories.

Ask the user **only** for facts you cannot infer, and batch them into ONE
`AskUserQuestion`. Good things to confirm: the go/no-go decision, the target
environment and window, and the client/BigStep owners. Do not ask for anything
already visible in context.

**Safety rule — never fabricate authorisation.** Do not fill in a signatory
`name`, `signature`, or `date`, and do not mark a Go decision, unless the user
explicitly states that person/decision. Roles may be pre-filled; identities and
approvals are left blank for real people to sign.

---

## Step 3: Write the JSON spec

Write a spec file at `/tmp/go-live-signoff.json` (or the working directory)
following `references/content_spec.md`. Every field is optional — omit anything
unknown and it renders as a blank line. Example skeleton:

```json
{
  "meta": { "doc_ref": "BST-GL-____", "version": "1.0", "classification": "Confidential" },
  "details": { "project_product": "", "client_org": "", "release_version": "", "release_type": "" },
  "readiness": [ { "text": "UAT completed and signed off", "checked": false } ],
  "rollback": "Trigger / criteria, method, estimated time, backup recovery point and decision owner.",
  "decision": { "selected": null, "notes": "" },
  "signoff": {
    "client":  { "name": "", "role": "", "signature": "", "date": "" },
    "bigstep": { "name": "", "role": "", "signature": "", "date": "" }
  }
}
```

A full, realistic example is in `example/signoff.example.json`.

---

## Step 4: Build

```bash
OUT_DIR="${OUT_DIR:-.}"
python3 "$SKILL_DIR/scripts/build.py" /tmp/go-live-signoff.json "$OUT_DIR/Go-Live-Release-Sign-Off.docx"
```

With no spec argument, the script emits the blank template — use that if the
user just wants the empty form. The builder embeds Poppins so the brand holds
without a local font install.

---

## Step 5: Verify the rendered output

Never ship without looking at it. Render to PDF and inspect:

```bash
soffice --headless --convert-to pdf "$OUT_DIR/Go-Live-Release-Sign-Off.docx" >/dev/null 2>&1
pdftoppm -jpeg -r 140 "$OUT_DIR/Go-Live-Release-Sign-Off.pdf" /tmp/gls >/dev/null 2>&1
```

Read the resulting image(s) and confirm: the logo and title render, the field
grid and checklist are aligned, ticked items reflect the true readiness state,
the correct go/no-go option is highlighted, and signatures are blank. The blank
template must be a single page; a heavily-filled form may run to two pages,
which is acceptable.

If a section overflowed by a line or two, shorten the offending prose (rollback
text, notes) in the spec and rebuild — do not fight the layout by hand.

---

## Step 6: Present

Present `Go-Live-Release-Sign-Off.docx` as the deliverable. In one or two lines,
state what you pre-filled and what is intentionally left blank for the
signatories (typically names, signatures, dates, and — unless told — the go/no-go
decision).

---

## Rules

- **Reflect reality, don't invent it.** Tick only verified readiness items;
  never pre-sign or pre-approve on someone's behalf.
- **Brand comes from the builder.** Do not restyle by hand; edit the spec and
  rebuild.
- **One page for the blank form.** Preserve it; a filled form may extend.
- **Stay in lane.** This skill produces the sign-off document only. Actual
  deployment, PR creation, and post-deploy checks belong to /ship, /land-and-deploy,
  and /canary.
