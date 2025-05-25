import os
import asyncio
import json
import logging
from dotenv import load_dotenv
import openai
from typing import Dict, Any, List

# Ortam değişkenlerini yükle
# load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '../.env'))

logger = logging.getLogger(__name__)

SIMULATION_MODE = False

SIMULATION_RESPONSE = {
    "status": "success",
    "progress": [
        {"step": 1, "message": "Profil verileri analiz ediliyor..."},
        {"step": 2, "message": "Yapay zeka analizi yapılıyor..."},
        {"step": 3, "message": "Analiz sonuçları işleniyor..."},
        {"step": 4, "message": "Analiz tamamlandı!"}
    ],
    "data": {
        "ozet": "Test kullanıcısı için örnek analiz özeti.",
        "guclu_yonler": ["Takım çalışması", "Analitik düşünme"],
        "gelisim_alanlari": ["Zaman yönetimi"],
        "oneriler": ["Daha fazla proje deneyimi edin.", "Mentorluk al."],
        "detaylar": [
            {"baslik": "Teknik Yetenekler", "icerik": "Python ve Flutter konusunda güçlü."},
            {"baslik": "Kariyer Hedefi", "icerik": "Mobil uygulama geliştirme alanında ilerlemek istiyor."}
        ]
    }
}

async def analyze_user(user_data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Kullanıcı verilerini analiz eder ve yapılandırılmış bir rapor döndürür.
    
    Args:
        user_data: Kullanıcının profil verileri
        
    Returns:
        Dict containing:
            - status: "success" or "error"
            - progress: List of progress steps
            - data: Analysis results in structured format
            - message: Optional status message
            - error: Optional error message
            - details: Optional error details
    """
    progress_messages = []

    if SIMULATION_MODE:
        logger.info("Simülasyon modu açık, test verileri dönüyor.")
        return SIMULATION_RESPONSE

    # Ortam değişkenini terminale yazdır
    print("OPENAI_API_KEY (openai_api.py):", os.environ.get("OPENAI_API_KEY"))

    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        logger.error("OpenAI API anahtarı bulunamadı.")
        return {
            "status": "error",
            "message": "OpenAI API anahtarı bulunamadı.",
            "progress": progress_messages
        }

    openai.api_key = api_key

    try:
        progress_messages.append({"step": 1, "message": "Profil verileri analiz ediliyor..."})

        prompt = f"""Kullanıcı verisi: {json.dumps(user_data, ensure_ascii=False)}

Lütfen bu veriyi analiz ederek aşağıdaki JSON formatında bir yanıt oluştur:
{{
    "ozet": "Genel profil özeti",
    "guclu_yonler": ["güçlü yön 1", "güçlü yön 2", ...],
    "gelisim_alanlari": ["gelişim alanı 1", "gelişim alanı 2", ...],
    "oneriler": ["öneri 1", "öneri 2", ...],
    "detaylar": [
        {{
            "baslik": "Detay başlığı 1",
            "icerik": "Detaylı açıklama 1"
        }},
        ...
    ]
}}

Yanıt MUTLAKA bu JSON formatında ve geçerli JSON olmalıdır. Türkçe karakter kullanabilirsin."""

        progress_messages.append({"step": 2, "message": "Yapay zeka analizi yapılıyor..."})

        response = await asyncio.to_thread(
            lambda: openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "Sen bir kariyer danışmanısın. Kullanıcının profilini analiz edip, belirtilen JSON formatında yanıt vermelisin."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=2000,
                temperature=0.7
            )
        )

        progress_messages.append({"step": 3, "message": "Analiz sonuçları işleniyor..."})

        result_content = response.choices[0].message.content

        try:
            result_json = json.loads(result_content)
            
            # Sonuç formatını doğrula
            required_keys = ["ozet", "guclu_yonler", "gelisim_alanlari", "oneriler", "detaylar"]
            if not all(k in result_json for k in required_keys):
                raise ValueError("Eksik alanlar: " + ", ".join(k for k in required_keys if k not in result_json))
                
            progress_messages.append({"step": 4, "message": "Analiz tamamlandı!"})
            
            return {
                "status": "success",
                "progress": progress_messages,
                "data": result_json
            }
            
        except json.JSONDecodeError as e:
            logger.error(f"JSON decode hatası: {str(e)}")
            return {
                "status": "error",
                "progress": progress_messages,
                "message": "JSON parse hatası oluştu",
                "error": "Geçersiz JSON formatı",
                "details": result_content
            }
        except ValueError as e:
            logger.error(f"Veri doğrulama hatası: {str(e)}")
            return {
                "status": "error",
                "progress": progress_messages,
                "message": "Analiz sonucu beklenen formatta değil",
                "error": str(e),
                "details": result_content
            }

    except Exception as e:
        logger.exception("OpenAI API hatası oluştu.")
        return {
            "status": "error",
            "progress": progress_messages,
            "message": "OpenAI API çağrısı sırasında hata oluştu",
            "error": str(e),
            "details": "Sistem hatası"
        }
