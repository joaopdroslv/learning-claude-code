#!/usr/bin/env bash
#
# Project bootstrap: create `.venv` at the repo root using the Python version
# pinned in `.python-version` (via pyenv), then install `requirements.txt`.
# Safe to re-run.
#
# Requires: pyenv (or pyenv-win) on PATH.
#
# Usage:
#   ./scripts/bootstrap/setup-venv.sh

set -euo pipefail

# Jump to project root.
cd "$(dirname "$0")/../.."

VENV=".venv"
REQS="requirements.txt"
PIN_FILE=".python-version"

if ! command -v pyenv >/dev/null 2>&1; then
  echo "error: pyenv is required but not found on PATH." >&2
  echo "       Install pyenv (pyenv-win on Windows) and re-run." >&2
  exit 1
fi

if [[ ! -f "$PIN_FILE" ]]; then
  echo "error: $PIN_FILE not found at project root." >&2
  exit 1
fi

PIN_VERSION="$(tr -d '[:space:]' < "$PIN_FILE")"

if ! pyenv versions --bare | grep -qx "$PIN_VERSION"; then
  echo "error: Python $PIN_VERSION is not installed under pyenv." >&2
  echo "       Run: pyenv install $PIN_VERSION" >&2
  exit 1
fi

if [[ ! -d "$VENV" ]]; then
  echo "Creating virtual environment at $VENV (Python $PIN_VERSION via pyenv)..."
  pyenv exec python -m venv "$VENV"
fi

# venv's bin dir differs across platforms: Scripts on Windows, bin elsewhere.
if [[ -d "$VENV/Scripts" ]]; then
  VENV_BIN="$VENV/Scripts"
elif [[ -d "$VENV/bin" ]]; then
  VENV_BIN="$VENV/bin"
else
  echo "error: $VENV exists but has neither Scripts/ nor bin/ — looks broken." >&2
  exit 1
fi

# Use `python -m pip` rather than the `pip` entry-point so the upgrade works
# on Windows too (where pip cannot replace its own running .exe).
VENV_PY="$VENV_BIN/python"

echo "Upgrading pip..."
"$VENV_PY" -m pip install --upgrade pip

if [[ -s "$REQS" ]]; then
  echo "Installing $REQS..."
  "$VENV_PY" -m pip install -r "$REQS"
else
  echo "$REQS is empty — nothing to install."
fi

echo
echo "Done. Activate the venv with:"
echo "  source $VENV_BIN/activate"
