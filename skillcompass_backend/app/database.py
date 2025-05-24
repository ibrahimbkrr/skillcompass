import os
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

# Ortam değişkenlerini yükle
load_dotenv()

# Servis hesabı dosya yolunu .env'den al
service_account_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", "skillcompass-project-firebase-adminsdk-fbsvc-d0608a42c2.json")
cred = credentials.Certificate(service_account_path)

firebase_admin.initialize_app(cred)

# Firestore veritabanı nesnesini oluşturuyoruz
db = firestore.client()
