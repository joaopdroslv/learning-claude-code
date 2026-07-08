# Project Layout

The full repository structure and what lives where.

```
.
├── CLAUDE.md                       # thin index, @-imports each standards file + the reference layout
├── README.md                       # human-facing project overview
├── SETUP.md                        # bootstrap doc — replicate these conventions in a fresh repo
├── alembic.ini                     # Alembic configuration
├── requirements.txt                # Python dependencies
├── .python-version                 # Python version pin (pyenv)
├── .env.example                    # template for MYSQL_* connection settings
├── app/                            # application code (feature-based, see docs/standards/architecture.md)
│   ├── db.py                       # engine, session factory, declarative Base
│   ├── core/                       # cross-cutting infrastructure
│   │   └── metadata.py             # imports every feature's models for Alembic autogenerate
│   └── features/                   # one package per feature (vertical slice)
│       └── clients/
│           ├── enums.py            # ClientType (individual / company)
│           ├── models/             # one SQLAlchemy model per file
│           │   ├── client.py       # Client base (joined-table inheritance)
│           │   ├── individual.py   # Individual (PF)
│           │   └── company.py      # Company (PJ)
│           └── schemas.py          # Pydantic v2 request/response schemas
├── migrations/                     # Alembic environment and version scripts
│   ├── env.py
│   ├── script.py.mako
│   └── versions/                   # one file per migration
├── docker/                         # Compose files for the dev MySQL service
│   └── docker-compose.dev.yml
├── scripts/
│   ├── db-query.sh                 # read-only MySQL query wrapper (used by the mysql-dev subagent)
│   ├── bootstrap/                  # one-shot setup scripts
│   │   ├── setup-venv.sh
│   │   └── init-db.sh
│   └── db/                         # Alembic migration wrappers
│       ├── _alembic.sh
│       ├── migrate-up.sh
│       ├── migrate-down.sh
│       ├── migrate-new.sh
│       └── migrate-status.sh
├── docs/
│   ├── README.md                   # documentation index
│   ├── reference/                  # descriptive docs — what the project is and how it's structured
│   │   ├── README.md
│   │   ├── overview.md
│   │   └── layout.md               # this file
│   ├── standards/                  # rule-sets imported by CLAUDE.md, one per file
│   │   ├── README.md
│   │   ├── language.md
│   │   ├── architecture.md
│   │   ├── change-tracking.md
│   │   └── decision-records.md
│   └── decisions/                  # ADRs, sequential numbering
│       ├── README.md               # index table
│       └── NNN-FEATURE_NAME.md     # one file per decision
├── .devcontainer/                  # Dev Container definition
│   ├── Dockerfile
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   ├── init-firewall.sh            # firewall allowlist
│   └── init-volumes.sh             # named-volume ownership bootstrap
└── .claude/
    ├── commands/                   # custom slash commands (/log-decision, /migrate-new)
    ├── agents/                     # custom subagents (mysql-dev)
    ├── settings.json               # shared (committed)
    └── settings.local.json         # personal (gitignored)
```

## Where things go

- **Descriptive documentation** — what the project is, how it's structured, how to run it — lives in `docs/reference/`.
- **Rules and patterns to follow** when editing the project live in `docs/standards/`, which `CLAUDE.md` `@`-imports.
- **Change history and rationale** lives in `docs/decisions/` as numbered ADRs.

## Audiences

- `README.md` targets humans landing in the repo.
- `CLAUDE.md` (and every file it `@`-imports from `docs/standards/`, plus this layout) targets the model.

These do not duplicate content. The human-facing README points to `CLAUDE.md` for the full rule-set; `CLAUDE.md` does not narrate what the project is for.

## Discoverability

Every directory under `docs/` has its own `README.md` acting as a local index, so a reader can drill down from any entry point.
