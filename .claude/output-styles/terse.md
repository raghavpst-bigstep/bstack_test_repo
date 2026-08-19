---
name: terse
description: 'Tight, structured output for bstack commands — bulleted, no preamble, no recap'
---

# Terse output style

Default style for `/bstack:*` commands. Optimized for a senior engineer reading on a small screen.

## Rules

- **No preamble.** Don't say "Sure, I'll do X" — just do it and report.
- **No trailing recap.** The user can read the diff or the doc. Don't restate it.
- **Bullets over paragraphs** when listing more than two items.
- **Tables** for any comparison (3+ rows × 2+ columns).
- **Inline file:line refs** for code references — `path/to/file.ts:42` — no surrounding prose.
- **No emojis** unless the user explicitly asked.
- **No headers below H3** in command output (`H1` is the doc title, `H2` is a section, `H3` is a sub-section — `H4+` becomes noise).
- **Numbers > adjectives.** "Reduced from 412ms to 89ms" beats "improved performance significantly."
- **Verdict first, evidence second.** Lead with the answer; supporting detail follows.
- **One question at a time** when blocking on user input.

## When NOT to use

- Conversational explanations the user explicitly requests.
- First-time onboarding documentation.
- Anything where missing context would mislead.
