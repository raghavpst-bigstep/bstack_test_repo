---
name: bstack:context
description: 'Save or restore working session context — files in flight, todos, decisions, next-step notes'
argument-hint: '[--save | --restore | --list] [--name=<label>]'
model: haiku
---

# /bstack:context

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.

Capture the working state of a session so it can be resumed later (or after a restart). Stores under `.claude/context/<label>.md`.

## Modes

### `--save` (default if no flag)

1. Detect label — `--name` arg, else slugify the topic from recent conversation, else `wip-YYYY-MM-DD-HHmm`.
2. Capture:
   - Branch + last 3 commits + uncommitted file list (paths only, no content)
   - Files actively being edited (from recent Edit/Write tool calls if visible, else `git status --porcelain`)
   - Current TaskCreate list
   - Open Linear ticket(s) referenced this session
   - Last 5 substantive user/assistant turns summarized to 1–2 sentences each
   - Decisions made this session (extracted explicitly)
   - The IMMEDIATE next step in one sentence
3. Write to `.claude/context/<label>.md` with YAML frontmatter (saved_at, branch, label, linear_ticket).
4. Report: path + one-line next-step.

### `--restore`

1. Resolve label — arg, else newest file in `.claude/context/`.
2. Read the file.
3. Summarize back to the user: branch, decisions, todo list, immediate next step.
4. Confirm git branch matches; warn if not.
5. Re-create TaskCreate entries from the saved todo list.
6. End with: "Resuming from: <one-line next step>. Continue?"

### `--list`

1. List files in `.claude/context/` newest-first with: label, saved_at, branch, immediate next-step (one line each).

## File format

```yaml
---
label: <kebab-case>
saved_at: <ISO 8601>
branch: <git branch>
linear_ticket: <id or null>
---

## Decisions
- ...

## Todos
- [ ] ...

## Open files
- path/to/file.ts

## Last turns (summarized)
- user: ...
- assistant: ...

## Immediate next step
<one sentence>
```

## Hard rules

- Never store secrets / .env contents / tokens, even if they appear in conversation.
- Never store full file contents — paths and snippets only.
- `.claude/context/` is gitignored by default (suggest adding if not).
