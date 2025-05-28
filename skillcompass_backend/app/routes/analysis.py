"""
Kariyer analizi endpointi - SkillCompass
Sadece 8 kartı toplar ve analiz eder.
"""
from fastapi import APIRouter, HTTPException, Path, Depends
from skillcompass_backend.app.database import db
from skillcompass_backend.app.openai_api import analyze_user
from skillcompass_backend.app.auth.jwt import verify_access_token, TokenData
from skillcompass_backend.app.schemas.analysis_schemas import AnalysisResponse
from typing import Dict, Any
import asyncio
import logging
from google.cloud import firestore
from fastapi.responses import JSONResponse

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/analysis")

PROFILE_DOCS = [
    "identity-status",
    "technical-profile",
    "learning-style",
    "career-vision",
    "project-experience",
    "networking",
    "personal-brand"
]

@router.post("/{user_id}/analyze")
async def analyze_user_profile(
    user_id: str = Path(..., description="Firebase user ID"),
    token_data: TokenData = Depends(verify_access_token)
):
    if user_id != token_data.user_id:
        raise HTTPException(status_code=403, detail="Yetkisiz işlem.")

    try:
        profile_data_ref = db.collection('users').document(user_id).collection('profile_data')
        all_profile_data = {}
        progress = [{"step": 1, "message": "Profil verileri toplanıyor..."}]
        for doc_name in PROFILE_DOCS:
            doc_snapshot = await asyncio.to_thread(lambda: profile_data_ref.document(doc_name).get())
            all_profile_data[doc_name] = doc_snapshot.to_dict() if doc_snapshot.exists else None
        if not any(all_profile_data.values()):
            return JSONResponse(
                status_code=200,
                content={
                    "status": "error",
                    "message": "Kullanıcı profil verisi bulunamadı",
                    "progress": progress,
                    "error": "Profil verileri eksik"
                },
                headers={"Content-Type": "application/json; charset=utf-8"}
            )
        progress.append({"step": 2, "message": "Yapay zeka analizi yapılıyor..."})
        analysis_result = await analyze_user(all_profile_data)
        if analysis_result.get("status") == "error":
            return JSONResponse(
                status_code=200,
                content={
                    "status": "error",
                    "message": "Analiz sırasında bir hata oluştu",
                    "progress": progress,
                    "error": analysis_result.get("message"),
                    "details": analysis_result.get("details")
                },
                headers={"Content-Type": "application/json; charset=utf-8"}
            )
        progress.append({"step": 3, "message": "Analiz sonuçları kaydediliyor..."})
        await asyncio.to_thread(
            lambda: profile_data_ref.document('analysis_report').set({
                'report': analysis_result.get("data", {}),
                'generated_at': firestore.SERVER_TIMESTAMP,
            }, merge=True)
        )
        progress.append({"step": 4, "message": "Analiz tamamlandı!"})
        analysis_result["progress"] = progress
        return JSONResponse(
            status_code=200,
            content=analysis_result,
            headers={"Content-Type": "application/json; charset=utf-8"}
        )
    except Exception as e:
        logger.exception("Analiz sırasında beklenmeyen hata")
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": "Beklenmeyen bir hata oluştu",
                "progress": progress if 'progress' in locals() else [],
                "error": str(e),
                "details": "Sistem hatası"
            },
            headers={"Content-Type": "application/json; charset=utf-8"}
        )
