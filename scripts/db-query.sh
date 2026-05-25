#!/usr/bin/env bash
#
# Run a read-only query against the dev MySQL.
#
# Loads credentials from the project-root `.env` (gitignored). The connection
# is restricted to the `MYSQL_READONLY_USER` account, so INSERT/UPDATE/DELETE
# and DDL all fail at the DB.
#
# Usage:
#   ./scripts/db-query.sh "SELECT ... LIMIT 50"
#   ./scripts/db-query.sh <<'SQL'
#     SELECT ...
#   SQL

set -euo pipefail

# Jump to project root regardless of where the script was invoked from,
# so `docker compose` finds the right compose file and `.env` is at CWD.
cd "$(dirname "$0")/.."

ENV_FILE=".env"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
else
  echo "error: $ENV_FILE not found at project root. Copy .env.example to .env." >&2
  exit 1
fi

COMPOSE_FILE="${COMPOSE_FILE:-docker/docker-compose.dev.yml}"
SERVICE="${MYSQL_SERVICE:-mysql}"
DB="${MYSQL_DATABASE:?MYSQL_DATABASE not set in .env}"
USER="${MYSQL_CLAUDE_USER:?MYSQL_CLAUDE_USER not set in .env}"
PASS="${MYSQL_CLAUDE_USER_PASSWORD:?MYSQL_CLAUDE_USER_PASSWORD not set in .env}"

if [[ $# -gt 0 ]]; then
  QUERY="$*"
else
  QUERY="$(cat)"
fi

if [[ "${DEVCONTAINER:-}" == "true" ]]; then
  # Inside the dev container — talk to MySQL directly over the docker network
  # using the `mysql` compose-service hostname. No docker socket required.
  mysql -h "$SERVICE" -u "$USER" -p"$PASS" "$DB" \
    --table \
    -e "$QUERY"
else
  # On the host — go through `docker compose exec` so we don't need a mysql
  # client installed locally.
  docker compose \
    --env-file "$ENV_FILE" \
    -f "$COMPOSE_FILE" \
    exec -T "$SERVICE" \
    mysql -u "$USER" -p"$PASS" "$DB" \
    --table \
    -e "$QUERY"
fi
