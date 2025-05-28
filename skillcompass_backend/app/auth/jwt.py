import os
from fastapi import Depends, HTTPException, status, Request
from pydantic import BaseModel
import firebase_admin
from firebase_admin import auth, credentials
from dotenv import load_dotenv
from typing import Optional
import jwt
from datetime import datetime, timedelta

load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET_KEY", "skillcompass_secret_key")
ALGORITHM = "HS256"

# Firebase Admin başlat (idempotent)
if not firebase_admin._apps:
    cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS") or "skillcompass-project-firebase-adminsdk-fbsvc-97fdc7df20.json"
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

class TokenData(BaseModel):
    user_id: Optional[str] = None

async def verify_access_token(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token eksik veya hatalı.")
    id_token = auth_header.split(" ")[1]
    # Önce custom JWT olarak decode etmeyi dene
    try:
        decoded_token = jwt.decode(id_token, SECRET_KEY, algorithms=[ALGORITHM])
        return TokenData(user_id=decoded_token.get("sub") or decoded_token.get("user_id"))
    except Exception:
        # Olmazsa Firebase ID Token olarak dene
        try:
            decoded_token = auth.verify_id_token(id_token)
            return TokenData(user_id=decoded_token["uid"])
        except Exception:
            raise HTTPException(status_code=401, detail="Geçersiz veya süresi dolmuş token.")

# JWT token üretici fonksiyon
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=60))
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt
