"""Enumerations for the clients feature."""

import enum


class ClientType(str, enum.Enum):
    INDIVIDUAL = "individual"
    COMPANY = "company"
