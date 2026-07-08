# Spec: Clients feature (individuals & companies)

> **Depends on:** —

---

## Problem

The project is heading toward a fake-bank domain (accounts → immutable ledger → balance
projection, fed asynchronously through Kafka). The central legal entity every account and
ledger entry will hang off is the **client**, and a client is either an **individual**
(pessoa física / PF) or a **company** (pessoa jurídica / PJ). These carry different
attributes — a PF has a CPF, full name, and birth date; a PJ has a CNPJ, legal name, and
trade name — so a single flat "customer" shape cannot represent them honestly.

Two concrete gaps today:

1. **Domain.** The only model is `app/models/customer.py` — `customers(full_name, email,
   age, birthdate)`. It has no client type, no status, no PF/PJ split, and `age` is
   redundant with `birthdate`. There is nowhere for accounts/ledger to attach a typed owner.
2. **Structure.** The codebase is layer-based (`app/models/`). There is no FastAPI app, no
   Pydantic typing, and no feature boundaries. This will not scale to the planned features
   (accounts, ledger, workers) without turning into a pile of cross-cutting layer folders.

Since this is the first feature, it also has to establish the pattern the rest of the
project follows.

---

## Solution

Two moves, delivered together because the first feature sets the conventions:

1. **Adopt a feature-based layout.** Each feature owns its models, schemas, and (later)
   router/service/worker under `app/features/<feature>/`. Shared infrastructure stays in
   `app/db.py` (engine, session, `Base`) plus a new `app/core/` for cross-cutting concerns.
   The convention is formalized in an ADR and `docs/standards/architecture.md`.
2. **Model `clients` with SQLAlchemy joined-table inheritance.** A base `clients` table holds
   the columns common to every client plus a `type` discriminator; two subtype tables,
   `individuals` (PF) and `companies` (PJ), each key off `client_id` (PK **and** FK to
   `clients.id`). This gives the rest of the system a single `client_id` to reference while
   letting each subtype enforce its own columns `NOT NULL` in its own table. **Pydantic v2**
   schemas provide strongly-typed, validated input/output.

This spec is the **data layer only**: models, Pydantic schemas, Alembic wiring, and the
migration. No FastAPI app, router, endpoints, workers, or Kafka — those arrive in later
specs.

---

## Non-goals

- **No FastAPI app / router / endpoints.** `app/main.py`, `app/core/config.py`, and any
  `router.py` are deferred to the first spec that actually serves a feature.
- **No accounts, ledger, balances, outbox, Kafka, or workers.**
- **No live-DB rollback.** The database is offline; the old migration is deleted and a fresh
  one generated against an empty schema. There is no applied revision to downgrade.
- **No CPF/CNPJ check-digit validation, auth, soft-delete, or address/contact sub-entities.**
  Validation here is limited to shape (11/14 digits). Check-digit validation is a later
  enhancement.

---

## Feature-based layout

Target tree (only the parts this spec creates or touches):

```
app/
├── __init__.py
├── db.py                        # unchanged: engine, SessionLocal, Base (shared infra)
├── core/
│   ├── __init__.py
│   └── metadata.py              # imports every feature's models so Alembic sees them
└── features/
    ├── __init__.py
    └── clients/
        ├── __init__.py
        ├── enums.py             # ClientType (individual / company)
        ├── models/              # one SQLAlchemy model per file
        │   ├── __init__.py      # re-exports Client, Individual, Company
        │   ├── client.py        # Client (base)
        │   ├── individual.py    # Individual (PF)
        │   └── company.py       # Company (PJ)
        └── schemas.py           # Pydantic v2 schemas
```

`app/models/` is removed entirely. Shared DB infra stays in `app/db.py` so features never
import connection details; only `Base` is imported by models.

---

## Client models (joined-table inheritance)

`Client` is the base mapped class over the `clients` table; it is never instantiated
directly (`polymorphic_abstract=True`). Each subtype adds its own table joined 1:1 on
`client_id`.

The `ClientType` discriminator lives in its own module so other features (accounts, ledger)
can reuse it:

`app/features/clients/enums.py`:

```python
"""Enumerations for the clients feature."""

import enum


class ClientType(str, enum.Enum):
    INDIVIDUAL = "individual"
    COMPANY = "company"
```

