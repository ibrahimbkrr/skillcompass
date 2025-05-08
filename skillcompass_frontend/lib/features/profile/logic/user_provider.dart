import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      _userData = null;
      _error = "Kullanıcı oturumu açık değil.";
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _userData = doc.data();
      } else {
        _userData = null;
        _error = null;
      }
    } catch (e) {
      _userData = null;
      _error = "Veri çekme hatası: $e";
    }
    _isLoading = false;
    notifyListeners();
  }
} 