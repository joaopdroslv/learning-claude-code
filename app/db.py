"""Database engine, session factory, and declarative base."""

from __future__ import annotations

import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

load_dotenv()


def _build_database_url() -> str:
    user = os.environ["MYSQL_DEFAULT_USER"]
    password = os.environ["MYSQL_DEFAULT_USER_PASSWORD"]
    host = os.environ.get("MYSQL_HOST", "127.0.0.1")
    port = os.environ.get("MYSQL_HOST_PORT", "3306")
    database = os.environ["MYSQL_DATABASE"]
    return f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}"


DATABASE_URL = _build_database_url()

engine = create_engine(DATABASE_URL, future=True)

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


class Base(DeclarativeBase):
    """Single declarative base for every ORM model in this project."""