`app/features/clients/models/client.py`:

```python
"""Base client model over the `clients` table (joined-table inheritance root).

`Client` holds the columns common to every client; `Individual` (PF) and `Company` (PJ) live
in their own tables keyed by `client_id`. `Client` is never instantiated directly — always
create an `Individual` or a `Company`.
"""
from __future__ import annotations

from datetime import datetime

from sqlalchemy import DateTime, Enum, String, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base
from app.features.clients.enums import ClientType


class Client(Base):
    __tablename__ = "clients"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    type: Mapped[ClientType] = mapped_column(
        Enum(
            ClientType,
            native_enum=False,
            length=20,
            # Store the member value ("individual"/"company"), not the member name,
            # so the DB representation matches the Pydantic/JSON representation.
            values_callable=lambda enum_cls: [member.value for member in enum_cls],
        )
    )
    status: Mapped[str] = mapped_column(String(20), server_default="active")
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    phone: Mapped[str | None] = mapped_column(String(20), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now(), onupdate=func.now()
    )

    __mapper_args__ = {"polymorphic_on": type, "polymorphic_abstract": True}
```

`app/features/clients/models/individual.py`:

```python
"""Individual (pessoa física / PF) client subtype."""
from __future__ import annotations

from datetime import date

from sqlalchemy import Date, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.features.clients.enums import ClientType
from app.features.clients.models.client import Client


class Individual(Client):
    __tablename__ = "individuals"

    client_id: Mapped[int] = mapped_column(ForeignKey("clients.id"), primary_key=True)
    cpf: Mapped[str] = mapped_column(String(11), unique=True, index=True)
    full_name: Mapped[str] = mapped_column(String(255))
    birth_date: Mapped[date] = mapped_column(Date)

    __mapper_args__ = {"polymorphic_identity": ClientType.INDIVIDUAL}
```

`app/features/clients/models/company.py`:

```python
"""Company (pessoa jurídica / PJ) client subtype."""
from __future__ import annotations

from datetime import date

from sqlalchemy import Date, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.features.clients.enums import ClientType
from app.features.clients.models.client import Client


class Company(Client):
    __tablename__ = "companies"

    client_id: Mapped[int] = mapped_column(ForeignKey("clients.id"), primary_key=True)
    cnpj: Mapped[str] = mapped_column(String(14), unique=True, index=True)
    legal_name: Mapped[str] = mapped_column(String(255))
    trade_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    founded_date: Mapped[date | None] = mapped_column(Date, nullable=True)

    __mapper_args__ = {"polymorphic_identity": ClientType.COMPANY}
```

`app/features/clients/models/__init__.py` re-exports so callers and Alembic import from one
place:

```python
"""Client feature models."""
from app.features.clients.models.client import Client
from app.features.clients.models.company import Company
from app.features.clients.models.individual import Individual

__all__ = ["Client", "Company", "Individual"]
```

Notes:
- `type` uses `Enum(..., native_enum=False)` → stored as `VARCHAR(20)` with a `CHECK`
  constraint, portable and readable rather than a MySQL-native `ENUM`. `values_callable` makes
  it store the member *value* (`individual`/`company`) so the DB matches the Pydantic/JSON
  representation instead of the uppercase member name.
- `cpf`/`cnpj` are `String` (→ `VARCHAR`) not integers, to preserve leading zeros.

---

## Data model

**`clients`** (base — common columns):

| Column | Type | Notes |
|---|---|---|
| `id` | INT, PK, autoincrement | |
| `type` | VARCHAR(20) + CHECK | discriminator: `individual` \| `company` |
| `status` | VARCHAR(20), default `active` | |
| `email` | VARCHAR(255), unique, indexed | |
| `phone` | VARCHAR(20), nullable | |
| `created_at` | DATETIME, default `NOW()` | |
| `updated_at` | DATETIME, default `NOW()`, app-side `onupdate` | |

**`individuals`** (PF):

| Column | Type | Notes |
|---|---|---|
| `client_id` | INT, PK, FK → `clients.id` | 1:1 with the base row |
| `cpf` | VARCHAR(11), unique, indexed | 11 digits |
| `full_name` | VARCHAR(255) | |
| `birth_date` | DATE | |

