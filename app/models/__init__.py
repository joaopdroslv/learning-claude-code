"""ORM models. Import every model here so Alembic autogenerate can see them."""

from app.models.customer import Customer

__all__ = ["Customer"]
