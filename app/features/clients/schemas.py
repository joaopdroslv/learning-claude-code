"""Pydantic v2 schemas for the clients feature.

``Create`` (input) is split from ``Read`` (output); both use a ``type`` discriminator so a
caller always works with the correct subtype shape (individual vs company).
"""

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


ClientCreate = Annotated[
    Union[IndividualCreate, CompanyCreate], Field(discriminator="type")
]


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
