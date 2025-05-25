import requests
import pytest

BASE_URL = "http://localhost:8000"
USER_ID = "test_user_1"
EMAIL = "testuser1@example.com"
FULL_NAME = "Test Kullanıcı"
PASSWORD = "Test1234!"

@pytest.fixture(scope="session")
def register_user():
    data = {
        "firstName": "Test",
        "lastName": "Kullanıcı",
        "email": EMAIL,
        "uid": USER_ID,
        "birthYear": 2000,
        "gender": "Male",
        "location": {
            "city": "İstanbul",
            "country": "Turkey",
            "livingAreaType": "Urban"
        },
        "education": {
            "highestDegree": "Bachelor's Degree",
            "major": "Computer Engineering",
            "currentlyStudent": False,
            "strongSubjects": ["Algorithms", "Databases"],
            "certificates": ["AWS Certified Developer"]
        },
        "workExperience": {
            "currentlyWorking": True,
            "yearsExperience": "3-5 years",
            "sectorsWorked": ["IT", "Finance"],
            "positions": ["Developer", "Team Lead"],
            "managerialExperience": True,
            "freelanceExperience": False
        },
        "skills": {
            "technicalSkills": ["Python", "React"],
            "socialSkills": ["Teamwork", "Leadership"],
            "problemSolving": 8,
            "englishLevel": "Fluent",
            "otherLanguages": ["Spanish", "German"],
            "highlightedSkill": "Python"
        },
        "interestsAndGoals": {
            "interestedSectors": ["Technology", "AI"],
            "interestedRoles": ["Software Engineer", "Data Scientist"],
            "careerGoal1Year": "Complete senior developer promotion",
            "careerGoal5Year": "Lead a technical team",
            "entrepreneurshipInterest": True,
            "startupCultureInterest": True,
            "internationalCareerGoal": False,
            "desiredImpactArea": "Topluma fayda sağlamak",
            "careerGoalsClarity": 80,
            "careerPriorities": ["Kariyer Gelişimi", "Yenilikçilik"],
            "customCareerPriority": "",
            "careerProgress": 50
        },
        "workingStyleAndMotivation": {
            "workPreference": "Remote",
            "workingLocationPreference": "Hybrid",
            "workingHoursPreference": "Flexible",
            "preferredCompanySize": "Medium",
            "projectTypePreference": "Long-term",
            "mainMotivation": ["Continuous Learning"],
            "customMotivation": None
        },
        "selfAssessment": {
            "strengths": ["Analytical Thinking", "Adaptability"],
            "weaknesses": ["Time Management", "Public Speaking"],
            "lifeChallenges": "Balancing work-life responsibilities",
            "stressHandling": "Moderate stress resilience",
            "learningDesire": 9,
            "identityStory": "Kendi hikayem",
            "technicalConfidence": 8
        },
        "learningPreferences": {
            "learningStyle": ["Visual", "Practical"],
            "customLearningStyle": "Mixed",
            "onlineLearningFrequency": "Weekly",
            "mentorshipInterest": True,
            "learningResources": ["Books", "Online Courses"],
            "customLearningResource": "YouTube Videos",
            "learningMotivation": "Curiosity",
            "learningBarriers": "Time Management"
        },
        "consents": {
            "dataProcessingConsent": True,
            "aiCareerAdviceConsent": True
        },
        "createdAt": "2024-01-01T00:00:00"
    }
    r = requests.post(f"{BASE_URL}/users/auth/register", json=data)
    # 200 veya 409 (zaten kayıtlı) kabul edilebilir
    assert r.status_code in [200, 409], f"Kayıt başarısız: {r.text}"

@pytest.fixture(scope="session")
def jwt_token(register_user):
    data = {
        "email": EMAIL,
        "password": PASSWORD
    }
    r = requests.post(f"{BASE_URL}/users/auth/test-login", json=data)
    assert r.status_code == 200, f"JWT token alınamadı: {r.text}"
    return r.json()["access_token"]

