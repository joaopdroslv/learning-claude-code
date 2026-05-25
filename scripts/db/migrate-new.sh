#!/usr/bin/env bash
#
# Generate a new Alembic migration via autogenerate.
#
# Safety: refuses to run if the DB is not at the head revision. Running
# autogenerate against a stale DB diffs your models against an out-of-date
# schema and produces a migration that duplicates work already in pending
# migrations.
#
# Usage:
#   ./scripts/db/migrate-new.sh "<short_snake_case_message>"

set -euo pipefail
cd "$(dirname "$0")/../.."
# shellcheck source=./_alembic.sh
source ./scripts/db/_alembic.sh

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 \"<migration message>\"" >&2
  exit 2
fi

# Extract revision hashes from alembic output. The hashes are lowercase
# hex; they're the first token on their own line.
current_rev=$("$ALEMBIC" current 2>/dev/null | grep -oE '^[a-f0-9]{8,}' | tail -1 || true)
head_rev=$("$ALEMBIC" heads 2>/dev/null | grep -oE '^[a-f0-9]{8,}' | tail -1 || true)

if [[ -z "$head_rev" ]]; then
  # No migrations in the codebase yet — this would be the first one. Fine.
  :
elif [[ "$current_rev" != "$head_rev" ]]; then
  echo "error: DB is not at the head migration." >&2
  echo "  current: ${current_rev:-<none, DB has no version>}" >&2
  echo "  head:    $head_rev" >&2
  echo >&2
  echo "  Apply pending migrations first:" >&2
  echo "    ./scripts/db/migrate-up.sh" >&2
  echo "  Then retry this command." >&2
  exit 1
fi

"$ALEMBIC" revision --autogenerate -m "$1"
