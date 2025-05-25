import pytest
from fastapi.testclient import TestClient
from skillcompass_backend.main import app

client = TestClient(app)

USER = {
    "id": "testprofileuser",
    "email": "profile@example.com",
    "full_name": "Profile User",
    "password": "profilepass123"
}
PROFILE_DATA = {
    "identity_status_v3": {"status": "active", "city": "Istanbul", "country": "Turkey"},
    "technical_profile_v4": {"skills": ["Python", "FastAPI"]},
    "learning_thinking_style_v2": {"style": "visual"},
    "career_vision_v5": {"vision": "Lead developer"},
    "blockers_challenges_v3": {"blocker": "time management"},
    "support_community_v2": {"community": "Tech Group"},
    "inner_obstacles_v2": {"obstacle": "procrastination"}
}

def get_token():
    client.post("/users/auth/register", json=USER)
    r = client.post("/users/auth/token", data={"username": USER["id"], "password": USER["password"]})
    return r.json()["access_token"]

def test_profile_update_and_get():
    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}
    r = client.put(f"/profiles/{USER['id']}", json=PROFILE_DATA, headers=headers)
    assert r.status_code == 200
    r = client.get(f"/profiles/{USER['id']}", headers=headers)
    assert r.status_code == 200
    assert "identity" in r.json()

def test_analysis_endpoint():
    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}
    # Profil verisi yükle
    r = client.put(f"/profiles/{USER['id']}", json=PROFILE_DATA, headers=headers)
    assert r.status_code == 200
    # Analiz başlat
    r = client.post(f"/users/{USER['id']}/analyze", headers=headers)
    assert r.status_code == 200
    data = r.json()
    assert "analysis_report" in data or "message" in data 