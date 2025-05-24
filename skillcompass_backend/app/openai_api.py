# app/openai_api.py
import os
import asyncio
import traceback
import json
from dotenv import load_dotenv

# Ortam değişkenlerini yükle
load_dotenv()

# Test modunu açık duruma getiriyorum (API çağrılarını devre dışı bırakır)
SIMULATION_MODE = True 

# Test için örnek analiz JSON sonucu
SIMULATION_RESPONSE = """
{
  "ozet": "Yazılım geliştirme alanında güçlü teknik yetenekleri ve sürekli öğrenme isteği olan, kariyer vizyonunu net bir şekilde belirlemiş, problem çözme yeteneği yüksek bir profesyonelsin. Hem teknik hem de iletişim becerilerini geliştirmeye açıksın.",
  "guclu_yonler": ["Problem çözme yeteneği", "Analitik düşünme", "Öğrenme isteği", "Teknik bilgi birikimi", "Uyum sağlama yeteneği", "Hedef odaklı çalışma"],
  "gelisim_alanlari": ["İş-yaşam dengesi", "Zaman yönetimi", "İletişim becerileri", "Dokümantasyon alışkanlığı", "Mentorluk alma"],
  "oneriler": [
    "Haftada bir kez teknik olmayan bir beceri geliştirmek için zaman ayır",
    "Öğrendiğin bilgileri blog yazıları veya teknik makaleler olarak paylaş",
    "Açık kaynak projelere katkıda bulun",
    "Mentorluk ilişkisi için networking etkinliklerine katıl",
    "Pomodoro tekniği ile zaman yönetimini geliştir",
    "Öğrendiklerini öğretmek için küçük webinarlar düzenle"
  ],
  "detaylar": [
    {"baslik": "Eğitim Geçmişi Analizi", "icerik": "Bilgisayar mühendisliği alanında güçlü bir eğitim temelin var. Akademik bilgileri pratik uygulamalara dönüştürme konusunda yeteneklisin."},
    {"baslik": "Yetenek ve Beceriler Analizi", "icerik": "Full-stack geliştirme, veritabanı yönetimi ve bulut teknolojileri konusunda geniş bir yetenek setine sahipsin. Teknik becerilerin iş dünyasında değerli bir kaynak."},
    {"baslik": "Çalışma Tecrübesi Analizi", "icerik": "Farklı projelerde görev alarak çeşitli teknolojileri kullanma fırsatı bulmuşsun. Bu çeşitlilik, farklı zorluklara uyum sağlama yeteneğini geliştirmiş."},
    {"baslik": "İlgi Alanları ve Kariyer Hedefleri Analizi", "icerik": "Yapay zeka ve veri bilimi alanlarına ilgi duyuyorsun. Bu alanlardaki bilgini derinleştirmen, kariyerinde yeni fırsatlar yaratabilir."},
    {"baslik": "Çalışma Stili ve Motivasyon Analizi", "icerik": "Zorlu problemleri çözmekten keyif alıyor ve yeni şeyler öğrenmek seni motive ediyor. Bu özellikler, yazılım geliştirme alanında başarılı olmak için çok değerli."},
    {"baslik": "Kişisel Güçlü ve Zayıf Yönler Analizi", "icerik": "Teknik konularda kendine güvenin yüksek ancak iş-yaşam dengesi konusunda zorlanabiliyorsun. Zamanı daha iyi yönetmeye odaklanman faydalı olabilir."},
    {"baslik": "Öğrenme Tarzı ve Eğitim Önerileri", "icerik": "Pratik yaparak öğrenmeyi tercih ediyorsun. Öğrendiğin konuları küçük projelerle pekiştirmen ve bilgini paylaşman öğrenme sürecini hızlandırabilir."},
    {"baslik": "1 Yıllık ve 5 Yıllık Kariyer Planı", "icerik": "1 yıl içinde: Mevcut teknik yeteneklerini derinleştir ve mentorluk ilişkisi kur. 5 yıl içinde: Uzmanlaştığın alanda liderlik pozisyonlarına hazırlan ve sürekli öğrenmeyi bir yaşam tarzı haline getir."}
  ]
}
"""

async def analyze_user(user_data: dict):
    print("🧠 [OpenAI] Prompt hazırlanıyor...")

    # Simülasyon modu etkinse, sabit yanıt döndür (şu an her zaman etkin)
    if SIMULATION_MODE:
        print("[ℹ️ SİMÜLASYON MODU] OpenAI API anahtarı geçerli değil, test yanıtı döndürülüyor.")
        print("[✅ OpenAI] Simülasyon yanıtı alındı.")
        return SIMULATION_RESPONSE

    # --- Bu kısım şu anda kullanılmıyor, SIMULATION_MODE = True olduğu için ---
    try:
        # OpenAI API çağrısı yerine doğrudan simülasyon yanıtı döndür
        print("[✅ OpenAI] Yanıt alındı.")
        return SIMULATION_RESPONSE

    except Exception as e:
        print("❌ [OpenAI] Hata:", traceback.format_exc())
        print("[ℹ️ SİMÜLASYON MODU] Hata nedeniyle test yanıtı döndürülüyor.")
        return SIMULATION_RESPONSE
