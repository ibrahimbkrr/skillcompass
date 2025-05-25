import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/common/themed_card_header.dart';
import 'widgets/common/animated_question_card.dart';
import 'widgets/common/inspiration_popup.dart';
import 'widgets/personal_brand_header.dart';
import 'widgets/personal_brand_profile_question.dart';
import 'widgets/personal_brand_goal_question.dart';
import 'widgets/personal_brand_content_question.dart';
import 'widgets/personal_brand_challenge_question.dart';
import 'widgets/personal_brand_progress_actions.dart';
import 'widgets/common/profile_progress_header.dart';
import 'package:skillcompass_frontend/features/profile/services/profile_service.dart';
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
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _fetchBrandData();
    _animController.forward();
  }

  Future<void> _fetchBrandData() async {
    setState(() { _isLoading = true; });
    try {
      final data = await ProfileService().loadPersonalBrand();
      if (data != null) {
        setState(() {
          _brandData = data;
          _selectedProfiles = List<String>.from(data['current_profiles'] ?? []);
          _brandGoal = data['brand_goal'] ?? '';
          _selectedContents = List<String>.from(data['content_types'] ?? []);
          _brandChallenge = data['brand_challenges'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
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
      final data = {
        'current_profiles': _selectedProfiles,
        'brand_goal': _brandGoal,
        'content_types': _selectedContents,
        'brand_challenges': _brandChallenge,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      await ProfileService().savePersonalBrand(data);
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
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainBlue = Color(0xFF2A4B7C);
    final gold = Color(0xFFD4A017);
    final cloudGrey = Color(0xFFA0AEC0);
    final lightBlue = Color(0xFF6B7280);
    final accentCoral = Color(0xFFFF6B6B);
    final cardPadding = 24.0;
    final borderRadius = 10.0;
    final elevation = 6.0;
    final maxCardWidth = 520.0;
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.95 < maxCardWidth ? size.width * 0.95 : maxCardWidth;

    return Scaffold(
      backgroundColor: bgSoftWhite,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCardWidth),
            child: Card(
              elevation: elevation,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: SingleChildScrollView(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Text(_error!, style: GoogleFonts.inter(color: Colors.red)))
                          : Stack(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ProfileProgressHeader(
                                      completedSteps: (_selectedProfiles.isNotEmpty ? 1 : 0) + (_brandGoal.trim().length >= 10 ? 1 : 0) + (_selectedContents.isNotEmpty ? 1 : 0) + (_brandChallenge.trim().length >= 10 ? 1 : 0),
                                      totalSteps: 4,
                                      progress: ((_selectedProfiles.isNotEmpty ? 1 : 0) + (_brandGoal.trim().length >= 10 ? 1 : 0) + (_selectedContents.isNotEmpty ? 1 : 0) + (_brandChallenge.trim().length >= 10 ? 1 : 0)) / 4,
                                      mainColor: mainBlue,
                                      accentColor: gold,
                                      cardWidth: cardWidth,
                                      icon: Icons.star,
                                      title: 'Kişisel Marka',
                                      description: 'Kişisel markanızı ve hedeflerinizi paylaşın.',
                                    ),
                                    const SizedBox(height: 18),
                                    AnimatedQuestionCard(
                                      completed: _selectedProfiles.isNotEmpty,
                                      borderColor: _selectedProfiles.isNotEmpty ? gold : cloudGrey,
                                      child: PersonalBrandProfileQuestion(
                                        initialSelected: _selectedProfiles,
                                        onChanged: (list) => setState(() => _selectedProfiles = list),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    AnimatedQuestionCard(
                                      completed: _brandGoal.trim().length >= 10,
                                      borderColor: _brandGoal.trim().length >= 10 ? gold : cloudGrey,
                                      child: PersonalBrandGoalQuestion(
                                        initialGoal: _brandGoal,
                                        onChanged: (val) => setState(() => _brandGoal = val),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    AnimatedQuestionCard(
                                      completed: _selectedContents.isNotEmpty,
                                      borderColor: _selectedContents.isNotEmpty ? gold : cloudGrey,
                                      child: PersonalBrandContentQuestion(
                                        initialSelected: _selectedContents,
                                        onChanged: (list) => setState(() => _selectedContents = list),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    AnimatedQuestionCard(
                                      completed: _brandChallenge.trim().length >= 10,
                                      borderColor: _brandChallenge.trim().length >= 10 ? gold : cloudGrey,
                                      child: PersonalBrandChallengeQuestion(
                                        initialChallenge: _brandChallenge,
                                        onChanged: (val) => setState(() => _brandChallenge = val),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _isComplete ? _saveToFirestore : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isComplete ? accentCoral : cloudGrey,
                                          foregroundColor: _isComplete ? Colors.white : lightBlue,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                                          elevation: 0,
                                        ),
                                        child: _isSaving ? const CircularProgressIndicator() : const Text('Kaydet ve İlerle'),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Tüm sorulara yanıt vererek en iyi sonucu alın.', style: GoogleFonts.inter(fontSize: 14, color: lightBlue)),
                                  ],
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 