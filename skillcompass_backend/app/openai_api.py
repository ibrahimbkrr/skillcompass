import os
import asyncio
import json
import logging
from dotenv import load_dotenv
import openai
from typing import Dict, Any, List

# OpenAI API anahtarını doğrudan koda ekle
openai_api_key = "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"

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

    api_key = openai_api_key
    if not api_key:
        logger.error("OpenAI API anahtarı bulunamadı.")
        return {
            "status": "error",
            "message": "OpenAI API anahtarı bulunamadı.",
            "progress": progress_messages
        }

    # Yeni OpenAI API client'ı ile çağrı
    client = openai.OpenAI(api_key=api_key)

    try:
        progress_messages.append({"step": 1, "message": "Profil verileri analiz ediliyor..."})

        prompt = (
            f"Kullanıcı verisi (tüm adımlar ve cevaplar):\n"
            f"{json.dumps(user_data, ensure_ascii=False, indent=2)}\n\n"
            "Aşağıdaki kurallara göre kapsamlı, profesyonel ve kişiselleştirilmiş bir analiz raporu oluştur:\n"
            "- Her kategori için (Kimlik, Teknik Profil, Öğrenme Stili, Kariyer Vizyonu, Proje Deneyimleri, Networking, Kişisel Marka) ayrı ayrı detaylı analiz yap.\n"
            "- Her kategori için: Açıklama, güçlü yönler, gelişim alanları, öneriler, motivasyonel mesaj, örnek ve kaynak önerisi ver.\n"
            "- Teknik ve sosyal becerileri ayrı ayrı analiz et.\n"
            "- Kullanıcının güçlü yönlerine özel tavsiyeler ve gelişim için somut adımlar sun.\n"
            "- Yanıtı SADECE aşağıdaki JSON formatında, uzun ve zengin içerikli döndür. Başka hiçbir şey ekleme, sadece geçerli JSON döndür:\n"
            "{\n"
            "  \"ozet\": \"Genel profil özeti (en az 3 cümle)\",\n"
            "  \"kategoriler\": [\n"
            "    {\n"
            "      \"ad\": \"Kategori Adı\",\n"
            "      \"aciklama\": \"Bu kategoriye dair detaylı analiz\",\n"
            "      \"guclu_yonler\": [\"...\"],\n"
            "      \"gelisim_alanlari\": [\"...\"],\n"
            "      \"oneriler\": [\"...\"],\n"
            "      \"motivasyon\": \"Kısa motivasyonel mesaj\",\n"
            "      \"ornek\": \"Kişiselleştirilmiş örnek\",\n"
            "      \"kaynaklar\": [\"Kaynak 1\", \"Kaynak 2\"]\n"
            "    }, ...\n"
            "  ]\n"
            "}\n"
            "Yanıt SADECE bu JSON formatında ve geçerli JSON olmalı. Türkçe karakter kullanabilirsin."
        )

        progress_messages.append({"step": 2, "message": "Yapay zeka analizi yapılıyor..."})

        logger.info(f"OpenAI API çağrısı başlatılıyor. API KEY: {api_key[:8]}...{api_key[-4:]}")
        try:
            response = await asyncio.to_thread(
                lambda: client.chat.completions.create(
                    model="gpt-4o",
                    messages=[
                        {"role": "system", "content": "Sen bir kariyer danışmanısın. Sadece geçerli JSON döndür, başka hiçbir şey ekleme."},
                        {"role": "user", "content": prompt}
                    ],
                    max_tokens=2000,
                    temperature=0.7
                )
            )
            logger.info(f"OpenAI API çağrısı BAŞARILI (gpt-4o). Response: {response}")
        except Exception as e:
            logger.error(f"gpt-4o ile hata: {str(e)}. gpt-4 ile tekrar deneniyor.")
            response = await asyncio.to_thread(
                lambda: client.chat.completions.create(
                    model="gpt-4",
                    messages=[
                        {"role": "system", "content": "Sen bir kariyer danışmanısın. Sadece geçerli JSON döndür, başka hiçbir şey ekleme."},
                        {"role": "user", "content": prompt}
                    ],
                    max_tokens=2000,
                    temperature=0.7
                )
            )
            logger.info(f"OpenAI API çağrısı BAŞARILI (gpt-4 fallback). Response: {response}")

        progress_messages.append({"step": 3, "message": "Analiz sonuçları işleniyor..."})

        # response objesini ve content'ini logla
        logger.info(f"OpenAI response: {response}")
        result_content = getattr(response.choices[0].message, 'content', None)
        logger.info(f"API cevabı: '{result_content}'")
        if not result_content or not result_content.strip():
            logger.error("OpenAI'den boş cevap geldi.")
            return {
                "status": "error",
                "progress": progress_messages,
                "message": "OpenAI'den boş cevap geldi.",
                "error": "Boş içerik",
                "details": str(response)
            }

        try:
            try:
                result_json = json.loads(result_content, strict=False)
            except json.JSONDecodeError:
                # Son çare: ilk '{' ve son '}' arasını alıp parse et
                import re
                match = re.search(r'\{.*\}', result_content, re.DOTALL)
                if match:
                    result_json = json.loads(match.group(0), strict=False)
                else:
                    raise
            required_keys = ["ozet", "kategoriler"]
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
        logger.exception(f"OpenAI API hatası oluştu. API KEY: {api_key[:8]}...{api_key[-4:]}, Hata: {str(e)}")
        return {
            "status": "error",
            "progress": progress_messages,
            "message": "OpenAI API çağrısı sırasında hata oluştu",
            "error": str(e),
            "details": "Sistem hatası"
        }
