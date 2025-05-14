import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service class for handling all profile-related operations with Firestore
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Identity Status Operations ---
  
  /// Loads identity status data for the current user
  Future<Map<String, dynamic>?> loadIdentityStatus() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('identity_status_v3')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      // Log the error
      print('Error loading identity status: $e');
      rethrow; // Rethrow to let UI handle the error
    }
  }

  /// Saves identity status data for the current user
  Future<void> saveIdentityStatus(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Add updated_at timestamp
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('identity_status_v3')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving identity status: $e');
      rethrow;
    }
  }

  // --- Technical Profile Operations ---
  
  /// Loads technical profile data for the current user
  Future<Map<String, dynamic>?> loadTechnicalProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('technical_profile_v3')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error loading technical profile: $e');
      rethrow;
    }
  }

  /// Saves technical profile data for the current user
  Future<void> saveTechnicalProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('technical_profile_v3')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving technical profile: $e');
      rethrow;
    }
  }

  // --- Learning Style Operations ---
  
  /// Loads learning style data for the current user
  Future<Map<String, dynamic>?> loadLearningStyle() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('learning_thinking_style_v2')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error loading learning style: $e');
      rethrow;
    }
  }

  /// Saves learning style data for the current user
  Future<void> saveLearningStyle(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('learning_thinking_style_v2')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving learning style: $e');
      rethrow;
    }
  }

  // --- Career Vision Operations ---
  
  /// Loads career vision data for the current user
  Future<Map<String, dynamic>?> loadCareerVision() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('career_vision_v5')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error loading career vision: $e');
      rethrow;
    }
  }

  /// Saves career vision data for the current user
  Future<void> saveCareerVision(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('career_vision_v5')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving career vision: $e');
      rethrow;
    }
  }
  
  // --- Blockers & Challenges Operations ---
  
  /// Loads blockers and challenges data for the current user
  Future<Map<String, dynamic>?> loadBlockersChallenges() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('blockers_challenges_v3')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error loading blockers and challenges: $e');
      rethrow;
    }
  }

  /// Saves blockers and challenges data for the current user
  Future<void> saveBlockersChallenges(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('blockers_challenges_v3')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving blockers and challenges: $e');
      rethrow;
    }
  }
  
  // --- Inner Obstacles Operations ---
  
  /// Loads inner obstacles data for the current user
  Future<Map<String, dynamic>?> loadInnerObstacles() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('inner_obstacles_v2')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error loading inner obstacles: $e');
      rethrow;
    }
  }

  /// Saves inner obstacles data for the current user
  Future<void> saveInnerObstacles(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('inner_obstacles_v2')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving inner obstacles: $e');
      rethrow;
    }
  }
  
  // --- Support Community Operations ---
  
  /// Loads support community data for the current user
  Future<Map<String, dynamic>?> loadSupportCommunity() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('support_community_v2')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error loading support community: $e');
      rethrow;
    }
  }

  /// Saves support community data for the current user
  Future<void> saveSupportCommunity(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('support_community_v2')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving support community: $e');
      rethrow;
    }
  }
} 