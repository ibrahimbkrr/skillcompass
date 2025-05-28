import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillcompass_frontend/core/constants/app_constants.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Güvenlik için önerilen yöntem: Flutter'dan doğrudan OpenAI'ya istek atmak yerine
// kendi backend'inizde (ör. Firebase Functions, FastAPI, Node.js) bir endpoint oluşturun.
// Flutter'dan sadece kendi backend'inize istek atın, backend OpenAI ile konuşsun.
// Böylece API anahtarınız gizli kalır ve rate limit, logging, kullanıcı doğrulama gibi ek güvenlikler ekleyebilirsiniz.
// Örnek backend endpoint kullanımı:
// const endpoint = 'https://your-backend.com/api/analyze';

// Not: Aşağıdaki kod sadece demo amaçlıdır. Gerçek projede doğrudan OpenAI anahtarı kullanmayın!

class AnalysisResponse {
  final String status;
  final String? message;
  final List<ProgressStep> progress;
  final Map<String, dynamic>? data;
  final String? error;
  final String? details;

  AnalysisResponse({
    required this.status,
    this.message,
    required this.progress,
    this.data,
    this.error,
    this.details,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      status: json['status'] as String,
      message: json['message'] as String?,
      progress: (json['progress'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => ProgressStep.fromJson(e))
              .toList() ??
          [],
      data: json['data'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      details: json['details'] as String?,
    );
  }

  @override
  String toString() {
    return 'AnalysisResponse(status: '
        '[32m$status[0m, message: $message, progress: $progress, data: $data, error: $error, details: $details)';
  }
}

class ProgressStep {
  final int step;
  final String message;

  ProgressStep({required this.step, required this.message});

  factory ProgressStep.fromJson(Map<String, dynamic> json) {
    return ProgressStep(
      step: json['step'] as int,
      message: json['message'] as String,
    );
  }

  @override
  String toString() {
    return '{step: $step, message: $message}';
  }
}

class AnalysisService {
  final AuthProvider authProvider;

  AnalysisService(this.authProvider);

  Future<AnalysisResponse> startAnalysis(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.backendJwt;
      print('ANALYSIS API JWT: $token');
      if (token == null) throw Exception('Oturum bulunamadı');
      final userId = authProvider.user?.uid;
      if (userId == null) throw Exception('Kullanıcı ID bulunamadı');
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/analysis/$userId/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnalysisResponse.fromJson(data);
      } else {
        throw Exception('API Hatası: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      return AnalysisResponse(
        status: 'error',
        message: 'Analiz başlatılırken bir hata oluştu',
        progress: [],
        error: e.toString(),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAnalysisHistory() async {
    try {
      final token = authProvider.backendJwt;
      if (token == null) throw Exception('Oturum bulunamadı');

      final userId = authProvider.user?.uid;
      if (userId == null) throw Exception('Kullanıcı ID bulunamadı');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/users/$userId/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else {
        throw Exception('API Hatası: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Analiz geçmişi alınırken hata: $e');
      return [];
    }
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