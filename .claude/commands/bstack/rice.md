---
name: bstack:rice
description: 'R.I.C.E. feature-architect gate — ask the four questions, emit R/I/C/E block consumed by plan/implement/review. New-feature work only.'
argument-hint: '[file or app path — optional; defaults to pwd]'
model: opus
---

# /bstack:rice

> **STOP. Do not read files, explore the codebase, or launch agents yet. Ask the four questions first.**
>
> **TASK TRACKING:** Create one task per R.I.C.E. answer (R, I, C, E). Mark each complete as it is captured.

The architect-protocol gate for **new** screens, features, endpoints, components, hooks, services, repositories, and modules. For modifications to existing code, do **not** invoke this — match that file's established patterns. For code reviews, use `/bstack:review`.

## Steps

1. **Resolve SKILL.md** — run `bin/bstack-rice path "$ARG"` (where `$ARG` is the argument or `pwd`). The script prints the inheritance chain (most-specific first, then `extends:` chain back to a base). If it exits non-zero, tell the user "no feature-protocol resolvable — run `/bstack:rice-init` first" and stop.

2. **Read the chain** — `Read` each SKILL.md in the chain. Merge semantically: per-app overrides win on conflicts; **Forbidden lists are unioned** (never subtract a base ban). The merged Role / Intent / Context / Enforcement is the default for this turn.

3. **Ask the four questions, one at a time, in order.** Each accepts `use default`. Wait for each answer before asking the next.

   1. **R — Role:** "Any extra constraints on the architect role for this feature? (examples from your SKILL.md Role section.) — or **'use default'**."
   2. **I — Intent:** "Any extra acceptance criteria? (e.g. which domain rule IDs apply, feature flag, role visibility, E2E coverage required) — or **'use default'**."
   3. **C — Context:** "Any extra context to load? (e.g. spec section, design artifact, neighboring feature folder) — or **'use default'**."
   4. **E — Enforcement:** "Any extra non-negotiables? (e.g. no new heavy dependency, must add schema validation, must add unit + E2E tests) — or **'use default'**."

   Skip a question only when the user has already supplied that field in the same turn. Skip all four only when the user has explicitly said so.

4. **Emit the structured block.** Write it to the conversation verbatim — downstream commands (`/bstack:plan`, `/bstack:spec`, `/bstack:implement`, `/bstack:review`) read it as authoritative:

   ```markdown
   ## R — Role
   <merged defaults from SKILL.md Role + any **extras** called out separately as "extras:">

   ## I — Intent
   <merged defaults from SKILL.md Intent + extras>

   ## C — Context
   <merged defaults from SKILL.md Context (locked stack, folder layout, source of truth, forbidden list) + extras>

   ## E — Enforcement
   <numbered list from SKILL.md Enforcement + extras (additive — never delete a base invariant)>
   ```

5. **Hand off.** If the user's original prompt was an implementation request, suggest `/bstack:plan` next. The plan command's Step 0 will detect the R/I/C/E block and embed it into the plan file.

## Conventions

- Extras are **additive**. Never delete or weaken a Role / Intent / Enforcement default; only stack onto it.
- Forbidden list is **union, never subtract** across the inheritance chain.
- If a user's extra contradicts an Enforcement default, flag the conflict explicitly and ask the user to choose — do not silently override.
- The four-question gate runs **once per feature**, not once per file. Re-invoke only when the feature scope changes.
