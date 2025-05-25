import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillcompass_frontend/core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _backendJwt;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  String? get backendJwt => _backendJwt;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    if (_isInitialized) return;
    
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        // Kullanıcı oturum açtığında veya token yenilendiğinde
        final token = await user.getIdToken();
        if (token != null) {
          await _handleFirebaseToken(token);
        }
      } else {
        // Kullanıcı oturumu kapattığında
        await _clearBackendJwt();
      }
      notifyListeners();
    });

    // Mevcut token'ı yükle
    await _loadBackendJwt();
    
    _isInitialized = true;
  }

  Future<void> _handleFirebaseToken(String token) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/users/auth/token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token'
        },
        body: {
          'firebase_token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final backendToken = data['access_token'];
        if (backendToken != null) {
          await _saveBackendJwt(backendToken);
        } else {
          throw Exception('Backend JWT alınamadı.');
        }
      } else {
        throw Exception('Backend token alınamadı: ${response.body}');
      }
    } catch (e) {
      print('Backend token alma hatası: $e');
      await _clearBackendJwt();
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      // Firebase ile giriş yap
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      // Firebase token'ı al
      final token = await userCredential.user?.getIdToken();
      if (token == null) throw Exception('Firebase token alınamadı');

      // Backend'e token ile giriş yap
      await _handleFirebaseToken(token);
    } catch (e) {
      print('Giriş hatası: $e');
      await _clearBackendJwt();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _clearBackendJwt();
    await _auth.signOut();
  }

  Future<void> _saveBackendJwt(String token) async {
    _backendJwt = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend_jwt', token);
    notifyListeners();
  }

  Future<void> _loadBackendJwt() async {
    final prefs = await SharedPreferences.getInstance();
    _backendJwt = prefs.getString('backend_jwt');
    notifyListeners();
  }

  Future<void> _clearBackendJwt() async {
    _backendJwt = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backend_jwt');
    notifyListeners();
  }
} 