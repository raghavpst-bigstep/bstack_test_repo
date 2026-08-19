---
name: project-completion-certificate
preamble-tier: 2
version: 1.0.0
description: |
  Generate a premium, BigStep-branded Project Completion Certificate (.docx) —
  the formal artifact that certifies a project has been delivered in line with
  the agreed scope and acceptance criteria and has been accepted by the client.
  Use when asked for a "project completion certificate", "completion / handover
  certificate", "certificate of completion", "sign-off certificate", or to turn
  a delivered project's details into the branded certificate. Pre-fills the
  stakeholder details, deliverables & milestones table, completion confirmation,
  and warranty/handover terms from what is known, leaving the rest as a clean
  fillable certificate. Sits in the delivery/close-out family alongside
  /go-live-signoff and /document-release. (bstack)
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

# Project Completion Certificate

You are running the `/project-completion-certificate` workflow. You act as
**BigStep's Delivery Lead**: you produce the one-page, BigStep-branded
certificate a client and BigStep co-sign to formally close out a project. Your
job is to assemble the project facts, record what was actually delivered and
accepted, and hand back a document that is premium, accurate, and safe to
circulate — never to certify a completion or acceptance that has not happened.

The workflow is fixed: **gather the project facts → write a JSON spec → run the
build script → verify the rendered PDF → present the `.docx`.** You never
hand-place formatting; the builder renders every section in brand style from the
spec.

---

## Step 1: Locate the skill and set paths

The build script and bundled brand engine live in this skill's directory. Run in
place; do not copy assets around.

```bash
SKILL_DIR="$(dirname "$(readlink -f "$0" 2>/dev/null)")" 2>/dev/null || true
[ -d "$SKILL_DIR/scripts" ] || SKILL_DIR="$HOME/.claude/skills/project-completion-certificate"
[ -d "$SKILL_DIR/scripts" ] || SKILL_DIR=".claude/skills/project-completion-certificate"
echo "SKILL_DIR=$SKILL_DIR"
python3 -c "import docx, PIL, reportlab" 2>/dev/null || python3 -m pip install --user python-docx Pillow reportlab --quiet --break-system-packages
```

Read `references/content_spec.md` before writing the spec. If it cannot be read,
STOP and report the error — do not guess the schema.

---

## Step 2: Gather the project facts

Collect what you can from context before asking — a project brief, statement of
work, delivery plan, prior `/go-live-signoff` or `/document-release` run, or the
repo's changelog/milestones often already contain most of this. Aim to fill:

- **Details:** project/product, client/org, project/contract ref, certificate
  no., BigStep PM, client sponsor, start date, completion date.
- **Deliverables:** the milestones actually delivered and accepted, with status
  and delivery date. List only what was delivered — do not pad the table.
- **Confirmation:** whether the standard completion statement holds (UAT signed
  off, deployed & operational, Critical/High defects resolved, docs/source/KT
  provided). Adjust the wording if reality differs.
- **Warranty & handover:** defect-liability period, warranty dates, post-
  completion support, escalation path, outstanding/known issues, final payment
  status.

Ask the user **only** for facts you cannot infer, batched into ONE
`AskUserQuestion`. Good things to confirm: the completion date, the deliverables
list, the warranty terms, and the client sponsor.

**Safety rule — never certify what did not happen.** Do not mark a deliverable
"Accepted", state that completion criteria are met, or fill a signatory `name`,
`signature`, or `date` unless the user provides it. Roles may be pre-filled;
acceptances, approvals, and identities are left blank for real people to sign.

---

## Step 3: Write the JSON spec

Write a spec at `/tmp/project-completion-certificate.json` following
`references/content_spec.md`. Every field is optional — omit anything unknown and
it renders as a blank line. Skeleton:

```json
{
  "meta": { "version": "1.0", "classification": "Confidential" },
  "details": { "project_product": "", "client_org": "", "certificate_no": "" },
  "deliverables": [ { "deliverable": "", "status": "", "date": "" } ],
  "confirmation": "All in-scope deliverables handed over; UAT signed off; …",
  "warranty": { "warranty_liability": "", "warranty_dates": "" },
  "signoff": {
    "client":  { "name": "", "role": "", "signature": "", "date": "" },
    "bigstep": { "name": "", "role": "", "signature": "", "date": "" }
  }
}
```

A full, realistic example is in `example/certificate.example.json`.

---

## Step 4: Build

```bash
OUT_DIR="${OUT_DIR:-.}"
python3 "$SKILL_DIR/scripts/build.py" /tmp/project-completion-certificate.json "$OUT_DIR/Project-Completion-Certificate.docx"
```

With no spec argument, the script emits the blank certificate. The builder
embeds Poppins so the brand holds without a local font install.

---

## Step 5: Verify the rendered output

Never ship without looking at it:

```bash
soffice --headless --convert-to pdf "$OUT_DIR/Project-Completion-Certificate.docx" >/dev/null 2>&1
pdftoppm -jpeg -r 140 "$OUT_DIR/Project-Completion-Certificate.pdf" /tmp/pcc >/dev/null 2>&1
```

Read the image(s) and confirm: the centered certificate header renders, the
detail grids and deliverables table are aligned, the deliverables reflect what
was actually delivered, and signatures/acceptances are blank unless supplied.
The blank certificate is a single page; a certificate with many deliverables or
long values may run to two pages — acceptable, and the signature block moves
with it.

If a section overflowed by a line or two, shorten the offending prose
(confirmation text, long field values) in the spec and rebuild — do not fight
the layout by hand.

---

## Step 6: Present

Present `Project-Completion-Certificate.docx`. In one or two lines, state what
you pre-filled and what is intentionally left blank for the signatories
(typically names, signatures, and dates).

---

## Rules

- **Certify reality, don't manufacture it.** List only delivered/accepted items;
  never pre-sign, pre-accept, or pre-date on someone's behalf.
- **Brand comes from the builder.** Do not restyle by hand; edit the spec and
  rebuild.
- **One page for the blank certificate.** Preserve it; a filled certificate may
  extend.
- **Stay in lane.** This skill produces the completion certificate only.
  Go-live authorisation is /go-live-signoff; release docs are /document-release.
