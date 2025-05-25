from pydantic import BaseModel
from typing import List, Dict, Any, Optional

class ProgressStep(BaseModel):
    step: int
    message: str

class AnalysisResponse(BaseModel):
    status: str
    message: Optional[str] = None
    progress: List[ProgressStep] = []
    data: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    details: Optional[str] = None

    class Config:
        schema_extra = {
            "example": {
                "status": "success",
                "message": "Analiz tamamlandı",
                "progress": [
                    {"step": 1, "message": "Profil verileri analiz ediliyor..."},
                    {"step": 2, "message": "Yapay zeka analizi yapılıyor..."},
                    {"step": 3, "message": "Analiz sonuçları işleniyor..."},
                    {"step": 4, "message": "Analiz tamamlandı!"}
                ],
                "data": {
                    "ozet": "Kullanıcı profil özeti",
                    "guclu_yonler": ["Analitik düşünme", "Problem çözme"],
                    "gelisim_alanlari": ["İletişim becerileri"],
                    "oneriler": ["Mentorluk programına katılın"],
                    "detaylar": [
                        {
                            "baslik": "Teknik Yetkinlikler",
                            "icerik": "Python ve Flutter konularında deneyimli"
                        }
                    ]
                }
            }
        } 