"""Company (pessoa juridica / PJ) client subtype."""

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
