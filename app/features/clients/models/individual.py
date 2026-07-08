"""Individual (pessoa fisica / PF) client subtype."""

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
