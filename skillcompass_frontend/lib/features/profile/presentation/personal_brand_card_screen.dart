import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/personal_brand_header.dart';
import 'widgets/personal_brand_profile_question.dart';
import 'widgets/personal_brand_goal_question.dart';
import 'widgets/personal_brand_content_question.dart';
import 'widgets/personal_brand_challenge_question.dart';
import 'widgets/personal_brand_progress_actions.dart';
// ... diğer widget importları (ilerleyen adımlarda eklenecek)

class PersonalBrandCardScreen extends StatefulWidget {
  const PersonalBrandCardScreen({Key? key}) : super(key: key);

  @override
  State<PersonalBrandCardScreen> createState() => _PersonalBrandCardScreenState();
}

class _PersonalBrandCardScreenState extends State<PersonalBrandCardScreen> with SingleTickerProviderStateMixin {
  // --- Renkler ve sabitler ---
  static const Color mainBlue = Color(0xFF2A4B7C);
  static const Color gold = Color(0xFFFFC700);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color bgSoftWhite = Color(0xFFF8FAFC);
  static const Color bgGradientEnd = Color(0xFFE6EAF0);
  static const Color cloudGrey = Color(0xFFA0AEC0);
  static const Color lightBlue = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF38A169);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color accentBlue = Color(0xFF3D5AFE);
  static const Color accentBlueDark = Color(0xFF1741B6);
  static const Color lightGrey = Color(0xFFB0B0B0);
  static const Color green = Color(0xFF4CAF50);

  // --- State ---
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  Map<String, dynamic>? _brandData;

  // --- Kişisel Marka Kartı State ---
  List<String> _selectedProfiles = [];
  String _brandGoal = '';
  List<String> _selectedContents = [];
  String _brandChallenge = '';

  // --- Animasyon ---
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack);
    _fetchBrandData();
    _scaleController.forward();
  }

  Future<void> _fetchBrandData() async {
    setState(() { _isLoading = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() { _isLoading = false; });
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_profile')
          .doc('personal_brand')
          .get();
      final data = doc.data();
      setState(() {
        _brandData = data;
        _selectedProfiles = List<String>.from(data?['current_profiles'] ?? []);
        _brandGoal = data?['brand_goal'] ?? '';
        _selectedContents = List<String>.from(data?['content_types'] ?? []);
        _brandChallenge = data?['brand_challenges'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool get _isComplete =>
      _selectedProfiles.isNotEmpty &&
      _selectedContents.isNotEmpty &&
      _brandGoal.trim().length >= 10 &&
      _brandChallenge.trim().length >= 10;

  Future<void> _saveToFirestore() async {
    setState(() { _isSaving = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_profile')
          .doc('personal_brand')
          .set({
        'current_profiles': _selectedProfiles,
        'brand_goal': _brandGoal,
        'content_types': _selectedContents,
        'brand_challenges': _brandChallenge,
        'lastUpdated': DateTime.now(),
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kişisel marka kartı kaydedildi!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt hatası: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  String? get _summary {
    if (!_isComplete) return null;
    // Basit özet örneği, daha gelişmiş öneri mantığı eklenebilir
    if (_selectedProfiles.contains("GitHub")) {
      return "GitHub'da projeler paylaşarak açık kaynak topluluğuna hitap edin.";
    } else if (_selectedProfiles.contains("LinkedIn")) {
      return "LinkedIn profilinizi optimize ederek işverenlerin dikkatini çekin.";
    } else {
      return "Seçtiğiniz platformlarda özgün içerikler paylaşarak markanızı güçlendirin.";
    }
  }

  List<Map<String, String>> get _resources => [
    {
      "title": "LinkedIn Profili Optimize Etme Rehberi",
      "url": "https://www.linkedin.com/help/linkedin/answer/112133",
    },
    {
      "title": "GitHub'da Projeler Sergileme İpuçları",
      "url": "https://docs.github.com/en/get-started/exploring-projects-on-github/showcasing-your-work-on-your-profile",
    },
    {
      "title": "Kişisel Blog Açma ve İçerik Stratejisi",
      "url": "https://www.freecodecamp.org/news/how-to-start-a-blog/",
    },
  ];

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.9;
    const maxCardWidth = 520.0;
    const minCardWidth = 260.0;
    double cardPadding = 24.0;
    if (size.width < 350) cardPadding = 12.0;
    const borderRadius = 10.0;
    const elevation = 16.0;
    const horizontalPadding = 8.0;

    return Scaffold(
      backgroundColor: bgSoftWhite,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [bgSoftWhite, bgGradientEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: cardWidth,
                      constraints: BoxConstraints(
                        maxWidth: maxCardWidth,
                        minWidth: minCardWidth,
                      ),
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: mainBlue.withOpacity(0.10),
                            blurRadius: elevation,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PersonalBrandHeader(
                            mainBlue: mainBlue,
                            gold: gold,
                            cloudGrey: cloudGrey,
                          ),
                          const SizedBox(height: 24),
                          PersonalBrandProfileQuestion(
                            initialSelected: _selectedProfiles,
                            onChanged: (list) => setState(() => _selectedProfiles = list),
                          ),
                          const SizedBox(height: 24),
                          PersonalBrandGoalQuestion(
                            initialGoal: _brandGoal,
                            onChanged: (val) => setState(() => _brandGoal = val),
                          ),
                          const SizedBox(height: 24),
                          PersonalBrandContentQuestion(
                            initialSelected: _selectedContents,
                            onChanged: (list) => setState(() => _selectedContents = list),
                          ),
                          const SizedBox(height: 24),
                          PersonalBrandChallengeQuestion(
                            initialChallenge: _brandChallenge,
                            onChanged: (val) => setState(() => _brandChallenge = val),
                          ),
                          const SizedBox(height: 32),
                          PersonalBrandProgressActions(
                            isComplete: _isComplete,
                            isSaving: _isSaving,
                            onSave: _saveToFirestore,
                            summary: _summary,
                            resources: _isComplete ? _resources : null,
                            totalSteps: 4,
                            completedSteps: (_selectedProfiles.isNotEmpty ? 1 : 0) + (_brandGoal.trim().length >= 10 ? 1 : 0) + (_selectedContents.isNotEmpty ? 1 : 0) + (_brandChallenge.trim().length >= 10 ? 1 : 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 