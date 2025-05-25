"""
Kullanıcı endpointleri - SkillCompass
Her endpointte modüler UserData modeli kullanılır.
"""
from fastapi import APIRouter, HTTPException, Path, Body, Depends, Form
from skillcompass_backend.app.database import db
from skillcompass_backend.app.openai_api import analyze_user
from google.cloud import firestore
import traceback
from typing import Dict, Any
import asyncio
from skillcompass_backend.app.services.user_service import UserService
from skillcompass_backend.app.schemas.user_schemas import UserData
from skillcompass_backend.app.auth.jwt import verify_access_token, create_access_token, TokenData
from datetime import timedelta
from passlib.context import CryptContext
from firebase_admin import auth
import json
import logging
import os

router = APIRouter(
    prefix="/users",
    tags=["users"],
)

logger = logging.getLogger(__name__)

# Not: Analiz endpointi /analysis/{user_id}/analyze yoluna taşındı.
# Bkz: skillcompass_backend/app/routes/analysis.py

PROFILE_DOC_NAMES: Dict[str, str] = {
    'identity-status': 'identity-status',
    'technical-profile': 'technical-profile',
    'learning-style': 'learning-style',
    'career-vision': 'career-vision',
    'project-experience': 'project-experience',
    'networking': 'networking',
    'personal-brand': 'personal-brand',
}

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@router.get("/{user_id}", response_model=UserData, summary="Kullanıcı getir")
async def get_user(user_id: str, token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    user = await asyncio.to_thread(UserService.get_user_by_id, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı.")
    return user

@router.post("/", response_model=UserData, summary="Yeni kullanıcı oluştur")
async def create_user(user: UserData = Body(...)):
    try:
        await asyncio.to_thread(UserService.create_user, user.uid, user.dict())
        return user
    except Exception as e:
        logger.exception("Kullanıcı oluşturma sırasında hata oluştu.")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{user_id}", response_model=UserData, summary="Kullanıcı güncelle")
async def update_user(user_id: str, user: UserData = Body(...), token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    try:
        await asyncio.to_thread(UserService.update_user, user_id, user.dict())
        return user
    except Exception as e:
        logger.exception("Kullanıcı güncelleme hatası.")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{user_id}", summary="Kullanıcı sil")
async def delete_user(user_id: str, token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    try:
        await asyncio.to_thread(UserService.delete_user, user_id)
        return {"message": "Kullanıcı silindi."}
    except Exception as e:
        logger.exception("Kullanıcı silme hatası.")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/auth/register", summary="Kullanıcı kaydı")
async def register(user: UserData = Body(...)):
    try:
        await asyncio.to_thread(UserService.create_user, user.uid, user.dict())
        return {"message": "Kayıt başarılı."}
    except Exception as e:
        logger.exception("Kayıt sırasında hata oluştu.")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/auth/token", summary="Firebase token ile giriş")
async def login(firebase_token: str = Form(...)) -> Dict[str, Any]:
    try:
        decoded_token = auth.verify_id_token(firebase_token)
        user_id = decoded_token['uid']

        user = await asyncio.to_thread(UserService.get_user_by_id, user_id)
        if not user:
            raise HTTPException(status_code=401, detail="Kullanıcı bulunamadı.")

        expire_minutes = int(os.getenv("JWT_EXPIRE_MINUTES", 60))

        access_token = create_access_token(
            data={"sub": user_id},
            expires_delta=timedelta(minutes=expire_minutes)
        )

        return {"access_token": access_token, "token_type": "bearer"}
    except auth.InvalidIdTokenError:
        raise HTTPException(status_code=401, detail="Geçersiz Firebase token.")
    except Exception as e:
        logger.exception("Token doğrulama hatası.")
        raise HTTPException(status_code=500, detail=str(e))

# TEST AMAÇLI: E-posta/şifre ile JWT token döner (sadece test_user_1 için)
@router.post("/auth/test-login", summary="Test için e-posta/şifre ile JWT üretir (sadece testte kullan!)")
async def test_login(email: str = Body(...), password: str = Body(...)):
    if email == "testuser1@example.com" and password == "Test1234!":
        user_id = "test_user_1"
        expire_minutes = int(os.getenv("JWT_EXPIRE_MINUTES", 60))
        access_token = create_access_token(
            data={"sub": user_id},
            expires_delta=timedelta(minutes=expire_minutes)
        )
        return {"access_token": access_token, "token_type": "bearer"}
    raise HTTPException(status_code=401, detail="Geçersiz e-posta veya şifre")
