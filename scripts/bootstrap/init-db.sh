#!/bin/bash
#
# Runs once on the MySQL container's first boot (via docker-entrypoint-initdb.d).
# Creates the read-only account used by `scripts/db-query.sh` and the
# `mysql-dev` subagent. The application user (MYSQL_USER/MYSQL_PASSWORD) is
# handled by the official image entrypoint.

set -euo pipefail

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE USER IF NOT EXISTS '${MYSQL_CLAUDE_USER}'@'%' IDENTIFIED BY '${MYSQL_CLAUDE_USER_PASSWORD}';
GRANT SELECT ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_CLAUDE_USER}'@'%';
FLUSH PRIVILEGES;
SQL
