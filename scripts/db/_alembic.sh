# Shared helpers for the migrate-*.sh wrappers.
# Sourced, not executed. Sets:
#   ALEMBIC — path to the venv's alembic binary (Windows/Scripts or POSIX/bin)
# Exits with a clear error if the venv hasn't been bootstrapped yet.

if [[ -x ".venv/Scripts/alembic" ]]; then
  ALEMBIC=".venv/Scripts/alembic"
elif [[ -x ".venv/bin/alembic" ]]; then
  ALEMBIC=".venv/bin/alembic"
else
  echo "error: alembic not found in .venv/." >&2
  echo "       Run ./scripts/bootstrap/setup-venv.sh first." >&2
  exit 1
fi
