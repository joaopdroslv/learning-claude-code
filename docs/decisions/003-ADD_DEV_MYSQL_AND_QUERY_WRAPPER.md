# ADD_DEV_MYSQL_AND_QUERY_WRAPPER

**ID:** ADR-003
**Timestamp:** 2026-05-25 11:00
**Status:** Accepted
**Type:** feature

## Context
The repo had scaffold files (`docker/docker-compose.dev.yml`, `scripts/dev/db-query.sh`, `scripts/bootstrap/init-db.sql`, `.env`, `.env.example`) but every one of them was empty. The `mysql-dev` subagent (`.claude/agents/mysql-dev.md`) was already wired to call `./scripts/db-query.sh`, but no such script existed at that path and no MySQL container was actually defined. The agent could not run.

We need a local MySQL the developer (and the subagent) can query, with credentials kept out of git and a read-only path for the agent so it cannot mutate state.

## Decision
- **MySQL 8.0 via `docker/docker-compose.dev.yml`**, configured entirely from project-root `.env`. The compose file mounts `scripts/bootstrap/init-db.sh` into `/docker-entrypoint-initdb.d/`, which runs on the container's first boot.
- **Two database accounts**:
  - Application user (`MYSQL_DEFAULT_USER`) — full privileges on `MYSQL_DATABASE`, created by the official MySQL image entrypoint.
  - Read-only user (`MYSQL_CLAUDE_USER`) — `SELECT`-only on `MYSQL_DATABASE`, created by `init-db.sh`. This is the account the wrapper uses.
- **`scripts/db-query.sh`** is the single entry point for ad-hoc queries. It sources `.env` from the project root, then `docker compose -f docker/docker-compose.dev.yml exec`s a `mysql` client as the read-only user. The `mysql-dev` subagent uses it via the existing `Bash(./scripts/db-query.sh:*)` permission in `.claude/settings.json`.
- **`.env` is gitignored, `.env.example` is committed** as the template. A new `.gitignore` covers both, plus `.claude/settings.local.json` and common editor noise.
- The previous `scripts/dev/` location for the wrapper was dropped — the subagent and `settings.json` both reference `./scripts/db-query.sh`, so the wrapper now lives at the top level of `scripts/`.

## Alternatives considered
- **Hardcode dev credentials in `init-db.sql` and ignore `.env` in the script**: simpler but splits the source of truth. A password change would need edits in two files, and `db-query.sh` could silently drift from the actual DB. Rejected.
- **A native MySQL install instead of Docker**: lower indirection but worse cross-platform reproducibility (Windows is the primary host here). Rejected.
- **Grant the read-only user `SELECT` on `*.*` (including `mysql`, `information_schema`, etc.)**: gives the agent more room to introspect server-level metadata, but also lets it read across databases unrelated to the project. Chose to scope it to `MYSQL_DATABASE`.
- **Let the subagent call `mysql`/`docker compose exec` directly**: drops a layer of indirection but spreads credentials across the prompt and complicates the `settings.json` allow-list. Rejected — the wrapper is the choke point.

## Consequences
**Positive:**
- The `mysql-dev` subagent is actually runnable: one script, one allow-listed Bash pattern, credentials sourced from `.env`.
- Credentials live in exactly one place (`.env`). `.env.example` documents the schema for new contributors.
- The read-only account is enforced at the database layer, not the prompt — even a misbehaving query cannot mutate data.

**Negative:**
- `init-db.sh` only runs on first boot of a fresh volume. If credentials change in `.env` after the volume is initialized, the readonly user inside MySQL stays on the old password until the volume is recreated (`docker compose -f docker/docker-compose.dev.yml down -v`).
- The wrapper requires Docker Desktop running. There is no fallback to a host-local `mysql` client.
- Anyone with read access to the working tree can read `.env`. This is acceptable for dev creds but the same file shape must not be reused for staging/prod without revisiting.
