from fastapi import APIRouter, HTTPException
from app.database import db  # Firestore bağlantısını getiriyoruz
from app.schemas import UserData  # Sadece dışarıdan şema import ediyoruz
from typing import List
from app.openai_api import analyze_user
from datetime import datetime
from google.cloud import firestore




# Router tanımlıyoruz (bu dosyaya ait API'ler burada toplanacak)
router = APIRouter()

# POST /user-data API Endpoint'i
@router.post("/user-data")
async def create_user_data(user_data: UserData):
    try:
        doc_ref = db.collection('users').document()
        doc_ref.set(user_data.dict())

        return {
            "message": "Kullanıcı verisi Firestore'a başarıyla kaydedildi!",
            "user_id": doc_ref.id  # 🔥 OLUŞAN ID'yi de döndür!
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    
# Kullanıcı verilerini getirme (Tüm kullanıcıların verilerini getirme)
@router.get("/user-data", response_model=List[dict])
async def get_all_user_data():
    try:
        users_ref = db.collection('users')
        docs = users_ref.stream()

        user_list = []
        for doc in docs:
            user = doc.to_dict()
            user_list.append(user)

        return user_list

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
# Kullanıcı verilerini getirme (İlgili kullanıcının verilerini getirme)
@router.get("/user-data/{user_id}", response_model=dict)
async def get_user_data(user_id: str):
    try:
        doc_ref = db.collection('users').document(user_id)
        doc = doc_ref.get()

        if not doc.exists:
            raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı.")
        
        return doc.to_dict()

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Bir hata oluştu: {str(e)}")

#  Kullanıcı güncelleme (PUT)
@router.put("/user-data/{user_id}")
async def update_user_data(user_id: str, user_data: UserData):
    try:
        doc_ref = db.collection('users').document(user_id)
        doc = doc_ref.get()

        if not doc.exists:
            raise HTTPException(status_code=404, detail="Güncellenecek kullanıcı bulunamadı.")

        doc_ref.update(user_data.dict())
        
        return {"message": "Kullanıcı başarıyla güncellendi!"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Bir hata oluştu: {str(e)}")

# Kullanıcı silme (DELETE)  
@router.delete("/user-data/{user_id}")
async def delete_user_data(user_id: str):
    try:
        doc_ref = db.collection('users').document(user_id)
        doc = doc_ref.get()

        if not doc.exists:
            raise HTTPException(status_code=404, detail="Silinecek kullanıcı bulunamadı.")

        doc_ref.delete()

        return {"message": "Kullanıcı başarıyla silindi!"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Bir hata oluştu: {str(e)}")

# Kariyer tavsiyesi alma (GET)
@router.post("/user-data/{user_id}/analyze")
async def analyze_user_data(user_id: str):
    try:
        # Kullanıcıyı Firestore'dan alıyoruz
        doc_ref = db.collection('users').document(user_id)
        doc = doc_ref.get()

        if not doc.exists:
            raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı.")

        # Kullanıcı verisini alıyoruz
        user_data = doc.to_dict()

        # OpenAI API'ye veri gönderiyoruz ve tavsiye alıyoruz
        analysis = analyze_user(user_data)

        # Geçmiş tavsiyelerle birlikte careerAdviceHistory'yi güncelliyoruz
        doc_ref.update({
            # careerAdviceHistory, yeni tavsiyeyi tarih ile birlikte ekliyoruz
            "careerAdviceHistory": firestore.ArrayUnion([{
                "date": str(datetime.now()),  # Şu anki tarih
                "careerAdvice": analysis  # OpenAI'den gelen kariyer tavsiyesi
            }]),
            "careerAdvice": analysis  # Son tavsiyeyi careerAdvice olarak da kaydediyoruz
        })

        return {
            "message": "Kariyer tavsiyesi başarıyla oluşturuldu ve kaydedildi!",
            "career_advice": analysis
        }

    except Exception as e:
        import traceback
        print("🔥 HATA:", traceback.format_exc())  # Hata detayını yazdırıyoruz
        raise HTTPException(status_code=500, detail=f"Bir hata oluştu: {str(e)}")

# Kariyer tavsiyesi geçmişini alma (GET)
@router.get("/user-data/{user_id}/career-advice-history")
async def get_career_advice_history(user_id: str):
    try:
        # Kullanıcıyı Firestore'dan alıyoruz
        doc_ref = db.collection('users').document(user_id)
        doc = doc_ref.get()

        if not doc.exists:
            raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı.")

        # Geçmiş tavsiyeleri alıyoruz
        user_data = doc.to_dict()
        career_advice_history = user_data.get("careerAdviceHistory", [])

        return {
            "career_advice_history": career_advice_history
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Bir hata oluştu: {str(e)}")






