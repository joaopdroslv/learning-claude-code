# learning-claude-code

A playground for codifying solid patterns for working with [Claude Code](https://claude.com/claude-code) — custom slash commands, subagents, hooks, settings, and disciplined documentation conventions — on top of a small Python + MySQL stack that exists to give those patterns something real to operate on.

## Stack

- **Python 3.13.3** (pinned via `.python-version`, installed by pyenv inside the dev container).
- **SQLAlchemy 2.0 + Alembic** for ORM and migrations (`app/`, `migrations/`).
- **MySQL 8.0** in Docker as the development database.
- **Dev Container** vendored from Anthropic's reference setup, with a firewall allowlist and named-volume bootstrap.

## Repository layout

| Path | What lives here |
|------|-----------------|
| `CLAUDE.md` | Project guidelines (thin index, auto-loaded into every Claude Code conversation). |
| `README.md` | This file. Human-facing overview. |
| `SETUP.md` | Bootstrap doc — replicate the documentation conventions in a fresh repo. |
| `app/` | Application code (`db.py`, ORM models under `models/`). |
| `migrations/` | Alembic environment and version scripts. |
| `alembic.ini` | Alembic configuration. |
| `requirements.txt` | Python dependencies. |
| `docker/` | Compose files for the dev MySQL service. |
| `scripts/bootstrap/` | One-shot setup scripts (`setup-venv.sh`, `init-db.sh`). |
| `scripts/db/` | Migration wrappers (`migrate-up.sh`, `migrate-down.sh`, `migrate-new.sh`, `migrate-status.sh`). |
| `scripts/db-query.sh` | Read-only MySQL query wrapper used by the `mysql-dev` subagent. |
| `.devcontainer/` | Dev Container definition, firewall init, named-volume init. |
| `docs/standards/` | Project rule-sets, `@`-imported by `CLAUDE.md`. |
| `docs/decisions/` | Decision records (ADRs), one Markdown file per change. |
| `.claude/commands/` | Custom slash commands (`/log-decision`, `/migrate-new`). |
| `.claude/agents/` | Custom Claude Code subagents (`mysql-dev`). |
| `.claude/settings.json` | Shared Claude Code settings (committed). |
| `.claude/settings.local.json` | Personal overrides (gitignored). |

## Getting started

The expected workflow is to open the repo inside the Dev Container (VS Code → *Reopen in Container*). The container brings Python 3.13.3, the MySQL client, and the firewall allowlist; named volumes (`.venv`) are chowned to `node` by `init-volumes.sh` before any user-level script runs.

Once the container is up:

```bash
# Create .venv and install requirements.txt
./scripts/bootstrap/setup-venv.sh
source .venv/bin/activate

# Start the dev MySQL service (docker compose under docker/)
./scripts/bootstrap/init-db.sh

# Apply migrations
./scripts/db/migrate-up.sh
```

Database connection settings come from `.env` (see `.env.example`). `app/db.py` builds the SQLAlchemy URL from `MYSQL_*` variables.

## Working with the database

- **Inspect**: the `mysql-dev` subagent (`.claude/agents/mysql-dev.md`) runs read-only queries through `scripts/db-query.sh`. Ask Claude things like "does the customers table exist?".
- **New migration**: run `/migrate-new` (or `./scripts/db/migrate-new.sh "<message>"`) — autogenerates from the current model diff after an at-head safety check.
- **Apply / roll back / status**: `./scripts/db/migrate-up.sh`, `./scripts/db/migrate-down.sh`, `./scripts/db/migrate-status.sh`.

## How changes are tracked

Every change — feature, fix, refactor, or documentation update — is logged as a numbered decision record (ADR) under `docs/decisions/`. ADRs carry the full rationale (context, decision, alternatives, consequences); the [decisions index](./docs/decisions/README.md) doubles as a scannable change history (date, status, one-line summary).

Use `/log-decision <FEATURE_NAME> "<summary>" [type]` to scaffold a new ADR and update the index in one step. ADRs are numbered sequentially (`001`, `002`, ...) and referenced in prose as `ADR-NNN`.

## Conventions in one sentence

All code, comments, and documentation are written in English; every change is captured as a numbered ADR under `docs/decisions/`.

For the full rule-set see [`CLAUDE.md`](./CLAUDE.md), which `@`-imports each standard from [`docs/standards/`](./docs/standards/README.md).
