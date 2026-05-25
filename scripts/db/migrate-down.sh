#!/usr/bin/env bash
#
# Undo the most recently applied migration. Asks for confirmation first.
#
# Usage:
#   ./scripts/db/migrate-down.sh

set -euo pipefail
cd "$(dirname "$0")/../.."
# shellcheck source=./_alembic.sh
source ./scripts/db/_alembic.sh

echo "== Current DB revision =="
"$ALEMBIC" current
echo
read -r -p "Downgrade by one revision? [y/N] " reply
if [[ ! "$reply" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

"$ALEMBIC" downgrade -1
echo
echo "DB is now at:"
"$ALEMBIC" current
