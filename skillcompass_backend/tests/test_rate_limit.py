from fastapi.testclient import TestClient
from skillcompass_backend.main import app

client = TestClient(app)

USER = {
    "id": "ratelimituser",
    "email": "ratelimit@example.com",
    "full_name": "Rate Limit User",
    "password": "ratelimitpass123"
}

def test_rate_limit():
    client.post("/users/auth/register", json=USER)
    for i in range(5):
        r = client.post("/users/auth/token", data={"username": USER["id"], "password": USER["password"]})
        assert r.status_code == 200
    r = client.post("/users/auth/token", data={"username": USER["id"], "password": USER["password"]})
    assert r.status_code == 429 