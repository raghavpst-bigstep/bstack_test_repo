---
name: bstack:migrate
description: 'Safe Kysely migration generator — reversibility, locking safety, and idempotency validation'
argument-hint: '[what to migrate — table, column, index, or description]'
model: opus
---

# /bstack:migrate

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.
>
> **Why this command exists:** Migrations are write-once and run against production data. A bad `down`, a locking `ALTER`, or a non-idempotent step turns a routine deploy into an outage. This command prevents that class of error.

## MCP usage

| MCP | When | What for |
|---|---|---|
| context7 | Kysely API patterns | `resolve-library-id` → `query-docs` for current migration API |

## Steps

1. **Classify** — fill this table for the migration:
   | Field | Value |
   |---|---|
   | What | table / column / index / constraint / data migration |
   | Why | feature / schema fix / perf / cleanup |
   | Breaking | yes / no (does it change existing columns/constraints?) |
   | Table size | small / large (drives locking strategy) |

2. **Generate file** — name `YYYYMMDDHHMMSS_<verb>_<noun>.ts` under `libs/db/src/lib/migrations/files/`. Export `up` and `down`. Use Kysely's typed schema builder.
3. **Rollback** — `down` must actually reverse `up`. If irreversible (e.g. dropping a column with data), say so explicitly and require explicit confirmation.
4. **Locking safety** — on large tables: NOT NULL adds use default + backfill (not a single statement); indexes use `CREATE INDEX CONCURRENTLY`. Otherwise the deploy locks the table.
5. **Idempotency** — `up` is safe to re-run if interrupted (`IF NOT EXISTS` and Kysely's safe variants where applicable).
6. **Static check** — run `bin/bstack-migrate-check <file>`. Resolve every FAIL before proceeding; treat WARNs as deliberate decisions to justify. This is the same checklist `kysely-migration-validator` runs in review — passing it here means no surprises later.
7. **Local apply + verify** — run the migration locally, check the resulting schema. Roll back, re-apply, verify idempotency.
8. **Test the data path** — `nx test libs/db` and any affected app's repo tests.
9. **Stage in PR** — note the locking strategy chosen for any large-table change.

## Hard rules

- Never modify an existing migration file — write a new one.
- If you can't write a sensible `down`, the migration needs review.
