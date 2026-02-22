#!/usr/bin/env bash
set -euo pipefail

: "${SUPABASE_URL:?SUPABASE_URL is required for rpc command}"
: "${SUPABASE_KEY:?SUPABASE_KEY is required for rpc command}"
: "${SCHEMA:=public}"

FUNCTION="${1:?Usage: supabase-tools rpc <function> [json_args]}"
ARGS="${2:-{}}"

curl -s -X POST \
    "${SUPABASE_URL}/rest/v1/rpc/${FUNCTION}" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Accept-Profile: ${SCHEMA}" \
    -H "Content-Profile: ${SCHEMA}" \
    -d "$ARGS" | jq .