def test_identity_status(jwt_token):
    headers = {
        "Authorization": f"Bearer {jwt_token}",
        "Content-Type": "application/json"
    }
    data = {
        "story": "Kariyerimde insanlara ilham olmak istiyorum.",
        "motivations": ["Yenilik", "Problem Çözme"],
        "custom_motivation": "Kendi işimi kurmak",
        "impact": "Ürün Geliştirme",
        "clarity": 80
    }
    r_post = requests.post(f"{BASE_URL}/profile/{USER_ID}/identity-status", json=data, headers=headers)
    assert r_post.status_code == 200, f"POST başarısız: {r_post.text}"
    r_get = requests.get(f"{BASE_URL}/profile/{USER_ID}/identity-status", headers=headers)
    assert r_get.status_code == 200, f"GET başarısız: {r_get.text}"
    result = r_get.json()
    for key in data:
        assert result.get(key) == data[key], f"Alan uyumsuz: {key} -> {result.get(key)} != {data[key]}"

def test_technical_profile(jwt_token):
    headers = {
        "Authorization": f"Bearer {jwt_token}",
        "Content-Type": "application/json"
    }
    data = {
        "skills": ["Python", "Flutter", "React"],
        "highlight_skill": "Flutter ile mobil uygulama geliştirme",
        "learning_approach": "Uygulamalı Projeler",
        "confidence": 75
    }
    r_post = requests.post(f"{BASE_URL}/profile/{USER_ID}/technical-profile", json=data, headers=headers)
    assert r_post.status_code == 200, f"POST başarısız: {r_post.text}"
    r_get = requests.get(f"{BASE_URL}/profile/{USER_ID}/technical-profile", headers=headers)
    assert r_get.status_code == 200, f"GET başarısız: {r_get.text}"
    result = r_get.json()
    for key in data:
        assert result.get(key) == data[key], f"Alan uyumsuz: {key} -> {result.get(key)} != {data[key]}"

def test_learning_style(jwt_token):
    headers = {
        "Authorization": f"Bearer {jwt_token}",
        "Content-Type": "application/json"
    }
    data = {
        "preference": "Videolar ve Eğitim Platformları",
        "custom_preference": "",
        "resources": ["YouTube Videoları", "Online Eğitim Platformları (Udemy, Coursera)"],
        "custom_resource": "",
        "motivation": "Teknolojide güncel kalmak istiyorum.",
        "barriers": "Zaman yönetimi zorluğu."
    }
    r_post = requests.post(f"{BASE_URL}/profile/{USER_ID}/learning-style", json=data, headers=headers)
    assert r_post.status_code == 200, f"POST başarısız: {r_post.text}"
    r_get = requests.get(f"{BASE_URL}/profile/{USER_ID}/learning-style", headers=headers)
    assert r_get.status_code == 200, f"GET başarısız: {r_get.text}"
    result = r_get.json()
    for key in data:
        assert result.get(key) == data[key], f"Alan uyumsuz: {key} -> {result.get(key)} != {data[key]}"

def test_career_vision(jwt_token):
    headers = {
        "Authorization": f"Bearer {jwt_token}",
        "Content-Type": "application/json"
    }
    data = {
        "short_term_goal": "Bir açık kaynak projesine katkıda bulunmak.",
        "long_term_goal": "Kendi mobil uygulamasını yayınlamak.",
        "priorities": ["Beceri Geliştirme", "Networking"],
        "custom_priority": "",
        "progress": 60
    }
    r_post = requests.post(f"{BASE_URL}/profile/{USER_ID}/career-vision", json=data, headers=headers)
    assert r_post.status_code == 200, f"POST başarısız: {r_post.text}"
    r_get = requests.get(f"{BASE_URL}/profile/{USER_ID}/career-vision", headers=headers)
    assert r_get.status_code == 200, f"GET başarısız: {r_get.text}"
    result = r_get.json()
    for key in data:
        assert result.get(key) == data[key], f"Alan uyumsuz: {key} -> {result.get(key)} != {data[key]}"

