#!/usr/bin/env bash
set -euo pipefail

VERSION="0.1.0"
SCRIPTS_DIR="/usr/local/lib/supabase-tools"
SCHEMA="${SCHEMA:-public}"

usage() {
    cat <<'USAGE'
Usage: supabase-tools <command> [options]

Environment variables (required):
  DATABASE_URL     Direct Postgres connection string

Environment variables (optional, for PostgREST commands):
  SUPABASE_URL     Supabase project URL
  SUPABASE_KEY     Supabase service_role key

Commands:
  tables    [-s schema]              List tables with row counts
  schemas                            List all schemas
  schema-create <name>               Create a new schema
  schema-drop <name>                 Drop a schema (with confirmation)
  schema-dump [-s schema]            Dump schema DDL to stdout
  functions [-s schema]              List database functions
  migrate   [-d migrations_dir]      Apply pending .sql migration files
  migrations [-d migrations_dir]     Show applied vs pending migrations
  exec      <sql>                    Run arbitrary SQL statement
  exec-file <file.sql>               Run SQL from a file
  rpc       <function> [json_args]   Call RPC function via PostgREST

Options:
  -s, --schema <name>    Target schema (default: public)
  -d, --dir <path>       Migrations directory (default: /migrations)
  --help                 Show this help
  --version              Show version
USAGE
}

# Parse global options that can appear anywhere
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--schema) SCHEMA="$2"; shift 2 ;;
        --help) usage; exit 0 ;;
        --version) echo "supabase-tools $VERSION"; exit 0 ;;
        *) POSITIONAL+=("$1"); shift ;;
    esac
done
set -- "${POSITIONAL[@]}"

COMMAND="${1:-}"
shift || true

if [[ -z "$COMMAND" ]]; then
    usage
    exit 0
fi

export SCHEMA

case "$COMMAND" in
    tables)        exec "$SCRIPTS_DIR/tables.sh" "$@" ;;
    schemas)       exec "$SCRIPTS_DIR/schemas.sh" "$@" ;;
    schema-create) exec "$SCRIPTS_DIR/schemas.sh" create "$@" ;;
    schema-drop)   exec "$SCRIPTS_DIR/schemas.sh" drop "$@" ;;
    schema-dump)   exec "$SCRIPTS_DIR/schema-dump.sh" "$@" ;;
    functions)     exec "$SCRIPTS_DIR/functions.sh" "$@" ;;
    migrate)       exec "$SCRIPTS_DIR/migrate.sh" "$@" ;;
    migrations)    exec "$SCRIPTS_DIR/migrations.sh" "$@" ;;
    exec)          exec "$SCRIPTS_DIR/exec.sh" "$@" ;;
    exec-file)     exec "$SCRIPTS_DIR/exec.sh" --file "$@" ;;
    rpc)           exec "$SCRIPTS_DIR/rpc.sh" "$@" ;;
    *)             echo "Unknown command: $COMMAND"; usage; exit 1 ;;
esac
