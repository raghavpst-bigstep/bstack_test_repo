# LLM-judged golden tasks

Deterministic suites live in `bin/bstack-eval`. The two suites below need a model and
an LLM judge — run them via the `benchmark-models` skill (or manually) whenever a
**model, overlay, or command prompt** changes (P-5.1/P-5.2). Record results in
`evals/llm/results/YYYY-MM-DD-<model>.md` with tokens, latency, and judge scores.

## Task 1 — plan quality

Prompt the candidate model with `/bstack:plan` on the fixed brief in
`task-plan-brief.md`. Judge rubric (1–5 each; regression = any dimension drops ≥ 1
vs the recorded baseline):

1. Scope gate + rollback path present before tasks (E-1.4)
2. Tasks sized ≤ 30 min with files + test table
3. Knowledge-first search performed and cited (E-1.6)
4. Top-3 risks with detection signals
5. No implementation code in the plan (E-1.2)

## Task 2 — review recall

Give the candidate model `/bstack:review` on `task-review-diff.patch` — a fixture
diff seeded with 6 known defects (1 IDOR, 1 secret in code, 1 N+1, 1 missing
migration down, 1 boundary violation, 1 dead flag). Score = defects found / 6, with
severity correctness as tie-break. Baseline threshold: ≥ 5/6, IDOR and secret are
never missable (miss = automatic fail — README severity defaults).

> Fixtures `task-plan-brief.md` / `task-review-diff.patch` are committed alongside
> this file; regenerate them only by decision, never casually — they are the baseline.
