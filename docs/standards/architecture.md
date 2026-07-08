# Architecture

This project uses a **feature-based** (vertical-slice) layout with **FastAPI** and
**Pydantic v2**. Code is organized by feature, not by technical layer.

## Layout

Each feature is a self-contained package under `app/features/<feature>/` that owns its own
models, schemas, and — as it grows — router, service, repository, and worker:

```
app/
├── main.py                 # FastAPI app: builds the app and includes each feature's router
├── db.py                   # shared: engine, SessionLocal, declarative Base
├── core/                   # cross-cutting infrastructure (no feature logic)
│   ├── config.py           # Pydantic Settings (env-driven)
│   └── metadata.py         # imports every feature's models for Alembic autogenerate
└── features/
    └── <feature>/
        ├── models/         # one SQLAlchemy model per file; __init__ re-exports them
        ├── schemas.py      # Pydantic v2 request/response schemas
        ├── repository.py   # data access (optional)
        ├── service.py      # business rules (optional)
        └── router.py       # one APIRouter (promote to routers/ only if several are needed)
```

## Rules

- **One SQLAlchemy model per file.** A feature's `models/__init__.py` re-exports its models
  so callers and Alembic import them from one place.
- **Shared infrastructure lives outside features** — the DB engine/session/`Base` in
  `app/db.py`, cross-cutting concerns in `app/core/`. Features import `Base`, never raw
  connection details.
- **Alembic discovers models via `app/core/metadata.py`.** Add one import line there per
  feature. `migrations/env.py` imports that module and nothing else app-side, so migrations
  never drag in FastAPI/routers.
- **One router per feature** (`router.py`); split into a `routers/` package only when a
  feature genuinely needs several. Same for workers — a worker lives in the feature it
  serves (e.g. `app/features/ledger/worker.py`).
- **Strong typing with Pydantic v2.** Validate at the edges; split `...Create` (input) from
  `...Read` (output); use discriminated unions for polymorphic shapes.
- **Infrastructure services (e.g. Kafka) are declared in `docker/`**, one service per
  concern.

Rationale and trade-offs: see [ADR-012](../decisions/012-ADOPT_FEATURE_BASED_ARCHITECTURE.md).
