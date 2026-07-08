# Project Overview

## What this is

`learning-claude-code` is a playground for codifying solid patterns for working with
[Claude Code](https://claude.com/claude-code) — custom slash commands, subagents, hooks,
settings, and disciplined documentation conventions — on top of a small Python + MySQL
stack that exists to give those patterns something real to operate on.

The product is the *conventions*, not the application. The application is deliberately
minimal: just enough schema and tooling to exercise migrations, database inspection, and
the documentation workflow.

## Stack

- **Python 3.13.3** — pinned via `.python-version`, installed by pyenv inside the dev container.
- **SQLAlchemy 2.0 + Alembic** — ORM and migrations (`app/`, `migrations/`).
- **MySQL 8.0** — runs in Docker as the development database (`docker/`).
- **Dev Container** — vendored from Anthropic's reference setup, with a firewall allowlist
  and a named-volume ownership bootstrap (`.devcontainer/`).

## How it fits together

- `app/db.py` builds the SQLAlchemy URL from `MYSQL_*` environment variables (see `.env.example`).
- ORM models live under `app/features/<feature>/models/` (one per file); `app/core/metadata.py`
  imports them so Alembic autogenerates migrations into `migrations/versions/`.
- `scripts/bootstrap/` holds one-shot setup (`setup-venv.sh`, `init-db.sh`);
  `scripts/db/` wraps the Alembic up/down/new/status workflow; `scripts/db-query.sh`
  runs read-only queries for the `mysql-dev` subagent.

## Getting started

The expected workflow is to open the repo inside the Dev Container (VS Code → *Reopen in
Container*), then:

```bash
# Create .venv and install requirements.txt
./scripts/bootstrap/setup-venv.sh
source .venv/bin/activate

# Start the dev MySQL service
./scripts/bootstrap/init-db.sh

# Apply migrations
./scripts/db/migrate-up.sh
```

The root [`README.md`](../../README.md) carries the full getting-started walkthrough and the
database workflow commands.

## Documentation map

- **[`layout.md`](./layout.md)** — full repository structure and what lives where.
- **[`../standards/`](../standards/README.md)** — the rules to follow when editing the project.
- **[`../decisions/`](../decisions/README.md)** — numbered ADRs recording every change and its rationale.
