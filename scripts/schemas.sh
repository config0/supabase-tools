#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"

ACTION="${1:-list}"

case "$ACTION" in
    list)
        echo "Schemas:"
        psql "$DATABASE_URL" -t -A -c \
            "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT LIKE 'pg_%' AND schema_name != 'information_schema' ORDER BY schema_name;"
        ;;
    create)
        NAME="${2:?Usage: supabase-tools schema-create <name>}"
        psql "$DATABASE_URL" -c "CREATE SCHEMA IF NOT EXISTS \"$NAME\";"
        echo "Schema '$NAME' created."
        ;;
    drop)
        NAME="${2:?Usage: supabase-tools schema-drop <name>}"
        echo "WARNING: This will drop schema '$NAME' and ALL its objects."
        read -rp "Type the schema name to confirm: " CONFIRM
        if [[ "$CONFIRM" == "$NAME" ]]; then
            psql "$DATABASE_URL" -c "DROP SCHEMA \"$NAME\" CASCADE;"
            echo "Schema '$NAME' dropped."
        else
            echo "Aborted."
            exit 1
        fi
        ;;
    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac
