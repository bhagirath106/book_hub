import os

os.environ.setdefault("DATABASE_URL", "postgresql+asyncpg://user:password@localhost/bookhub")
os.environ.setdefault("JWT_SECRET", "test-secret-that-is-long-enough")

from fastapi.testclient import TestClient

from app.main import app


def test_health_endpoint():
    with TestClient(app) as client:
        response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
