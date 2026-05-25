#!/usr/bin/env bash

set -euo pipefail

# Bail out cleanly if not a git repo
git rev-parse --git-dir > /dev/null 2>&1 || exit 0

BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
STATUS=$(git status --short)
DIFFSTAT=$(git diff --stat HEAD 2>/dev/null | tail -1)

# Skip injection entirely if repo is clean — nothing useful to add
if [[ -z "$STATUS" ]]; then
  exit 0
fi

cat <<EOF
<dev-state>
branch: $BRANCH
changes: ${DIFFSTAT:-none}
files:
$(echo "$STATUS" | head -15)
</dev-state>
EOF