def test_project_experience(jwt_token):
    headers = {
        "Authorization": f"Bearer {jwt_token}",
        "Content-Type": "application/json"
    }
    data = {
        "past_projects": "Bir e-ticaret uygulamasında Flutter ile ön yüz geliştirdim.",
        "technologies": ["Flutter/Dart", "Python"],
        "future_project": "Bir yapay zeka tabanlı sohbet uygulaması geliştirmek.",
        "challenges": "Zaman yönetimi ve ekip koordinasyonu."
    }
    r_post = requests.post(f"{BASE_URL}/profile/{USER_ID}/project-experience", json=data, headers=headers)
    assert r_post.status_code == 200, f"POST başarısız: {r_post.text}"
    r_get = requests.get(f"{BASE_URL}/profile/{USER_ID}/project-experience", headers=headers)
    assert r_get.status_code == 200, f"GET başarısız: {r_get.text}"
    result = r_get.json()
    for key in data:
        assert result.get(key) == data[key], f"Alan uyumsuz: {key} -> {result.get(key)} != {data[key]}"

# Networking kartı testi
def test_networking(jwt_token):
    headers = {
        "Authorization": f"Bearer {jwt_token}",
        "Content-Type": "application/json"
    }
    data = {
        "mentorship_need": "Bir mentora ihtiyacım var.",
        "current_connections": ["LinkedIn", "GitHub"],
        "networking_goal": "Bir yıl içinde 10 yeni profesyonel bağlantı kurmak.",
        "networking_challenges": "Çekingenlik ve zaman eksikliği."
    }
    r_post = requests.post(f"{BASE_URL}/profile/{USER_ID}/networking", json=data, headers=headers)
    assert r_post.status_code == 200, f"POST başarısız: {r_post.text}"
    r_get = requests.get(f"{BASE_URL}/profile/{USER_ID}/networking", headers=headers)
    assert r_get.status_code == 200, f"GET başarısız: {r_get.text}"
    result = r_get.json()
    for key in data:
        assert result.get(key) == data[key], f"Alan uyumsuz: {key} -> {result.get(key)} != {data[key]}"

# PersonalBrand kartı testi
def test_personal_brand(jwt_token):
    headers = {
        "Authorization": f"Bearer {jwt_token}",
        "Content-Type": "application/json"
    }
    data = {
        "current_profiles": ["LinkedIn", "GitHub"],
        "brand_goal": "Kişisel markamı güçlendirmek ve daha fazla görünür olmak istiyorum.",
        "content_types": ["Blog Yazıları ve Makaleler", "Proje Tanıtımları (örneğin, GitHub)"],
        "brand_challenges": "Düzenli içerik üretmekte zorlanıyorum."
    }
    r_post = requests.post(f"{BASE_URL}/profile/{USER_ID}/personal-brand", json=data, headers=headers)
    assert r_post.status_code == 200, f"POST başarısız: {r_post.text}"
    r_get = requests.get(f"{BASE_URL}/profile/{USER_ID}/personal-brand", headers=headers)
    assert r_get.status_code == 200, f"GET başarısız: {r_get.text}"
    result = r_get.json()
    for key in data:
        assert result.get(key) == data[key], f"Alan uyumsuz: {key} -> {result.get(key)} != {data[key]}"

def test_analysis(jwt_token):
    headers = {
        "Authorization": f"Bearer {jwt_token}",
        "Content-Type": "application/json"
    }
    r_post = requests.post(f"{BASE_URL}/analysis/{USER_ID}/analyze", headers=headers)
    assert r_post.status_code == 200, f"Analiz POST başarısız: {r_post.text}"
    result = r_post.json()
    assert result.get("status") == "success"
    assert "data" in result
    # İsterseniz: assert "öneri" in result["data"] gibi daha detaylı kontrol ekleyebilirsiniz 