"""Base client model and the client-type discriminator.

Joined-table inheritance: ``Client`` holds the columns common to every client; ``Individual``
(PF) and ``Company`` (PJ) live in their own tables keyed by ``client_id``. ``Client`` is never
instantiated directly — always create an ``Individual`` or a ``Company``.
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