**`companies`** (PJ):

| Column | Type | Notes |
|---|---|---|
| `client_id` | INT, PK, FK → `clients.id` | 1:1 with the base row |
| `cnpj` | VARCHAR(14), unique, indexed | 14 digits |
| `legal_name` | VARCHAR(255) | razão social |
| `trade_name` | VARCHAR(255), nullable | nome fantasia |
| `founded_date` | DATE, nullable | |

---

## Alembic model discovery

With multiple features, `migrations/env.py` can no longer import a single `app.models`.
A new aggregator imports every feature's model modules (models only — never routers/services,
so migrations don't drag in FastAPI):

`app/core/metadata.py`:

```python
"""Aggregates ORM metadata for Alembic.

Import every feature's model modules here so `Base.metadata` is fully populated when Alembic
autogenerate diffs the live schema. Add one import per feature as features are created.
"""
from app.features.clients import models as _clients_models  # noqa: F401

# As new features land, import their models here too, e.g.:
# from app.features.accounts import models as _accounts_models  # noqa: F401
```

`migrations/env.py` — change the model-import line:

```python
# before
from app import models  # noqa: F401  (registers Customer with Base.metadata)

# after
from app.core import metadata  # noqa: F401  (registers every feature's models with Base.metadata)
```

---

## Pydantic schemas

`app/features/clients/schemas.py` — strongly-typed I/O, `Create` (input) split from `Read`
(output), with a discriminated union so a caller gets the right shape per `type`:

```python
"""Pydantic v2 schemas for the clients feature."""
from __future__ import annotations

from datetime import date, datetime
from typing import Annotated, Literal, Union

from pydantic import BaseModel, ConfigDict, EmailStr, Field, StringConstraints

from app.features.clients.enums import ClientType

Cpf = Annotated[str, StringConstraints(pattern=r"^\d{11}$")]
Cnpj = Annotated[str, StringConstraints(pattern=r"^\d{14}$")]


class _ClientBase(BaseModel):
    email: EmailStr
    phone: str | None = None


class IndividualCreate(_ClientBase):
    type: Literal[ClientType.INDIVIDUAL] = ClientType.INDIVIDUAL
    cpf: Cpf
    full_name: str
    birth_date: date


class CompanyCreate(_ClientBase):
    type: Literal[ClientType.COMPANY] = ClientType.COMPANY
    cnpj: Cnpj
    legal_name: str
    trade_name: str | None = None
    founded_date: date | None = None


ClientCreate = Annotated[Union[IndividualCreate, CompanyCreate], Field(discriminator="type")]


class _ClientReadBase(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    status: str
    email: EmailStr
    phone: str | None
    created_at: datetime
    updated_at: datetime


class IndividualRead(_ClientReadBase):
    type: Literal[ClientType.INDIVIDUAL]
    cpf: str
    full_name: str
    birth_date: date


class CompanyRead(_ClientReadBase):
    type: Literal[ClientType.COMPANY]
    cnpj: str
    legal_name: str
    trade_name: str | None
    founded_date: date | None


ClientRead = Annotated[Union[IndividualRead, CompanyRead], Field(discriminator="type")]
```

`EmailStr` requires the `email-validator` package, added via `pydantic[email]` (see Files
Affected).

---

## Migration

The existing base migration (`b1791b328d7d_create_customers.py`) is deleted and a fresh one
generated from the reworked models. Because the database is offline and nothing is applied,
there is no downgrade — but **autogenerate needs a reachable, empty database** to diff
`Base.metadata` against.

Order (also in the Checklist):

1. Delete `app/models/customer.py`, `app/models/__init__.py`, and
   `migrations/versions/b1791b328d7d_create_customers.py`.
2. Add the new models, schemas, and `app/core/metadata.py`; point `env.py` at it.
3. Bring up a **fresh, empty** dev MySQL (`docker/docker-compose.dev.yml`) so autogenerate
   has an empty schema to diff against.
4. Generate the migration: `/migrate-new` (or `./scripts/db/migrate-new.sh "create_clients"`).
   The at-head check passes trivially (no migrations in code, empty DB).
5. Apply it: `./scripts/db/migrate-up.sh`.

