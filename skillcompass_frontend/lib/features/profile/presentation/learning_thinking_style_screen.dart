import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/services/profile_service.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'widgets/learning_style_header.dart';
import 'widgets/learning_style_preference_card.dart';
import 'widgets/learning_style_resources_card.dart';
import 'widgets/learning_style_motivation_card.dart';
import 'widgets/learning_style_barrier_card.dart';
import 'widgets/learning_style_progress_actions.dart';
import 'widgets/common/themed_card_header.dart';
import 'widgets/common/themed_back_button.dart';
import 'widgets/common/animated_question_card.dart';
import 'widgets/common/inspiration_popup.dart';
import 'widgets/common/profile_progress_header.dart';

class LearningThinkingStyleScreen extends StatefulWidget {
  const LearningThinkingStyleScreen({Key? key}) : super(key: key);

  @override
  State<LearningThinkingStyleScreen> createState() => _LearningThinkingStyleScreenState();
}

class _LearningThinkingStyleScreenState extends State<LearningThinkingStyleScreen> with SingleTickerProviderStateMixin {
  // --- Theme Colors ---
  static const Color mainBlue = Color(0xFF2A4B7C);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color bgSoftWhite = Color(0xFFF8FAFC);
  static const Color bgGradientEnd = Color(0xFFE6EAF0);
  static const Color cloudGrey = Color(0xFFA0AEC0);
  static const Color lightBlue = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF38A169);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color gold = Color(0xFFD4A017);

  // --- Animation ---
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  // --- Soru 1: Öğrenme Tercihi ---
  final List<String> _preferenceOptions = [
    "Videolar ve Eğitim Platformları",
    "Kitaplar ve Makaleler",
    "Uygulamalı Projeler",
    "Mentor veya Eğitim Grupları",
    "Diğer"
  ];
  String? _selectedPreference;
  bool _showCustomPreferenceInput = false;
  String _customPreference = '';
  final TextEditingController _customPreferenceController = TextEditingController();
  final List<String> _customPreferenceList = [];

  // --- Soru 2: Kaynaklar ---
  final List<String> _resourceOptions = [
    "Online Eğitim Platformları (Udemy, Coursera)",
    "YouTube Videoları",
    "Açık Kaynak Belgeler (GitHub, Stack Overflow)",
    "Kütüphane ve Akademik Kaynaklar",
    "Diğer"
  ];
  final List<String> _selectedResources = [];
  bool _showCustomResourceInput = false;
  String _customResource = '';
  final TextEditingController _customResourceController = TextEditingController();

  // --- Soru 3: Motivasyon ---
  final TextEditingController _motivationController = TextEditingController();
  String _motivation = '';
  int _motivationInspireIndex = 0;
  bool _showMotivationInspirePopup = false;
  final List<String> _motivationInspireList = [
    "Kariyerimde ilerlemek için yeni beceriler kazanmak.",
    "Gerçek projelerde uygulama yaparak öğrenmek.",
    "Teknolojide güncel kalmak ve yenilikleri takip etmek.",
    "Bir topluluğa katkı sağlamak ve paylaşmak."
  ];
  Timer? _motivationInspireTimer;

  // --- Soru 4: Engeller ---
  final TextEditingController _barrierController = TextEditingController();
  String _barrier = '';
  int _barrierInspireIndex = 0;
  bool _showBarrierInspirePopup = false;
  final List<String> _barrierInspireList = [
    "Yeterli pratik yapma fırsatı bulamamak.",
    "Zaman yönetimi zorluğu.",
    "Karmaşık konularda motivasyon kaybı.",
    "Kaynakların dağınık ve ulaşılması zor olması."
  ];
  Timer? _barrierInspireTimer;

  // --- Progress ---
  int get _completedCount {
    int count = 0;
    if ((_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty) count++;
    if (_selectedResources.isNotEmpty) count++;
    if (_motivation.trim().length >= 10) count++;
    if (_barrier.trim().length >= 10) count++;
    return count;
  }

  // --- Firestore ---
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
    _fetchExistingData();
  }

  Future<void> _fetchExistingData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _profileService.loadLearningStyle();
      if (data != null) {
        setState(() {
          _selectedPreference = data['preference'] ?? '';
          _customPreference = data['custom_preference'] ?? '';
          _selectedResources.clear();
          _selectedResources.addAll(List<String>.from(data['resources'] ?? []));
          _customResource = data['custom_resource'] ?? '';
          _motivation = data['motivation'] ?? '';
          _motivationController.text = _motivation;
          _barrier = data['barriers'] ?? '';
          _barrierController.text = _barrier;
        });
      }
    } catch (e) {
      // Hata yönetimi
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final data = {
      'preference': _selectedPreference ?? '',
      'custom_preference': _customPreferenceList,
      'resources': _selectedResources,
      'custom_resource': _customResource,
      'motivation': _motivation.trim(),
      'barriers': _barrier.trim(),
    };
    try {
      await _profileService.saveLearningStyle(data);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      // Hata yönetimi
    }
    setState(() => _isSaving = false);
  }

  double _responsiveFont(BuildContext context, num base) {
    final scale = MediaQuery.of(context).textScaleFactor;
    return (base * scale).clamp(16, 20).toDouble();
  }

  void _showMotivationInspire() {
    setState(() {
      _showMotivationInspirePopup = true;
      _motivationInspireIndex = (_motivationInspireIndex + 1) % _motivationInspireList.length;
    });
    _motivationInspireTimer?.cancel();
    _motivationInspireTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _showMotivationInspirePopup = false);
    });
  }

  void _showBarrierInspire() {
    setState(() {
      _showBarrierInspirePopup = true;
      _barrierInspireIndex = (_barrierInspireIndex + 1) % _barrierInspireList.length;
    });
    _barrierInspireTimer?.cancel();
    _barrierInspireTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _showBarrierInspirePopup = false);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _customPreferenceController.dispose();
    _customResourceController.dispose();
    _motivationController.dispose();
    _barrierController.dispose();
    _motivationInspireTimer?.cancel();
    _motivationInspireTimer = null;
    _barrierInspireTimer?.cancel();
    _barrierInspireTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double horizontalPadding = 12;
    final double cardPadding = 20;
    final double maxCardWidth = 520;
    final double cardWidth = size.width - 2 * horizontalPadding < maxCardWidth
        ? size.width - 2 * horizontalPadding
        : maxCardWidth;
    final double borderRadius = 10;
    final double elevation = 6;
    final double progress = 4 / 7;

    return Scaffold(
      backgroundColor: bgSoftWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ThemedBackButton(),
      ),
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
          if (_showMotivationInspirePopup)
            InspirationPopup(
              text: _motivationInspireList[_motivationInspireIndex],
              color: gold,
              visible: true,
            ),
          if (_showBarrierInspirePopup)
            InspirationPopup(
              text: _barrierInspireList[_barrierInspireIndex],
              color: gold,
              visible: true,
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: cardWidth,
                      constraints: BoxConstraints(maxWidth: maxCardWidth),
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
                          ProfileProgressHeader(
                            completedSteps: _completedCount,
                            totalSteps: 4,
                            progress: _completedCount / 4,
                            mainColor: mainBlue,
                            accentColor: gold,
                            cardWidth: cardWidth,
                            icon: Icons.menu_book_rounded,
                            title: 'Öğrenme/Düşünme Stili',
                            description: 'Nasıl öğrendiğinizi ve düşündüğünüzü paylaşın. Kişisel gelişiminize ışık tutacak ipuçları verin.',
                          ),
                          const SizedBox(height: 18),
                          AnimatedQuestionCard(
                            completed: (_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty,
                            borderColor: ((_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty) ? gold : cloudGrey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LearningStylePreferenceCard(
                                  preferenceOptions: _preferenceOptions,
                                  selectedPreference: _selectedPreference,
                                  showCustomPreferenceInput: _showCustomPreferenceInput,
                                  customPreferenceController: _customPreferenceController,
                                  customPreference: _customPreference,
                                  customPreferenceList: _customPreferenceList,
                                  onCustomDelete: (pref) => setState(() => _customPreferenceList.remove(pref)),
                                  mainBlue: mainBlue,
                                  gold: gold,
                                  cloudGrey: cloudGrey,
                                  lightBlue: lightBlue,
                                  onOptionSelected: (option, val) {
                                    setState(() {
                                      if (option == 'Diğer') {
                                        _showCustomPreferenceInput = val;
                                        if (!val) _customPreferenceController.clear();
                                      } else {
                                        if (val) {
                                          _selectedPreference = option;
                                          _showCustomPreferenceInput = false;
                                          _customPreferenceController.clear();
                                        } else {
                                          _selectedPreference = null;
                                        }
                                      }
                                    });
                                  },
                                  onCustomChanged: (val) => setState(() => _customPreference = val),
                                  onCustomAdd: () {
                                    setState(() {
                                      final trimmed = _customPreference.trim();
                                      if (trimmed.isNotEmpty && !_customPreferenceList.contains(trimmed)) {
                                        _customPreferenceList.add(trimmed);
                                        _customPreference = '';
                                        _customPreferenceController.clear();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnimatedQuestionCard(
                            completed: _selectedResources.isNotEmpty,
                            borderColor: _selectedResources.isNotEmpty ? gold : cloudGrey,
                            child: LearningStyleResourcesCard(
                              resourceOptions: _resourceOptions,
                              selectedResources: _selectedResources,
                              showCustomResourceInput: _showCustomResourceInput,
                              customResourceController: _customResourceController,
                              customResource: _customResource,
                              mainBlue: mainBlue,
                              gold: gold,
                              cloudGrey: cloudGrey,
                              lightBlue: lightBlue,
                              onOptionSelected: (option, val) {
                                setState(() {
                                  if (option == 'Diğer') {
                                    _showCustomResourceInput = val;
                                    if (!val) _customResourceController.clear();
                                  } else {
                                    if (val && _selectedResources.length < 3) {
                                      _selectedResources.add(option);
                                    } else if (!val) {
                                      _selectedResources.remove(option);
                                    }
                                  }
                                });
                              },
                              onCustomChanged: (val) => setState(() => _customResource = val),
                              onCustomAdd: () {
                                setState(() {
                                  _selectedResources.add(_customResource.trim());
                                  _customResourceController.clear();
                                  _customResource = '';
                                  _showCustomResourceInput = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnimatedQuestionCard(
                            completed: _motivation.trim().length >= 10,
                            borderColor: _motivation.trim().length >= 10 ? gold : cloudGrey,
                            child: LearningStyleMotivationCard(
                              motivationController: _motivationController,
                              motivation: _motivation,
                              showInspirePopup: _showMotivationInspirePopup,
                              inspireIndex: _motivationInspireIndex,
                              inspireList: _motivationInspireList,
                              mainBlue: mainBlue,
                              gold: gold,
                              cloudGrey: cloudGrey,
                              lightBlue: lightBlue,
                              onInspireTap: _showMotivationInspire,
                              onChanged: (val) => setState(() => _motivation = val),
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnimatedQuestionCard(
                            completed: _barrier.trim().length >= 10,
                            borderColor: _barrier.trim().length >= 10 ? gold : cloudGrey,
                            child: LearningStyleBarrierCard(
                              barrierController: _barrierController,
                              barrier: _barrier,
                              showInspirePopup: _showBarrierInspirePopup,
                              inspireIndex: _barrierInspireIndex,
                              inspireList: _barrierInspireList,
                              mainBlue: mainBlue,
                              gold: gold,
                              cloudGrey: cloudGrey,
                              lightBlue: lightBlue,
                              onInspireTap: _showBarrierInspire,
                              onChanged: (val) => setState(() => _barrier = val),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isComplete ? _saveData : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isComplete ? accentCoral : cloudGrey,
                                foregroundColor: isComplete ? Colors.white : darkGrey,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                                elevation: 0,
                              ),
                              child: const Text('Kaydet ve İlerle'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Tüm sorulara yanıt vererek en iyi sonucu alın.', style: GoogleFonts.inter(fontSize: 14, color: lightBlue)),
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

  void _showGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Öğrenme Stili Kartı',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: mainBlue),
        ),
        content: const Text(
          'Bu kart, öğrenme alışkanlıklarınızı anlamanıza yardımcı olur. Tercihlerinizi belirleyin ve öğrenme stratejinizi güçlendirin.',
          style: TextStyle(fontSize: 16, color: darkGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  bool get isComplete {
    return ((_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty) &&
        _selectedResources.isNotEmpty &&
        _motivation.trim().length >= 10 &&
        _barrier.trim().length >= 10;
  }
} 