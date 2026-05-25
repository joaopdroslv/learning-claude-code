#!/bin/bash
#
# Reset ownership of Docker named volumes mounted under /workspace so the
# non-root `node` user can write to them.
#
# Why: Docker creates named volumes owned by root:root, regardless of the
# USER directive in the image. When such a volume is overlaid on a path the
# container runs into as `node` (uid 1000) — e.g. `venv-data` at
# `/workspace/.venv` — the user cannot write into it and bootstrap workflows
# like `python -m venv` fail with `Permission denied`.
#
# This script runs as root via NOPASSWD sudo from `postStartCommand`, before
# any user-level setup. It is idempotent: it only chowns when the root of a
# volume is owned by someone other than `node`, so re-runs on every container
# start are cheap.

set -euo pipefail

# Each entry: a path that may be a named-volume mount point we want owned by
# node. Extend this list as new named volumes are added to docker-compose.yml.
VOLUMES=(
  "/workspace/.venv"
)

for path in "${VOLUMES[@]}"; do
  if [ ! -d "$path" ]; then
    continue
  fi
  current_owner="$(stat -c '%U' "$path")"
  if [ "$current_owner" != "node" ]; then
    echo "Fixing ownership of $path (was owned by $current_owner)..."
    chown -R node:node "$path"
  fi
done