Expected autogenerated DDL: `create_table` for `clients`, `individuals`, `companies`; unique
indexes on `clients.email`, `individuals.cpf`, `companies.cnpj`; FKs `individuals.client_id`
and `companies.client_id` → `clients.id`. Review the generated file — autogenerate does not
always emit the `type` `CHECK` constraint or ordering exactly; adjust if needed.

---

## Tests

> The repo has no test harness yet (no `tests/` dir, no pytest config). The rows below are
> the target tests to add; wire them up when a testing spec lands.

| File | Type | What to cover |
|---|---|---|
| `tests/unit/features/clients/test_schemas.py` | unit | `Cpf`/`Cnpj` accept 11/14 digits and reject wrong length or non-digits; `EmailStr` rejects bad emails; `ClientCreate` discriminates `individual` vs `company` by `type` |
| `tests/integration/features/clients/test_models.py` | integration | persist an `Individual` and a `Company`; querying `Client` polymorphically returns the correct subclass; unique violations on `email`, `cpf`, `cnpj` raise `IntegrityError` |

---

## Files Affected

| File | Change |
|---|---|
| `app/models/customer.py` | **Delete** — replaced by the clients feature |
| `app/models/__init__.py` | **Delete** — `app/models/` package removed |
| `migrations/versions/b1791b328d7d_create_customers.py` | **Delete** — old base migration |
| `app/core/__init__.py` | New — package marker |
| `app/core/metadata.py` | New — imports every feature's models for Alembic |
| `app/features/__init__.py` | New — package marker |
| `app/features/clients/__init__.py` | New — package marker |
| `app/features/clients/enums.py` | New — `ClientType` (reusable across features) |
| `app/features/clients/models/__init__.py` | New — re-exports `Client`, `Individual`, `Company` |
| `app/features/clients/models/client.py` | New — `Client` base |
| `app/features/clients/models/individual.py` | New — `Individual` (PF) |
| `app/features/clients/models/company.py` | New — `Company` (PJ) |
| `app/features/clients/schemas.py` | New — Pydantic v2 schemas |
| `migrations/env.py` | Change model import: `app.models` → `app.core.metadata` |
| `migrations/versions/c881c52986ca_create_clients.py` | New — autogenerated migration |
| `requirements.txt` | Add `pydantic[email]>=2,<3` |
| `docs/standards/architecture.md` | New — feature-based layout convention |
| `CLAUDE.md` | Add `@docs/standards/architecture.md` under a new heading |
| `docs/reference/layout.md` | Update tree: feature-based layout + client models |
| `docs/decisions/012-ADOPT_FEATURE_BASED_ARCHITECTURE.md` | New ADR (via `/log-decision`) |
| `docs/decisions/README.md` | Add ADR-012 index row (via `/log-decision`) |
| `README.md` | Freshen the example query mention (`customers` → `clients`) |
| `docs/reference/overview.md` | Update "How it fits together": models now under `app/features/*/models/` |
| `.claude/commands/migrate-new.md` | Update the diff survey path to `app/features/` (models moved) |

Historical ADRs (e.g. `006-ADOPT_SQLALCHEMY_AND_ALEMBIC.md`) are **not** edited — they
record the state at their time.

---

## Checklist

- [x] Add `pydantic[email]>=2,<3` to `requirements.txt` and install
- [x] Create `app/core/` (`__init__.py`, `metadata.py`) and `app/features/clients/` skeleton
- [x] Write `client.py`, `individual.py`, `company.py` + `models/__init__.py`
- [x] Write `schemas.py` with CPF/CNPJ constraints and the discriminated unions
- [x] Point `migrations/env.py` at `app.core.metadata`
- [x] Delete `app/models/customer.py`, `app/models/__init__.py`, and `b1791b328d7d_create_customers.py`
- [x] Bring up a fresh empty dev MySQL; run `/migrate-new` → review generated DDL → `migrate-up` (revision `c881c52986ca`)
- [x] Add `docs/standards/architecture.md`; `@`-import it in `CLAUDE.md`; update `docs/reference/layout.md`
- [x] Log ADR-012 via `/log-decision`
- [ ] (When a test harness exists) add the tests listed above
