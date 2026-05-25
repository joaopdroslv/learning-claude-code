#!/usr/bin/env bash
#
# Show where the DB sits relative to the migration history.
#
# Usage:
#   ./scripts/db/migrate-status.sh

set -euo pipefail
cd "$(dirname "$0")/../.."
# shellcheck source=./_alembic.sh
source ./scripts/db/_alembic.sh

echo "== Current DB revision =="
"$ALEMBIC" current
echo
echo "== Head revision (latest in code) =="
"$ALEMBIC" heads
echo
echo "== History =="
"$ALEMBIC" history
