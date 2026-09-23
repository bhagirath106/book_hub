import os

os.environ.setdefault("DATABASE_URL", "postgres://user:password@localhost/bookhub?sslmode=require")
os.environ.setdefault("JWT_SECRET", "test-secret-that-is-long-enough")

from app.core.config import Settings


def test_neon_postgres_url_uses_asyncpg_driver():
    settings = Settings()

    assert settings.sqlalchemy_database_url.startswith("postgresql+asyncpg://")
