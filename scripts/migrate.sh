#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"

MIGRATIONS_DIR="/migrations"
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir) MIGRATIONS_DIR="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Create migrations tracking table if not exists
psql "$DATABASE_URL" -q <<'SQL'
CREATE TABLE IF NOT EXISTS _migrations (
    name TEXT PRIMARY KEY,
    applied_at TIMESTAMPTZ DEFAULT now()
);
SQL

# Find and apply pending migrations
APPLIED=0
for f in "$MIGRATIONS_DIR"/*.sql; do
    [[ -f "$f" ]] || continue
    NAME=$(basename "$f")
    ALREADY=$(psql "$DATABASE_URL" -t -A -c "SELECT COUNT(*) FROM _migrations WHERE name = '$NAME';")
    if [[ "$ALREADY" == "0" ]]; then
        echo "Applying: $NAME"
        psql "$DATABASE_URL" -q -f "$f"
        psql "$DATABASE_URL" -q -c "INSERT INTO _migrations (name) VALUES ('$NAME');"
        APPLIED=$((APPLIED + 1))
    fi
done

if [[ "$APPLIED" == "0" ]]; then
    echo "No pending migrations."
else
    echo "Applied $APPLIED migration(s)."
fi
