// Eval fixture — expected: FAIL (exit 1) from bstack-migrate-check (no down(), bare NOT NULL)
import { Kysely } from 'kysely';

export async function up(db: Kysely<any>): Promise<void> {
  await db.schema
    .alterTable('widgets')
    .addColumn('owner_id', 'integer', (c) => c.notNull())
    .execute();
}
