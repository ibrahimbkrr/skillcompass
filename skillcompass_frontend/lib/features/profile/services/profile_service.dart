import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillcompass_frontend/core/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Profil işlemleri için backend API ile iletişim kuran servis
class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Backend'den kimlik durumu verisini yükler
  Future<Map<String, dynamic>?> loadIdentityStatus() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) return null;
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/identity-status');
    final response = await http.get(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Kimlik durumu yüklenemedi: ${response.body}');
    }
  }

  /// Backend'e kimlik durumu verisini kaydeder
  Future<void> saveIdentityStatus(Map<String, dynamic> data) async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/identity-status');
    final response = await http.post(url, headers: _headers(token), body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Kimlik durumu kaydedilemedi: ${response.body}');
    }
  }

  /// Backend'den teknik profil verisini yükler
  Future<Map<String, dynamic>?> loadTechnicalProfile() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) return null;
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/technical-profile');
    final response = await http.get(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Teknik profil yüklenemedi: ${response.body}');
    }
  }

  /// Backend'e teknik profil verisini kaydeder
  Future<void> saveTechnicalProfile(Map<String, dynamic> data) async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/technical-profile');
    final response = await http.post(url, headers: _headers(token), body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Teknik profil kaydedilemedi: ${response.body}');
    }
  }

  /// Backend'den öğrenme stili verisini yükler
  Future<Map<String, dynamic>?> loadLearningStyle() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) return null;
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/learning-style');
    final response = await http.get(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Öğrenme stili yüklenemedi: ${response.body}');
    }
  }

  /// Backend'e öğrenme stili verisini kaydeder
  Future<void> saveLearningStyle(Map<String, dynamic> data) async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/learning-style');
    final response = await http.post(url, headers: _headers(token), body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Öğrenme stili kaydedilemedi: ${response.body}');
    }
  }

  /// Backend'den kariyer vizyonu verisini yükler
  Future<Map<String, dynamic>?> loadCareerVision() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) return null;
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/career-vision');
    final response = await http.get(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Kariyer vizyonu yüklenemedi: ${response.body}');
    }
  }

  /// Backend'e kariyer vizyonu verisini kaydeder
  Future<void> saveCareerVision(Map<String, dynamic> data) async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/career-vision');
    final response = await http.post(url, headers: _headers(token), body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Kariyer vizyonu kaydedilemedi: ${response.body}');
    }
  }

  /// Backend'den engeller ve zorluklar verisini yükler
  Future<Map<String, dynamic>?> loadBlockersChallenges() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) return null;
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/blockers-challenges');
    final response = await http.get(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Engeller ve zorluklar yüklenemedi: ${response.body}');
    }
  }

  /// Backend'e engeller ve zorluklar verisini kaydeder
  Future<void> saveBlockersChallenges(Map<String, dynamic> data) async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/blockers-challenges');
    final response = await http.post(url, headers: _headers(token), body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Engeller ve zorluklar kaydedilemedi: ${response.body}');
    }
  }

  /// Backend'den destek topluluğu verisini yükler
  Future<Map<String, dynamic>?> loadSupportCommunity() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) return null;
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/support-community');
    final response = await http.get(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Destek topluluğu yüklenemedi: ${response.body}');
    }
  }

  /// Backend'e destek topluluğu verisini kaydeder
  Future<void> saveSupportCommunity(Map<String, dynamic> data) async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/support-community');
    final response = await http.post(url, headers: _headers(token), body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Destek topluluğu kaydedilemedi: ${response.body}');
    }
  }

  /// Backend'den analiz sonucunu alır
  Future<Map<String, dynamic>> analyzeUserProfile() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/analysis/${user.uid}/analyze');
    final response = await http.post(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Analiz işlemi başarısız: \\${response.body}');
    }
  }

  /// Backend'den analiz sonucunu alır (userId ve token ile)
  Future<Map<String, dynamic>> analyzeUserProfileWithToken(String userId, String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/analysis/$userId/analyze');
    final response = await http.post(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Analiz işlemi başarısız: ${response.body}');
    }
  }

  /// Backend'e kişisel marka verisini kaydeder
  Future<void> savePersonalBrand(Map<String, dynamic> data) async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/personal-brand');
    final response = await http.post(url, headers: _headers(token), body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Kişisel marka kaydedilemedi: ${response.body}');
    }
  }

  /// Backend'e networking verisini kaydeder
  Future<void> saveNetworking(Map<String, dynamic> data) async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/networking');
    final response = await http.post(url, headers: _headers(token), body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Networking kaydedilemedi: ${response.body}');
    }
  }

  /// Backend'e proje deneyimi verisini kaydeder
  Future<void> saveProjectExperience(Map<String, dynamic> data) async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) throw Exception('Kullanıcı oturumu yok');
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/project-experience');
    final response = await http.post(url, headers: _headers(token), body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Proje deneyimi kaydedilemedi: ${response.body}');
    }
  }

  /// Backend'den proje deneyimi verisini yükler
  Future<Map<String, dynamic>?> loadProjectExperience() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) return null;
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/project-experience');
    final response = await http.get(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Proje deneyimi yüklenemedi: ${response.body}');
    }
  }

  /// Backend'den kişisel marka verisini yükler
  Future<Map<String, dynamic>?> loadPersonalBrand() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) return null;
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/personal-brand');
    final response = await http.get(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Kişisel marka yüklenemedi: ${response.body}');
    }
  }

  /// Backend'den networking verisini yükler
  Future<Map<String, dynamic>?> loadNetworking() async {
    final token = await _getBackendJwt();
    final user = _auth.currentUser;
    if (user == null || token == null) return null;
    final url = Uri.parse('${AppConstants.baseUrl}/profile/${user.uid}/networking');
    final response = await http.get(url, headers: _headers(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Networking verisi yüklenemedi: ${response.body}');
    }
  }

  /// JWT token'ı secure şekilde alır
  Future<String?> _getBackendJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('backend_jwt');
  }

  /// HTTP istekleri için header oluşturur
  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
} 