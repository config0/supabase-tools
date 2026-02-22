#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"

if [[ "${1:-}" == "--file" ]]; then
    FILE="${2:?Usage: supabase-tools exec-file <file.sql>}"
    psql "$DATABASE_URL" -f "$FILE"
else
    SQL="${1:?Usage: supabase-tools exec <sql>}"
    psql "$DATABASE_URL" -c "$SQL"
fi
