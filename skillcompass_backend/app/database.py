import os
import pathlib
import firebase_admin
from firebase_admin import credentials
from dotenv import load_dotenv
from google.cloud import firestore
import logging

# Ortam değişkenlerini yükle
load_dotenv()

logger = logging.getLogger(__name__)

# Servis hesabı dosya yolunu belirleme
def get_service_account_path() -> str:
    service_account_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

    # .env'de belirtilmişse kontrol et
    if service_account_path and os.path.exists(service_account_path):
        logger.info(f".env dosyasından servis hesabı bulundu: {service_account_path}")
        return service_account_path

    # backend klasöründe ara
    backend_dir = pathlib.Path(__file__).parent.parent
    service_account_files = list(backend_dir.glob("skillcompass-project-firebase-adminsdk-*.json"))

    if service_account_files:
        service_account_path = str(service_account_files[0])
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = service_account_path
        logger.info(f"Backend klasöründe bulunan servis hesabı kullanılıyor: {service_account_path}")
        return service_account_path

    error_msg = (
        "Firestore servis hesabı dosyası bulunamadı! "
        "Lütfen .env dosyasındaki GOOGLE_APPLICATION_CREDENTIALS yolunu kontrol edin "
        "veya servis hesabı JSON dosyasını backend klasörüne yerleştirin."
    )
    logger.error(error_msg)
    raise FileNotFoundError(error_msg)

# Firebase uygulamasını güvenli şekilde başlatma
def initialize_firebase():
    if not firebase_admin._apps:
        service_account_path = get_service_account_path()
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
        logger.info("Firebase başarıyla başlatıldı.")
    else:
        logger.info("Firebase zaten başlatılmış.")

# Firebase başlat
initialize_firebase()

# Firestore veritabanı nesnesini oluştur
db = firestore.Client()
