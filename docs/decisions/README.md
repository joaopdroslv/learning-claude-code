# Decision Records

Long-form rationale for every change in this project. Format details in [`../standards/decision-records.md`](../standards/decision-records.md).

To scaffold a new record (and its index row) run:

```
/log-decision <FEATURE_NAME> "<summary>" [type]
```

## Index

| ADR | Status | Date | Summary |
|-----|--------|------|---------|
| [ADR-008](./008-FIX_NAMED_VOLUME_OWNERSHIP.md) | Accepted | 2026-05-25 16:15 | `init-volumes.sh` (NOPASSWD sudo) chained before `init-firewall.sh` in `postStartCommand`; chowns named volumes (currently `.venv`) to `node` so non-root `setup-venv.sh` can write. Plus empty-dir handling in `setup-venv.sh`. |
| [ADR-007](./007-ADD_ALEMBIC_WORKFLOW_SCRIPTS.md) | Accepted | 2026-05-25 15:40 | `scripts/db/migrate-*.sh` wrappers (at-head safety on new migrations) + `/migrate-new` slash command + settings allowlist. |
| [ADR-006](./006-ADOPT_SQLALCHEMY_AND_ALEMBIC.md) | Accepted | 2026-05-25 15:25 | SQLAlchemy 2.0 + Alembic + PyMySQL; `app/db.py`, `app/models/customer.py`, env-driven `DATABASE_URL`; first migration `create_customers`. |
| [ADR-005](./005-ADD_DEV_CONTAINER.md) | Accepted | 2026-05-25 13:30 | `.devcontainer/` vendored from Anthropic's reference, with pyenv + Python 3.13.3, mysql client, and PyPI added to the firewall allowlist; `db-query.sh` branches on `DEVCONTAINER`. |
| [ADR-004](./004-ADD_PYTHON_VENV_BOOTSTRAP.md) | Accepted | 2026-05-25 12:35 | `scripts/bootstrap/setup-venv.sh` creates `.venv` and installs `requirements.txt`; committed empty `requirements.txt`. |
| [ADR-003](./003-ADD_DEV_MYSQL_AND_QUERY_WRAPPER.md) | Accepted | 2026-05-25 11:00 | Dev MySQL 8.0 in Docker, env-driven, with a read-only `scripts/db-query.sh` wrapper used by the `mysql-dev` subagent. |
| [ADR-002](./002-ESTABLISH_PROJECT_CONVENTIONS.md) | Accepted | 2026-05-22 14:15 | Established project conventions: modular `CLAUDE.md`, two-artifact change tracking, Nygard-format ADRs with sequential numbering, `.claude/` ecosystem. |
| [ADR-001](./001-ADOPT_ENGLISH_ONLY.md) | Accepted | 2026-05-22 14:00 | All persisted artifacts are written in English. |
