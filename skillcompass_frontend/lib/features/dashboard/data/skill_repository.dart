import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SkillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Teknik yetenekleri kaydet
  Future<void> saveTechnicalSkills(List<Map<String, dynamic>> skills) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('skills')
        .doc('technical')
        .set({
      'skills': skills,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Yumuşak yetenekleri kaydet
  Future<void> saveSoftSkills(List<Map<String, dynamic>> skills) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('skills')
        .doc('soft')
        .set({
      'skills': skills,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Dil yeteneklerini kaydet
  Future<void> saveLanguageSkills(List<Map<String, dynamic>> languages) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('skills')
        .doc('language')
        .set({
      'languages': languages,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Sertifikaları kaydet
  Future<void> saveCertificates(List<Map<String, dynamic>> certificates) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('skills')
        .doc('certificates')
        .set({
      'certificates': certificates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Örnek veri yapıları
  static List<Map<String, dynamic>> getDefaultTechnicalSkills() {
    return [
      {
        'name': 'Flutter',
        'level': 8,
        'category': 'Mobile Development',
        'lastUsed': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'name': 'Dart',
        'level': 7,
        'category': 'Programming Languages',
        'lastUsed': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'name': 'Firebase',
        'level': 6,
        'category': 'Backend',
        'lastUsed': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
  }

  static List<Map<String, dynamic>> getDefaultSoftSkills() {
    return [
      {
        'name': 'İletişim',
        'level': 8,
        'category': 'Interpersonal',
        'lastUsed': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'name': 'Problem Çözme',
        'level': 7,
        'category': 'Analytical',
        'lastUsed': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'name': 'Takım Çalışması',
        'level': 9,
        'category': 'Collaboration',
        'lastUsed': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];
  }

  static List<Map<String, dynamic>> getDefaultLanguages() {
    return [
      {
        'name': 'İngilizce',
        'level': 'B2',
        'category': 'Foreign Language',
        'lastUsed': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'name': 'Almanca',
        'level': 'A2',
        'category': 'Foreign Language',
        'lastUsed': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];
  }

  static List<Map<String, dynamic>> getDefaultCertificates() {
    return [
      {
        'name': 'Flutter Development',
        'issuer': 'Google',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'validUntil': DateTime.now().add(const Duration(days: 365)),
      },
      {
        'name': 'Firebase Fundamentals',
        'issuer': 'Google',
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'validUntil': DateTime.now().add(const Duration(days: 365)),
      },
    ];
  }
} 