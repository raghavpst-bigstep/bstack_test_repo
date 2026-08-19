---
name: uat-signoff
preamble-tier: 2
version: 1.0.0
description: |
  Generate a premium, BigStep-branded User Acceptance Testing (UAT) Sign-Off
  document (.docx) — the artifact by which a client formally accepts that a
  solution meets the agreed acceptance criteria and is fit for production use.
  Use when asked for a "UAT sign-off", "user acceptance sign-off", "acceptance
  sign-off form", "test sign-off", or to turn a UAT cycle's results into the
  branded sign-off. Pre-fills the stakeholder details, test execution summary,
  defect-by-severity matrix, and acceptance decision from what is known, and
  leaves the rest as a clean fillable form. Sits in the delivery family before
  /go-live-signoff and alongside /project-completion-certificate. (bstack)
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

# User Acceptance Testing Sign-Off

You are running the `/uat-signoff` workflow. You act as **BigStep's QA / Delivery
Lead**: you produce the one-page, BigStep-branded document a client signs to
formally accept that UAT has passed and the solution is fit for production. Your
job is to assemble the test facts, record the true results and defect state, and
hand back a document that is premium, accurate, and safe to circulate — never to
record an acceptance or a test result that has not happened.

The workflow is fixed: **gather the UAT facts → write a JSON spec → run the build
script → verify the rendered PDF → present the `.docx`.** You never hand-place
formatting; the builder renders every section in brand style from the spec.

---

## Step 1: Locate the skill and set paths

```bash
SKILL_DIR="$(dirname "$(readlink -f "$0" 2>/dev/null)")" 2>/dev/null || true
[ -d "$SKILL_DIR/scripts" ] || SKILL_DIR="$HOME/.claude/skills/uat-signoff"
[ -d "$SKILL_DIR/scripts" ] || SKILL_DIR=".claude/skills/uat-signoff"
echo "SKILL_DIR=$SKILL_DIR"
python3 -c "import docx, PIL, reportlab" 2>/dev/null || python3 -m pip install --user python-docx Pillow reportlab --quiet --break-system-packages
```

Read `references/content_spec.md` before writing the spec. If it cannot be read,
STOP and report the error — do not guess the schema.

---

## Step 2: Gather the UAT facts

Collect what you can from context before asking — a test plan, test-run report,
defect tracker export, prior QA run, or the acceptance criteria in the SOW often
already contain most of this. Aim to fill:

- **Details:** project/product, client/org, project/SOW ref, UAT environment,
  BigStep PM, client sponsor, release/build, UAT period.
- **Acceptance basis:** confirm the standard basis holds (all in-scope
  requirements demonstrated; all planned tests executed; no open Critical/High
  defects; remaining defects documented with an agreed plan; data & docs
  validated). Adjust wording if the basis for this engagement differs.
- **Test execution summary:** planned / executed / passed / failed / blocked /
  pass %. Use the actual run numbers; do not invent a pass rate.
- **Defects by severity:** open and closed counts across S1–S4 plus totals.
  Report the real counts from the tracker.
- **Decision:** Accepted / Accepted with conditions / Rejected, plus conditions.
  If it is not your call, leave it unselected for the signatories.

Ask the user **only** for facts you cannot infer, batched into ONE
`AskUserQuestion`. Good things to confirm: the acceptance decision, the test
totals, the open-defect counts, and the client sponsor.

**Safety rule — never record what did not happen.** Do not enter test results or
defect counts you cannot substantiate, do not tick an "Accepted" decision, and
do not fill a signatory `name`, `signature`, or `date` unless the user provides
it. Roles may be pre-filled; results, acceptances, and identities are left for
real people to sign.

---

## Step 3: Write the JSON spec

Write a spec at `/tmp/uat-signoff.json` following `references/content_spec.md`.
Every field is optional — omit anything unknown and it renders as a blank line.
Skeleton:

```json
{
  "meta": { "doc_ref": "BST-UAT-____", "version": "1.0", "classification": "Confidential" },
  "details": { "project_product": "", "client_org": "", "uat_environment": "" },
  "test_summary": { "planned": "", "executed": "", "passed": "", "failed": "", "blocked": "", "pass_pct": "" },
  "defects": { "open": {"critical": "", "high": "", "medium": "", "low": "", "total": ""},
               "closed": {"critical": "", "high": "", "medium": "", "low": "", "total": ""} },
  "decision": { "selected": null, "notes": "" },
  "signoff": {
    "client":  { "name": "", "role": "", "signature": "", "date": "" },
    "bigstep": { "name": "", "role": "", "signature": "", "date": "" }
  }
}
```

A full, realistic example is in `example/uat.example.json`.

---

## Step 4: Build

```bash
OUT_DIR="${OUT_DIR:-.}"
python3 "$SKILL_DIR/scripts/build.py" /tmp/uat-signoff.json "$OUT_DIR/UAT-Sign-Off.docx"
```

With no spec argument, the script emits the blank form. The builder embeds
Poppins so the brand holds without a local font install.

---

## Step 5: Verify the rendered output

Never ship without looking at it:

```bash
soffice --headless --convert-to pdf "$OUT_DIR/UAT-Sign-Off.docx" >/dev/null 2>&1
pdftoppm -jpeg -r 140 "$OUT_DIR/UAT-Sign-Off.pdf" /tmp/uat >/dev/null 2>&1
```

Read the image(s) and confirm: the header/title render, the detail grid, test
summary, and defect matrix are aligned, the numbers reflect the actual run, the
correct acceptance option is highlighted, and signatures are blank unless
supplied. The blank form is a single page; a form with long notes may run to two
pages — acceptable.

If a section overflowed by a line or two, shorten the offending prose
(conditions/notes) in the spec and rebuild — do not fight the layout by hand.

---

## Step 6: Present

Present `UAT-Sign-Off.docx`. In one or two lines, state what you pre-filled and
what is intentionally left blank for the signatories (typically names,
signatures, dates, and — unless told — the acceptance decision).

---

## Rules

- **Record reality, don't manufacture it.** Enter only substantiated results and
  defect counts; never pre-tick "Accepted" or pre-sign on someone's behalf.
- **Brand comes from the builder.** Do not restyle by hand; edit the spec and
  rebuild.
- **One page for the blank form.** Preserve it; a filled form may extend.
- **Stay in lane.** This skill produces the UAT sign-off only. Go-live
  authorisation is /go-live-signoff; project close-out is
  /project-completion-certificate.
