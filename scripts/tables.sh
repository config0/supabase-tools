#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"
: "${SCHEMA:=public}"

echo "Tables in schema '$SCHEMA':"
echo ""

psql "$DATABASE_URL" -t -A -F '|' <<SQL
SELECT
    tablename,
    pg_stat_get_live_tuples(c.oid) AS row_count
FROM pg_tables t
JOIN pg_class c ON c.relname = t.tablename
JOIN pg_namespace n ON n.oid = c.relnamespace AND n.nspname = t.schemaname
WHERE t.schemaname = '$SCHEMA'
ORDER BY tablename;
SQL
