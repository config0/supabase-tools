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

# Check if tracking table exists
EXISTS=$(psql "$DATABASE_URL" -t -A -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = '_migrations';")
if [[ "$EXISTS" == "0" ]]; then
    echo "No migrations applied yet (tracking table does not exist)."
    echo ""
    echo "Pending:"
    for f in "$MIGRATIONS_DIR"/*.sql; do
        [[ -f "$f" ]] || continue
        echo "  $(basename "$f")"
    done
    exit 0
fi

echo "Applied:"
psql "$DATABASE_URL" -t -A -c "SELECT '  ' || name || ' (' || applied_at::date || ')' FROM _migrations ORDER BY name;"

echo ""
echo "Pending:"
PENDING=0
for f in "$MIGRATIONS_DIR"/*.sql; do
    [[ -f "$f" ]] || continue
    NAME=$(basename "$f")
    ALREADY=$(psql "$DATABASE_URL" -t -A -c "SELECT COUNT(*) FROM _migrations WHERE name = '$NAME';")
    if [[ "$ALREADY" == "0" ]]; then
        echo "  $NAME"
        PENDING=$((PENDING + 1))
    fi
done
[[ "$PENDING" == "0" ]] && echo "  (none)"
