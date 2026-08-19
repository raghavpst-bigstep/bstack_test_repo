---
name: bstack:ship
description: 'Ship workflow — tests, VERSION bump, CHANGELOG, commit, push, PR'
argument-hint: '[optional: PR title hint]'
model: sonnet
---

# /bstack:ship

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.

End-to-end land flow: confirms tests are green, bumps version, writes CHANGELOG, pushes, opens PR.

## MCP usage

| MCP | When | What for |
|---|---|---|
| GitHub | Always | `create_pull_request`, `get_pull_request_status` for CI checks |
| Linear | Always | Link tickets in PR body; transition status to "In Review" |
| Slack | At PR opened | Post the PR link to the team channel |

## Steps

1. **Base branch sync** — detect base (`main` or `dev`), `git fetch`, merge or rebase onto base. Stop on conflicts.
2. **Diff review** — `git diff base...HEAD`. Sanity check: no debug logs, no secrets, no `.env` changes, no commented-out blocks.
3. **Tests** — run the affected projects' tests via `nx affected --target=test`. Block on failure.
4. **Lint** — `nx affected --target=lint`. Block on failure.
5. **VERSION bump** — read `VERSION`, increment patch (or minor / major if requested), write back.
6. **CHANGELOG** — prepend a new section with version + date + bullet list of user-visible changes (from commit messages).
7. **Commit** — message: `<type>: <one-line>`. Co-author footer per repo convention.
8. **Push** — `git push -u origin <branch>` if needed.
9. **PR** — title ≤ 70 chars. Body: Summary · Linear ticket · Test plan · Screenshots (if frontend) · Rollback plan (if risky). Use `gh pr create` with a HEREDOC body.
10. **Post-action** — Slack the PR link. Update Linear status. Watch first CI run.

## Hard rules

- Never `--no-verify`, `--force` to main, or amend a pushed commit (use a new commit instead).
- Never include unrelated files in the PR — if `git status` shows extras, ask before staging.
- If CI fails on first run, surface it — don't auto-retry silently.
