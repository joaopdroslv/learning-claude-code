# Decision Records

Long-form rationale for every change in this project. Format details in [`../standards/decision-records.md`](../standards/decision-records.md).

To scaffold a new record (and its index row) run:

```
/log-decision <FEATURE_NAME> "<summary>" [type]
```

## Index

| ADR | Status | Date | Summary |
|-----|--------|------|---------|
| [ADR-004](./004-ADD_PYTHON_VENV_BOOTSTRAP.md) | Accepted | 2026-05-25 12:35 | `scripts/bootstrap/setup-venv.sh` creates `.venv` and installs `requirements.txt`; committed empty `requirements.txt`. |
| [ADR-003](./003-ADD_DEV_MYSQL_AND_QUERY_WRAPPER.md) | Accepted | 2026-05-25 11:00 | Dev MySQL 8.0 in Docker, env-driven, with a read-only `scripts/db-query.sh` wrapper used by the `mysql-dev` subagent. |
| [ADR-002](./002-ESTABLISH_PROJECT_CONVENTIONS.md) | Accepted | 2026-05-22 14:15 | Established project conventions: modular `CLAUDE.md`, two-artifact change tracking, Nygard-format ADRs with sequential numbering, `.claude/` ecosystem. |
| [ADR-001](./001-ADOPT_ENGLISH_ONLY.md) | Accepted | 2026-05-22 14:00 | All persisted artifacts are written in English. |
