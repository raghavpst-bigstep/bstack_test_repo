// Eval fixture — expected: PASS (exit 0) from bstack-migrate-check
import { Kysely } from 'kysely';

export async function up(db: Kysely<any>): Promise<void> {
  await db.schema
    .createTable('widgets')
    .ifNotExists()
    .addColumn('id', 'serial', (c) => c.primaryKey())
    .addColumn('name', 'text', (c) => c.notNull().defaultTo(''))
    .execute();
}

export async function down(db: Kysely<any>): Promise<void> {
  await db.schema.dropTable('widgets').execute();
}
