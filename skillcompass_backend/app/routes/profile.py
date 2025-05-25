"""
Profil kartı endpointleri - SkillCompass
Her endpointte ilgili Pydantic model kullanılır.
"""
from fastapi import APIRouter, HTTPException, Path, Body, Depends
from skillcompass_backend.app.auth.jwt import verify_access_token, TokenData
from skillcompass_backend.app.services.profile_service import ProfileService
from skillcompass_backend.app.schemas.profile_schemas import (
    IdentityStatus, TechnicalProfile, LearningStyle, CareerVision, Networking, PersonalBrand, ProjectExperience
)
import asyncio

router = APIRouter(
    prefix="/profile",
    tags=["profile"],
)

# 1. Kimlik Durumu
@router.get("/{user_id}/identity-status", response_model=IdentityStatus, response_model_by_alias=True)
async def get_identity_status(user_id: str, token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    data = await asyncio.to_thread(ProfileService.get_identity_status, user_id)
    if not data:
        return IdentityStatus().model_dump(by_alias=True)
    return IdentityStatus(**data).model_dump(by_alias=True)

@router.post("/{user_id}/identity-status")
async def save_identity_status(user_id: str, data: IdentityStatus = Body(...), token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    await asyncio.to_thread(ProfileService.save_identity_status, user_id, data.dict(by_alias=True))
    return {"status": "success"}

# 2. Teknik Profil
@router.get("/{user_id}/technical-profile", response_model=TechnicalProfile, response_model_by_alias=True)
async def get_technical_profile(user_id: str, token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    data = await asyncio.to_thread(ProfileService.get_technical_profile, user_id)
    if not data:
        return TechnicalProfile().model_dump(by_alias=True)
    return TechnicalProfile(**data).model_dump(by_alias=True)

@router.post("/{user_id}/technical-profile")
async def save_technical_profile(user_id: str, data: TechnicalProfile = Body(...), token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    await asyncio.to_thread(ProfileService.save_technical_profile, user_id, data.dict(by_alias=True))
    return {"status": "success"}

# 3. Öğrenme Stili
@router.get("/{user_id}/learning-style", response_model=LearningStyle, response_model_by_alias=True)
async def get_learning_style(user_id: str, token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    data = await asyncio.to_thread(ProfileService.get_learning_style, user_id)
    if not data:
        return LearningStyle().model_dump(by_alias=True)
    return LearningStyle(**data).model_dump(by_alias=True)

@router.post("/{user_id}/learning-style")
async def save_learning_style(user_id: str, data: LearningStyle = Body(...), token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    await asyncio.to_thread(ProfileService.save_learning_style, user_id, data.dict(by_alias=True))
    return {"status": "success"}

# 4. Kariyer Vizyonu
@router.get("/{user_id}/career-vision", response_model=CareerVision, response_model_by_alias=True)
async def get_career_vision(user_id: str, token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    data = await asyncio.to_thread(ProfileService.get_career_vision, user_id)
    if not data:
        return CareerVision().model_dump(by_alias=True)
    return CareerVision(**data).model_dump(by_alias=True)

@router.post("/{user_id}/career-vision")
async def save_career_vision(user_id: str, data: CareerVision = Body(...), token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    await asyncio.to_thread(ProfileService.save_career_vision, user_id, data.dict(by_alias=True))
    return {"status": "success"}

# 5. Networking
@router.get("/{user_id}/networking", response_model=Networking, response_model_by_alias=True)
async def get_networking(user_id: str, token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    data = await asyncio.to_thread(ProfileService.get_networking, user_id)
    if not data:
        return Networking().model_dump(by_alias=True)
    return Networking(**data).model_dump(by_alias=True)

@router.post("/{user_id}/networking")
async def save_networking(user_id: str, data: Networking = Body(...), token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    await asyncio.to_thread(ProfileService.save_networking, user_id, data.dict(by_alias=True))
    return {"status": "success"}

# 6. Kişisel Marka
@router.get("/{user_id}/personal-brand", response_model=PersonalBrand, response_model_by_alias=True)
async def get_personal_brand(user_id: str, token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    data = await asyncio.to_thread(ProfileService.get_personal_brand, user_id)
    if not data:
        return PersonalBrand().model_dump(by_alias=True)
    return PersonalBrand(**data).model_dump(by_alias=True)

@router.post("/{user_id}/personal-brand")
async def save_personal_brand(user_id: str, data: PersonalBrand = Body(...), token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    await asyncio.to_thread(ProfileService.save_personal_brand, user_id, data.dict(by_alias=True))
    return {"status": "success"}

# 7. Proje Deneyimi
@router.get("/{user_id}/project-experience", response_model=ProjectExperience, response_model_by_alias=True)
async def get_project_experience(user_id: str, token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    data = await asyncio.to_thread(ProfileService.get_project_experience, user_id)
    if not data:
        return ProjectExperience().model_dump(by_alias=True)
    return ProjectExperience(**data).model_dump(by_alias=True)

@router.post("/{user_id}/project-experience")
async def save_project_experience(user_id: str, data: ProjectExperience = Body(...), token_data: TokenData = Depends(verify_access_token)):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")
    await asyncio.to_thread(ProfileService.save_project_experience, user_id, data.dict(by_alias=True))
    return {"status": "success"}
