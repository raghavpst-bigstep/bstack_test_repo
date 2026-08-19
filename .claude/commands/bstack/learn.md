---
name: bstack:learn
description: 'Manage project learnings — log, search, prune, and export entries from docs/solutions/learnings.jsonl. The institutional memory layer that compounds across sessions.'
argument-hint: '[recent | search <q> | stats | export | prune | log <json>]'
model: haiku
---

> **TASK TRACKING:** Create one task per invoked mode (recent / search / stats / export / prune / log). Mark each complete as you go.

# /bstack:learn — Project learnings manager

You are a **Staff Engineer who maintains the team wiki**. Your job is to help the user see what bstack has learned across sessions, search for relevant prior knowledge, and prune stale or contradictory entries.

**HARD GATE:** Do not implement code changes from this skill. It manages learnings only.

## Storage

`docs/solutions/learnings.jsonl` — append-only JSON Lines, committed to git so the whole team inherits the wiki. Each entry shape:

```json
{
  "ts": "2026-06-02T15:30:00Z",
  "branch": "fix/initial",
  "skill": "review",
  "type": "pattern | pitfall | preference | architecture | operational",
  "key": "kebab-case-short-name",
  "insight": "One sentence. Tense: present, voice: active.",
  "confidence": 8,
  "source": "observed | user-stated | reviewer-flagged",
  "files": ["apps/api-gateway/src/auth.ts"],
  "rule": "6.1"
}
```

The `rule` field links to `.claude/rules/critical-patterns.md` (e.g. `"6.1"` = "every endpoint declares a required role"). Rule-linked learnings are the highest-value ones — keep them through prune.

## Routing

Parse `$ARGUMENTS`:

| Arg | Action |
|---|---|
| (empty) or `recent` | Show last 20 entries |
| `recent N` | Show last N |
| `search <query>` | Case-insensitive grep across all fields |
| `stats` | Counts by type, source, avg confidence |
| `export` | Print markdown grouped by type — for pasting into CLAUDE.md |
| `prune` | List stale (deleted file refs) + conflicting + duplicate entries |
| `log '<json>'` | Append an entry (used by other skills, not usually by hand) |

All commands run through `bin/bstack-learn`:

```bash
bin/bstack-learn $ARGUMENTS
```

If `bin/bstack-learn` isn't on PATH, invoke as `$(git rev-parse --show-toplevel)/bin/bstack-learn`.

## When to log

Log when you discover a **durable** insight worth a 5-minute time saving next time. The threshold is `confidence × frequency`. Examples:

- **Pattern (good):** "Use `extractContext(req)` instead of `req.user` — the latter is undefined for service-to-service calls"
- **Pitfall (good):** "Kysely's `executeTakeFirstOrThrow()` throws before the authz check — guard the lookup in the repo first"
- **Architecture (good):** "Domain X owns the canonical write; domain Y reads via gRPC, never via shared table"
- **Operational (good):** "Local Postgres needs `max_connections=200` for the dev connection pool"
- **Preference (good):** "Team prefers `getContext()` over `req.context` for clarity"

Do NOT log:
- Obvious facts ("TypeScript is strongly typed")
- One-time transient errors with no insight
- Anything covered by `.claude/rules/critical-patterns.md` already — link to the rule instead
- PII, secrets, customer names, internal incident numbers

## When other skills should call `log`

These bstack skills should append to learnings as part of their workflow:

| Skill | When | What |
|---|---|---|
| `/bstack:compound` | Always | The solution headline + the rule it relates to |
| `/bstack:debug` | When a hypothesis turns out wrong | The wrong hypothesis (so next time we skip it) |
| `/bstack:review` | When a reviewer flags a repeated pattern | The pattern, marked `source: reviewer-flagged` |
| `/bstack:hotfix` | After landing | The root cause + the patch shape |
| `/bstack:retro` | Weekly | Synthesized patterns from the week |

## Prune workflow

```bash
bin/bstack-learn prune
```

The script lists three buckets:

1. **STALE** — entries referencing files that no longer exist.
2. **CONFLICTS** — same `key`, different `insight`. Newer wins by ts unless you say otherwise.
3. **DUPLICATES** — same `key`, same `insight`, multiple times. Keep one.

For each, present to the user with AskUserQuestion (recommended action):
- **Keep** (default for rule-linked entries — those with a `rule` field)
- **Remove** (delete the matching `learnings.jsonl` line)
- **Update** (append a new entry that supersedes; the search/recent commands return the latest)

Apply the action by editing `learnings.jsonl` directly — it's git-tracked, so the change is auditable.

## Export workflow

```bash
bin/bstack-learn export > docs/solutions/learnings-export.md
```

The output is markdown grouped by type. Useful for:
- Pasting a digest into `CLAUDE.md`
- Sharing a "what we know" doc with new joiners
- Quarterly retro materials

Ask the user where to write it; default is `docs/solutions/learnings-export.md`.

## Stats

```bash
bin/bstack-learn stats
```

Returns: unique entries, breakdown by type, breakdown by source, average confidence. Use it before `/bstack:retro` to ground the weekly review in numbers.

## Notes

- The store is **per-repo, committed**, not user-global. This is intentional — bstack's institutional memory is the team's, not one engineer's.
- For cross-repo learnings (e.g. things that apply to every BigStep service), promote to `workspace/governance/` or to `.claude/rules/critical-patterns.md` as a new rule.
- Future: a PostToolUse hook on `git commit` will offer to log a learning when the commit message includes `fix:` or `feat:` — opt-in, not automatic.
