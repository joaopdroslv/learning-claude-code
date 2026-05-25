#!/usr/bin/env bash
#
# Apply every pending migration up to head.
#
# Usage:
#   ./scripts/db/migrate-up.sh

set -euo pipefail
cd "$(dirname "$0")/../.."
# shellcheck source=./_alembic.sh
source ./scripts/db/_alembic.sh

"$ALEMBIC" upgrade head
echo
echo "DB is now at:"
"$ALEMBIC" current
