import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillcompass_frontend/features/profile/services/profile_service.dart';

class ProfileAnalyticsService {
  final ProfileService _profileService = ProfileService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Kullanıcının profilinin tamamlanma yüzdesini hesaplar
  Future<Map<String, dynamic>> calculateProfileCompleteness() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'overall_percentage': 0.0,
        'sections': {},
        'recommendations': ['Profil tamamlama için giriş yapmalısınız'],
      };
    }

    // Profil bölümlerini yükle
    final identityStatus = await _profileService.loadIdentityStatus();
    final technicalProfile = await _profileService.loadTechnicalProfile();
    final learningStyle = await _profileService.loadLearningStyle();
    final careerVision = await _profileService.loadCareerVision();
    final blockersChallenges = await _profileService.loadBlockersChallenges();
    final innerObstacles = await _profileService.loadInnerObstacles();
    final supportCommunity = await _profileService.loadSupportCommunity();

    // Her bölüm için tamamlanma oranı hesapla
    final identityCompletion = _calculateIdentityCompletion(identityStatus);
    final technicalCompletion = _calculateTechnicalCompletion(technicalProfile);
    final learningCompletion = _calculateLearningCompletion(learningStyle);
    final careerCompletion = _calculateCareerCompletion(careerVision);
    final blockersCompletion = _calculateBlockersCompletion(blockersChallenges);
    final obstaclesCompletion = _calculateObstaclesCompletion(innerObstacles);
    final supportCompletion = _calculateSupportCompletion(supportCommunity);

    // Genel tamamlanma yüzdesini hesapla - her bölüme eşit ağırlık veriyoruz
    final overallPercentage = (
      identityCompletion['percentage'] + 
      technicalCompletion['percentage'] + 
      learningCompletion['percentage'] + 
      careerCompletion['percentage'] +
      blockersCompletion['percentage'] +
      obstaclesCompletion['percentage'] +
      supportCompletion['percentage']
    ) / 7.0;

    // Öneriler listesi oluştur
    final recommendations = <String>[];
    if (identityCompletion['percentage'] < 100) {
      recommendations.add('Kimlik durumu profilini tamamla (${identityCompletion['percentage'].toInt()}%)');
    }
    if (technicalCompletion['percentage'] < 100) {
      recommendations.add('Teknik profilini tamamla (${technicalCompletion['percentage'].toInt()}%)');
    }
    if (learningCompletion['percentage'] < 100) {
      recommendations.add('Öğrenme stili profilini tamamla (${learningCompletion['percentage'].toInt()}%)');
    }
    if (careerCompletion['percentage'] < 100) {
      recommendations.add('Kariyer vizyonu profilini tamamla (${careerCompletion['percentage'].toInt()}%)');
    }
    if (blockersCompletion['percentage'] < 100) {
      recommendations.add('Engeller ve zorluklar profilini tamamla (${blockersCompletion['percentage'].toInt()}%)');
    }
    if (obstaclesCompletion['percentage'] < 100) {
      recommendations.add('İç engeller profilini tamamla (${obstaclesCompletion['percentage'].toInt()}%)');
    }
    if (supportCompletion['percentage'] < 100) {
      recommendations.add('Destek ve topluluk profilini tamamla (${supportCompletion['percentage'].toInt()}%)');
    }

    // Sonuç
    final result = {
      'overall_percentage': overallPercentage,
      'sections': {
        'identity_status': identityCompletion,
        'technical_profile': technicalCompletion,
        'learning_style': learningCompletion,
        'career_vision': careerCompletion,
        'blockers_challenges': blockersCompletion,
        'inner_obstacles': obstaclesCompletion,
        'support_community': supportCompletion,
      },
      'recommendations': recommendations,
      'last_updated': DateTime.now().toIso8601String(),
    };

    // Firebase'e kaydet
    await _saveAnalytics(result);

    return result;
  }

  /// Kimlik durumu tamamlanma yüzdesini hesaplar
  Map<String, dynamic> _calculateIdentityCompletion(Map<String, dynamic>? data) {
    if (data == null) {
      return {'percentage': 0.0, 'missing_fields': ['Tüm alanlar']};
    }

    final requiredFields = [
      'current_status',
      'education_level',
      'interest_areas',
    ];
    
    final missingFields = <String>[];
    int filledFields = 0;

    for (final field in requiredFields) {
      if (data[field] == null || 
          (data[field] is String && data[field].toString().isEmpty) ||
          (data[field] is List && (data[field] as List).isEmpty)) {
        missingFields.add(field);
      } else {
        filledFields++;
      }
    }

    final percentage = (filledFields / requiredFields.length) * 100;
    
    return {
      'percentage': percentage,
      'missing_fields': missingFields,
    };
  }

  /// Teknik profil tamamlanma yüzdesini hesaplar
  Map<String, dynamic> _calculateTechnicalCompletion(Map<String, dynamic>? data) {
    if (data == null) {
      return {'percentage': 0.0, 'missing_fields': ['Tüm alanlar']};
    }

    final requiredFields = [
      'primary_field',
      'experience_level', 
      'technologies'
    ];
    
    final missingFields = <String>[];
    int filledFields = 0;

    for (final field in requiredFields) {
      if (data[field] == null || 
          (data[field] is String && data[field].toString().isEmpty) ||
          (data[field] is List && (data[field] as List).isEmpty)) {
        missingFields.add(field);
      } else {
        filledFields++;
      }
    }

    final percentage = (filledFields / requiredFields.length) * 100;
    
    return {
      'percentage': percentage,
      'missing_fields': missingFields,
    };
  }

  /// Öğrenme stili tamamlanma yüzdesini hesaplar
  Map<String, dynamic> _calculateLearningCompletion(Map<String, dynamic>? data) {
    if (data == null) {
      return {'percentage': 0.0, 'missing_fields': ['Tüm alanlar']};
    }

    final requiredFields = [
      'learning_style',
      'learning_methods',
      'info_sources',
      'analytical_thinking'
    ];
    
    final missingFields = <String>[];
    int filledFields = 0;

    for (final field in requiredFields) {
      if (data[field] == null || 
          (data[field] is String && data[field].toString().isEmpty) ||
          (data[field] is List && (data[field] as List).isEmpty)) {
        missingFields.add(field);
      } else {
        filledFields++;
      }
    }

    final percentage = (filledFields / requiredFields.length) * 100;
    
    return {
      'percentage': percentage,
      'missing_fields': missingFields,
    };
  }

  /// Kariyer vizyonu tamamlanma yüzdesini hesaplar
  Map<String, dynamic> _calculateCareerCompletion(Map<String, dynamic>? data) {
    if (data == null) {
      return {'percentage': 0.0, 'missing_fields': ['Tüm alanlar']};
    }

    final requiredFields = [
      'one_year_goal',
      'five_year_vision',
      'motivation_sources'
    ];
    
    final missingFields = <String>[];
    int filledFields = 0;

    for (final field in requiredFields) {
      if (data[field] == null || 
          (data[field] is String && data[field].toString().isEmpty) ||
          (data[field] is List && (data[field] as List).isEmpty)) {
        missingFields.add(field);
      } else {
        filledFields++;
      }
    }

    final percentage = (filledFields / requiredFields.length) * 100;
    
    return {
      'percentage': percentage,
      'missing_fields': missingFields,
    };
  }

  /// Engeller ve zorluklar tamamlanma yüzdesini hesaplar
  Map<String, dynamic> _calculateBlockersCompletion(Map<String, dynamic>? data) {
    if (data == null) {
      return {'percentage': 0.0, 'missing_fields': ['Tüm alanlar']};
    }

    final requiredFields = [
      'struggledTopics',
      'progressionBlockers',
      'feelingStuckStatus'
    ];
    
    final missingFields = <String>[];
    int filledFields = 0;

    for (final field in requiredFields) {
      if (data[field] == null || 
          (data[field] is String && data[field].toString().isEmpty) ||
          (data[field] is List && (data[field] as List).isEmpty)) {
        missingFields.add(field);
      } else {
        filledFields++;
      }
    }

    final percentage = (filledFields / requiredFields.length) * 100;
    
    return {
      'percentage': percentage,
      'missing_fields': missingFields,
    };
  }

  /// İç engeller tamamlanma yüzdesini hesaplar
  Map<String, dynamic> _calculateObstaclesCompletion(Map<String, dynamic>? data) {
    if (data == null) {
      return {'percentage': 0.0, 'missing_fields': ['Tüm alanlar']};
    }

    final requiredFields = [
      'internalBlockers',
      'fearOfFailureStatus',
      'gaveUpSituation'
    ];
    
    final missingFields = <String>[];
    int filledFields = 0;

    for (final field in requiredFields) {
      if (data[field] == null || 
          (data[field] is String && data[field].toString().isEmpty) ||
          (data[field] is List && (data[field] as List).isEmpty)) {
        missingFields.add(field);
      } else {
        filledFields++;
      }
    }

    final percentage = (filledFields / requiredFields.length) * 100;
    
    return {
      'percentage': percentage,
      'missing_fields': missingFields,
    };
  }

  /// Destek ve topluluk tamamlanma yüzdesini hesaplar
  Map<String, dynamic> _calculateSupportCompletion(Map<String, dynamic>? data) {
    if (data == null) {
      return {'percentage': 0.0, 'missing_fields': ['Tüm alanlar']};
    }

    final requiredFields = [
      'problemSolvingMethods',
      'feedbackPreference',
      'mentorshipPreference',
      'hasSupportCircle'
    ];
    
    final missingFields = <String>[];
    int filledFields = 0;

    for (final field in requiredFields) {
      if (data[field] == null || 
          (data[field] is String && data[field].toString().isEmpty) ||
          (data[field] is List && (data[field] as List).isEmpty)) {
        missingFields.add(field);
      } else {
        filledFields++;
      }
    }

    final percentage = (filledFields / requiredFields.length) * 100;
    
    return {
      'percentage': percentage,
      'missing_fields': missingFields,
    };
  }

  /// Analitik sonuçlarını Firebase'e kaydeder
  Future<void> _saveAnalytics(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analytics')
          .doc('profile_completion')
          .set({
            'data': data,
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error saving analytics: $e');
    }
  }

  /// Profil tamamlanması için kişiselleştirilmiş öneriler oluşturur
  Future<List<String>> getPersonalizedRecommendations() async {
    final analytics = await calculateProfileCompleteness();
    final recommendations = analytics['recommendations'] as List<String>;
    
    // Özel öneriler ekleyebiliriz
    final sections = analytics['sections'] as Map<String, dynamic>;
    
    // Kariyer vizyonu düşük tamamlanmışsa daha detaylı öneriler
    if (sections['career_vision']['percentage'] < 50) {
      recommendations.add('Kariyer hedeflerini belirlemek için mentorlarla görüşmeni öneririz');
    }
    
    // Teknik profil tamamlanmışsa ama öğrenme stili eksikse
    if (sections['technical_profile']['percentage'] > 80 && sections['learning_style']['percentage'] < 50) {
      recommendations.add('Teknolojileri biliyorsun, şimdi öğrenme stilini belirle ve daha verimli ilerle');
    }
    
    // İç engeller ve destek topluluk durumu
    if (sections['inner_obstacles']['percentage'] > 80 && sections['support_community']['percentage'] < 50) {
      recommendations.add('İç engellerini biliyorsun, şimdi destek topluluğunu oluşturarak bu engelleri aşabilirsin');
    }
    
    return recommendations;
  }
} 