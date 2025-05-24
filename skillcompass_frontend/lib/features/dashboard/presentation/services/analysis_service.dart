import 'dart:convert';
import 'package:http/http.dart' as http;

// Güvenlik için önerilen yöntem: Flutter'dan doğrudan OpenAI'ya istek atmak yerine
// kendi backend'inizde (ör. Firebase Functions, FastAPI, Node.js) bir endpoint oluşturun.
// Flutter'dan sadece kendi backend'inize istek atın, backend OpenAI ile konuşsun.
// Böylece API anahtarınız gizli kalır ve rate limit, logging, kullanıcı doğrulama gibi ek güvenlikler ekleyebilirsiniz.
// Örnek backend endpoint kullanımı:
// const endpoint = 'https://your-backend.com/api/analyze';

// Not: Aşağıdaki kod sadece demo amaçlıdır. Gerçek projede doğrudan OpenAI anahtarı kullanmayın!

class AnalysisService {
  static Future<String> analyzeText(String text) async {
    return await analyzeTextCompute(text);
  }
}

Future<String> analyzeTextCompute(String text) async {
  // OpenAI API anahtarınızı güvenli şekilde .env ile yönetin!
  const apiKey = 'YOUR_OPENAI_API_KEY';
  const endpoint = 'https://api.openai.com/v1/chat/completions';

  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'system', 'content': 'Kullanıcıdan gelen metni analiz et ve özetle.'},
        {'role': 'user', 'content': text},
      ],
      'max_tokens': 512,
      'temperature': 0.7,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content']?.toString() ?? 'Yanıt alınamadı.';
  } else {
    throw Exception('API Hatası: ${response.statusCode}\n${response.body}');
  }
}
// Not: Gerçek API anahtarınızı .env ile yönetin ve kodda paylaşmayın! 