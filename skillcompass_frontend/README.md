# skillcompass_frontend

A new Flutter project.

## Kurulum

1. Depoyu klonlayın:
   ```sh
   git clone https://github.com/ibrahimbkrr/skillcompass.git
   cd skillcompass/skillcompass_frontend
   ```
2. Bağımlılıkları yükleyin:
   ```sh
   flutter pub get
   ```
3. Uygulamayı başlatın:
   ```sh
   flutter run
   ```

## Test Çalıştırma

```sh
flutter test
```

## .env Örneği

`.env.example` dosyasını inceleyin ve kendi backend'inizde kullanmak üzere `.env` olarak kopyalayın:

```
OPENAI_API_KEY=sk-xxx...
```

## Güvenlik ve OpenAI API Kullanımı

- OpenAI API anahtarınızı asla doğrudan Flutter kodunda veya .env dosyasında tutmayın.
- Kendi backend'inizde (ör. Firebase Functions, FastAPI, Node.js) bir proxy endpoint oluşturun.
- Flutter'dan sadece kendi backend'inize istek atın, backend OpenAI ile konuşsun.
- .env dosyanızda API anahtarınızı sadece backend için saklayın.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
