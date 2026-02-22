#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"
: "${SCHEMA:=public}"

echo "Functions in schema '$SCHEMA':"
echo ""

psql "$DATABASE_URL" -t -A <<SQL
SELECT
    p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')' AS signature,
    CASE p.prokind WHEN 'f' THEN 'function' WHEN 'p' THEN 'procedure' ELSE 'other' END AS kind
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = '$SCHEMA'
ORDER BY p.proname;
SQL
