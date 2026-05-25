# ADD_PYTHON_VENV_BOOTSTRAP

**ID:** ADR-004
**Timestamp:** 2026-05-25 12:35
**Status:** Accepted
**Type:** feature

## Context
The repo has started growing Python code under `app/` (with `app/__init__.py` and `app/models/`). Until now there was no documented way to set up the Python environment locally — a new contributor (or CI in the future) would have to guess the interpreter version, pick a venv tool, and decide where to put it. We want one obvious "do this after cloning" command, and we want the Python version itself to be pinned rather than implicit.

## Decision
- **`pyenv` is the required Python version manager** (pyenv-win on Windows). The bootstrap script refuses to run without it.
- **`.python-version`** at the repo root pins the interpreter version (currently `3.13.3`). pyenv reads it automatically; the bootstrap script also reads it directly to verify the version is installed before continuing.
- **`scripts/bootstrap/setup-venv.sh`** verifies pyenv is on `PATH`, confirms the pinned version is installed (suggests `pyenv install <version>` otherwise), creates `.venv/` via `pyenv exec python -m venv`, upgrades pip, then installs `requirements.txt` if it has any content. Idempotent.
- **`requirements.txt`** is committed at the repo root, initially empty. As `pip`-resolvable dependencies are added, they go here.
- **`.venv/` is gitignored** alongside `__pycache__/` and `*.py[cod]`.
- The script handles both `.venv/Scripts/` (Windows) and `.venv/bin/` (POSIX) so it works across the Windows-primary dev host and any future Linux CI.

## Alternatives considered
- **Poetry / pdm / uv**: nicer ergonomics (lockfiles, dependency groups) but heavier and more opinionated. None of those are justified yet — the project has zero dependencies. When the dep list grows enough to want lockfile-driven installs, this ADR can be superseded.
- **Let any Python on `PATH` work**: simpler, but two contributors on different host Pythons would diverge silently. Pinning via `.python-version`+pyenv makes the version explicit and reproducible.
- **`asdf` instead of pyenv**: broader tool coverage but extra setup cost, and the primary developer already uses pyenv.
- **A `Makefile` target (`make bootstrap`)**: discoverable on Unix but not on the Windows primary dev host without WSL or `make` installed. Rejected for portability.
- **Putting the script under a new `scripts/setup/`**: would split first-run setup across two directories. `scripts/bootstrap/` already holds `init-db.sh` (MySQL first-boot init), so co-locating "first-time setup" scripts there keeps the concept in one place.

## Consequences
**Positive:**
- One command to a working environment: `./scripts/bootstrap/setup-venv.sh`.
- Python version is pinned in-repo via `.python-version` — same interpreter for everyone.
- `requirements.txt` is a familiar contract — any tool that reads pip requirements just works.
- Clear, actionable error messages when pyenv or the pinned version is missing.

**Negative:**
- pyenv (or pyenv-win) is a hard prerequisite. No fallback to system Python.
- No lockfile. Two contributors running this on different days may end up with different transitive dependency versions. Acceptable while the project is small; revisit when reproducibility starts to matter.
- `requirements.txt` does not split runtime vs dev dependencies. If/when that matters, a second file (`requirements-dev.txt`) or migration to a dependency manager will be needed.
- Bumping the Python version means editing `.python-version` and re-creating `.venv/` (the bootstrap script does not auto-detect a stale venv tied to a previous version).
