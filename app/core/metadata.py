"""Aggregates ORM metadata for Alembic.

Import every feature's model modules here so ``Base.metadata`` is fully populated when Alembic
autogenerate diffs the live schema. Models only — never routers/services, so migrations do not
drag in FastAPI. Add one import per feature as features are created.
"""

from app.features.clients import models as _clients_models  # noqa: F401

# As new features land, import their models here too, e.g.:
# from app.features.accounts import models as _accounts_models  # noqa: F401
