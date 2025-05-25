from typing import Optional, Dict, Any
from pydantic import BaseModel, Field, EmailStr
from datetime import datetime

class User(BaseModel):
    id: str = Field(..., description="Kullanıcı ID", example="user_12345")
    email: EmailStr = Field(..., description="Kullanıcı email adresi", example="user@example.com")
    full_name: str = Field(..., description="Kullanıcının tam adı", example="Ahmet Yılmaz")
    password: str = Field(..., description="Kullanıcının şifresi", exclude=True)
    created_at: Optional[datetime] = Field(default_factory=datetime.utcnow, description="Oluşturulma tarihi")
    updated_at: Optional[datetime] = Field(default_factory=datetime.utcnow, description="Güncellenme tarihi")

    class Config:
        schema_extra = {
            "example": {
                "id": "user_12345",
                "email": "user@example.com",
                "full_name": "Ahmet Yılmaz",
                "created_at": "2024-05-24T22:00:00Z",
                "updated_at": "2024-05-24T22:00:00Z"
            }
        }

class Profile(BaseModel):
    user_id: str = Field(..., description="Kullanıcı ID", example="user_12345")
    identity: Optional[Dict[str, Any]] = Field(None, description="Kimlik durumu verileri")
    technical: Optional[Dict[str, Any]] = Field(None, description="Teknik profil verileri")
    learning: Optional[Dict[str, Any]] = Field(None, description="Öğrenme ve düşünme stili verileri")
    vision: Optional[Dict[str, Any]] = Field(None, description="Kariyer vizyonu verileri")
    blockers: Optional[Dict[str, Any]] = Field(None, description="Engeller ve zorluklar verileri")
    support: Optional[Dict[str, Any]] = Field(None, description="Destek topluluğu verileri")
    obstacles: Optional[Dict[str, Any]] = Field(None, description="İç engeller verileri")
    analysis_report: Optional[Dict[str, Any]] = Field(None, description="Analiz raporu verileri")

    class Config:
        schema_extra = {
            "example": {
                "user_id": "user_12345",
                "identity": {"status": "completed", "score": 95},
                "technical": {"skills": ["Python", "FastAPI"]},
                "learning": {"style": "visual"},
                "vision": {"goal": "Senior Developer"},
                "blockers": {"current": ["time management"]},
                "support": {"communities": ["Stack Overflow"]},
                "obstacles": {"internal": ["confidence"]},
                "analysis_report": {"summary": "High potential"}
            }
        }
