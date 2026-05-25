#!/usr/bin/env bash

set -euo pipefail

# Bail out cleanly if not a git repo (don't pollute context with errors)
git rev-parse --git-dir > /dev/null 2>&1 || exit 0

BRANCH=$(git branch --show-current)
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "no upstream")

# Position vs upstream (ahead/behind)
AHEAD=""
BEHIND=""
if [[ "$UPSTREAM" != "no upstream" ]]; then
  AHEAD_BEHIND=$(git rev-list --left-right --count "${UPSTREAM}...HEAD" 2>/dev/null || echo "0	0")
  BEHIND=$(echo "$AHEAD_BEHIND" | cut -f1)
  AHEAD=$(echo "$AHEAD_BEHIND" | cut -f2)
fi

cat <<EOF
## Current development state

**Branch:** \`$BRANCH\` (upstream: \`$UPSTREAM\`${AHEAD:+, $AHEAD ahead}${BEHIND:+, $BEHIND behind})

### Modified files (git status)
\`\`\`
$(git status --short || echo "(clean)")
\`\`\`

### Recent commits
\`\`\`
$(git log --oneline -8)
\`\`\`

### Uncommitted diff — per-file summary
\`\`\`
$(git diff --stat HEAD)
\`\`\`

### Staged diff (ready to commit)
\`\`\`
$(git diff --cached --stat)
\`\`\`
EOF
