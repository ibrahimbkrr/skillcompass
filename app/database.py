import firebase_admin
from firebase_admin import credentials, firestore

# Firebase Admin SDK için servis hesabı anahtarını yüklüyoruz
cred = credentials.Certificate("skillcompass-project-firebase-adminsdk-fbsvc-4a7b677b86.json")

firebase_admin.initialize_app(cred)

# Firestore veritabanı nesnesini oluşturuyoruz
db = firestore.client()
