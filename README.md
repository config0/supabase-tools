# supabase-tools

Portable Supabase database management CLI tool — packaged as a Docker image based on `postgres:16-alpine`. Run common database management tasks (table inspection, schema management, migrations, function listing, raw SQL execution, and RPC calls) against any Supabase or plain Postgres database without installing any local dependencies.

## Quick Start

```bash
# List tables in the public schema
docker run --rm \
  -e DATABASE_URL="postgresql://user:pass@host:5432/dbname" \
  config0/supabase-tools tables

# List tables in a specific schema
docker run --rm \
  -e DATABASE_URL="postgresql://user:pass@host:5432/dbname" \
  config0/supabase-tools tables --schema myschema

# Apply migrations from a local directory
docker run --rm \
  -e DATABASE_URL="postgresql://user:pass@host:5432/dbname" \
  -v /path/to/migrations:/migrations:ro \
  config0/supabase-tools migrate
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes (most commands) | Direct Postgres connection string, e.g. `postgresql://user:pass@host:5432/db` |
| `SUPABASE_URL` | Yes (rpc command) | Supabase project URL, e.g. `https://xyz.supabase.co` |
| `SUPABASE_KEY` | Yes (rpc command) | Supabase `service_role` key |
| `SCHEMA` | No | Default schema (default: `public`) |

## Commands

### `tables [-s schema]`

List all tables in the schema with approximate row counts.

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools tables

docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools tables --schema qhost
```

### `schemas`

List all user-created schemas (excludes `pg_*` and `information_schema`).

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools schemas
```

### `schema-create <name>`

Create a new schema.

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools schema-create myschema
```

### `schema-drop <name>`

Drop a schema and all its objects. Prompts for confirmation by requiring you to type the schema name.

```bash
docker run --rm -it \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools schema-drop myschema
```

### `schema-dump [-s schema]`

Dump the DDL (table definitions, indexes, constraints, functions) for a schema to stdout.

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools schema-dump > schema.sql

docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools schema-dump --schema qhost > qhost-schema.sql
```

### `functions [-s schema]`

List all functions and procedures in the schema.

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools functions

docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools functions --schema myschema
```

### `migrate [-d migrations_dir]`

Apply pending `.sql` migration files from the migrations directory. Tracks applied migrations in a `_migrations` table. Files are applied in alphabetical order; only files not yet recorded in `_migrations` are applied.

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  -v /path/to/migrations:/migrations:ro \
  config0/supabase-tools migrate

# Custom migrations directory inside container
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  -v /path/to/migrations:/sql:ro \
  config0/supabase-tools migrate --dir /sql
```

### `migrations [-d migrations_dir]`

Show the status of applied vs. pending migrations without applying them.

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  -v /path/to/migrations:/migrations:ro \
  config0/supabase-tools migrations
```

### `exec <sql>`

Run an arbitrary SQL statement.

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools exec "SELECT version();"

docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  config0/supabase-tools exec "INSERT INTO mytable (col) VALUES ('val');"
```

### `exec-file <file.sql>`

Run SQL from a file mounted into the container.

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  -v /path/to/script.sql:/script.sql:ro \
  config0/supabase-tools exec-file /script.sql
```

### `rpc <function> [json_args]`

Call a Supabase PostgREST RPC function and return JSON output. Requires `SUPABASE_URL` and `SUPABASE_KEY`.

```bash
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  -e SUPABASE_URL="https://xyz.supabase.co" \
  -e SUPABASE_KEY="eyJ..." \
  config0/supabase-tools rpc my_function '{"param1": "value1"}'

# No arguments
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  -e SUPABASE_URL="https://xyz.supabase.co" \
  -e SUPABASE_KEY="eyJ..." \
  config0/supabase-tools rpc get_stats
```

## Global Options

| Option | Description |
|--------|-------------|
| `-s, --schema <name>` | Target schema (default: `public`) |
| `-d, --dir <path>` | Migrations directory (default: `/migrations`) |
| `--help` | Show help message |
| `--version` | Show version |

## Docker Image Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest build from `main` branch |
| `main` | Latest build from `main` branch |
| `vX.Y.Z` | Specific release version |
| `vX.Y` | Latest patch for a minor version |
| `sha-XXXXXXX` | Specific commit SHA |

## Building Locally

```bash
git clone https://github.com/config0/supabase-tools.git
cd supabase-tools
docker build -t supabase-tools .
docker run --rm supabase-tools --help
```

## Using with Supabase (Neon Direct URL)

Supabase projects use Neon as the underlying Postgres provider. Use the **direct connection URL** (not the pooler URL) for DDL operations like migrations and schema dumps:

```bash
# From Supabase dashboard: Settings > Database > Connection string > Direct connection
DATABASE_URL="postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres"

docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  -v ./supabase/migrations:/migrations:ro \
  config0/supabase-tools migrate
```

## License

MIT
