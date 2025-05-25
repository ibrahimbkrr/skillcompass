import pytest
from fastapi.testclient import TestClient
from skillcompass_backend.main import app

client = TestClient(app)

USER = {
    "id": "testuser",
    "email": "test@example.com",
    "full_name": "Test User",
    "password": "testpass123"
}

def test_register_and_login():
    # Kayıt
    r = client.post("/users/auth/register", json=USER)
    assert r.status_code == 200
    # Giriş
    r = client.post("/users/auth/token", data={"username": USER["id"], "password": USER["password"]})
    assert r.status_code == 200
    assert "access_token" in r.json() 