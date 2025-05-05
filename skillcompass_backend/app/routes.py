from fastapi import APIRouter, HTTPException, Path
from app.database import db
from app.openai_api import analyze_user
from google.cloud import firestore
import traceback
from typing import Dict, Any
import asyncio

router = APIRouter(
    prefix="/users",
    tags=["users"],
)

PROFILE_DOC_NAMES: Dict[str, str] = {
    'identity': 'identity_status_v3',
    'technical': 'technical_profile_v4',
    'learning': 'learning_thinking_style_v2',
    'vision': 'career_vision_v5',
    'blockers': 'blockers_challenges_v3',
    'support': 'support_community_v2',
    'obstacles': 'inner_obstacles_v2',
}

@router.post("/{user_id}/analyze", tags=["analysis"])
async def start_user_analysis(user_id: str = Path(..., description="Kullanıcı ID")):
    print(f"--- Analiz İsteği Alındı --- User ID: {user_id}")
    all_profile_data: Dict[str, Any] = {}
    profile_data_ref = db.collection('users').document(user_id).collection('profile_data')

    try:
        print(f"[1/3] Profil verileri çekiliyor...")
        docs_found_count = 0

        # Firestore çağrılarını asyncio.to_thread ile async hale getir
        for key, doc_name in PROFILE_DOC_NAMES.items():
            print(f"   - '{doc_name}' çekiliyor...")

            doc_snapshot = await asyncio.to_thread(
                lambda: profile_data_ref.document(doc_name).get()
            )

            if doc_snapshot.exists:
                all_profile_data[key] = doc_snapshot.to_dict()
                print(f"   - '{doc_name}' başarıyla alındı.")
                docs_found_count += 1
            else:
                print(f"   - Uyarı: '{doc_name}' bulunamadı.")
                all_profile_data[key] = None

        if docs_found_count == 0:
            print("Hata: Kullanıcı için veri yok.")
            raise HTTPException(status_code=404, detail="Kullanıcı için veri bulunamadı.")

        print(f"[2/3] OpenAI analizi başlatılıyor...")
        analysis_result_text = await analyze_user(all_profile_data)
        print(f"[2/3] Analiz tamamlandı.")

        print(f"[3/3] Firestore'a kayıt yapılıyor...")
        await asyncio.to_thread(
            lambda: profile_data_ref.document('analysis_report').set({
                'report_text': analysis_result_text,
                'generated_at': firestore.SERVER_TIMESTAMP,
            }, merge=True)
        )
        print(f"[3/3] Kayıt başarılı.")

        return {
            "message": "Analiz tamamlandı ve kaydedildi.",
            "user_id": user_id,
            "analysis_report": analysis_result_text
        }

    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        error_details = traceback.format_exc()
        print(f"🔥 HATA:\n{error_details}")
        raise HTTPException(status_code=500, detail=f"Analiz sırasında hata oluştu: {str(e)}")
