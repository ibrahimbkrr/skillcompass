# 🚀 SkillCompass

## 🌟 Proje Hakkında

SkillCompass, kullanıcıların teknik ve kişisel gelişimlerini analiz ederek kariyer yolculuklarını daha bilinçli ve verimli yönetmelerini sağlayan modern, çok platformlu bir uygulamadır.  
Flutter ile mobil, React ile web arayüzü ve FastAPI tabanlı güçlü bir backend altyapısı sunar.

---

## 🏗️ Genel Mimari

- **Frontend (Flutter):**  
  Mobil uygulama, modern ve kullanıcı dostu arayüzlerle, analiz raporları, dashboard, profil ve daha fazlasını sunar.

- **Web (React):**  
  Web arayüzü ile kullanıcılar analizlerini ve kariyer gelişimlerini masaüstünden de takip edebilir.

- **Backend (FastAPI):**  
  RESTful API, kullanıcı yönetimi, analiz servisleri ve OpenAI entegrasyonu ile hızlı ve güvenli veri akışı sağlar.

---

## ✨ Temel Özellikler

- 🧑‍💻 **Kapsamlı Analiz Raporları:**  
  Kullanıcıların teknik, kişisel ve kariyer gelişimlerini detaylı analiz eder.

- 📊 **Dinamik Dashboard:**  
  Gelişim, hedefler ve öneriler tek ekranda.

- 🔒 **Güvenli Kimlik Doğrulama:**  
  Firebase Authentication ile güvenli giriş.

- 🤖 **Yapay Zeka Destekli Analiz:**  
  OpenAI API ile kişiye özel öneriler.

- 🌐 **Çoklu Platform Desteği:**  
  Mobil (Flutter) ve Web (React) arayüzleri.

---

## 🚀 Kurulum

### 1. Depoyu Klonla
```sh
git clone https://github.com/ibrahimbkrr/skillcompass.git
```

### 2. Backend (FastAPI)
```sh
cd skillcompass/skillcompass_backend
python -m venv .venv
.venv\\Scripts\\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### 3. Frontend (Flutter)
```sh
cd ../skillcompass_frontend
flutter pub get
flutter run
```

### 4. Web (React)
```sh
cd ../skillcompass_web
npm install
npm start
```

---

## 🛡️ Güvenlik

- API anahtarları ve hassas bilgiler `.env` dosyasında tutulur, asla repoya eklenmez!
- `.gitignore` dosyası ile hassas dosyalar korunur.
- Tüm kullanıcı girdileri hem frontend hem backend'de doğrulanır.

---

## 📁 Proje Yapısı

```
skillcompass/
├── skillcompass_backend/   # FastAPI backend
├── skillcompass_frontend/  # Flutter mobil uygulama
├── skillcompass_web/       # React web arayüzü
└── tests/                  # Testler
```

---

## 📢 Katkı ve İletişim

- Katkıda bulunmak için lütfen bir issue açın veya pull request gönderin.
- Her türlü soru ve öneriniz için [GitHub Issues](https://github.com/ibrahimbkrr/skillcompass/issues) üzerinden iletişime geçebilirsiniz.

---

## 🏆 Lisans

MIT License 