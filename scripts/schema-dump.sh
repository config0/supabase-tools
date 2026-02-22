#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"
: "${SCHEMA:=public}"

pg_dump "$DATABASE_URL" --schema-only --schema="$SCHEMA" --no-owner --no-privileges
