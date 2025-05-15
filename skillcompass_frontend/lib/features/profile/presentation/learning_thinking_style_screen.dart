import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'widgets/learning_style_header.dart';
import 'widgets/learning_style_preference_card.dart';
import 'widgets/learning_style_resources_card.dart';
import 'widgets/learning_style_motivation_card.dart';
import 'widgets/learning_style_barrier_card.dart';
import 'widgets/learning_style_progress_actions.dart';

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
  late Animation<double> _headerAnim;
  late Animation<double> _fadeAnim;

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

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    _fetchExistingData();
  }

  Future<void> _fetchExistingData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('user_profile')
        .doc('learning_style')
        .get();
    if (doc.exists) {
      final data = doc.data() ?? {};
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
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }
    final data = {
      'preference': _selectedPreference ?? '',
      'custom_preference': _customPreference,
      'resources': _selectedResources,
      'custom_resource': _customResource,
      'motivation': _motivation.trim(),
      'barriers': _barrier.trim(),
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('user_profile')
        .doc('learning_style')
        .set(data, SetOptions(merge: true));
    if (mounted) Navigator.of(context).pop(true);
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
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _showMotivationInspirePopup = false);
    });
  }

  void _showBarrierInspire() {
    setState(() {
      _showBarrierInspirePopup = true;
      _barrierInspireIndex = (_barrierInspireIndex + 1) % _barrierInspireList.length;
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
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
            Center(
              child: AnimatedOpacity(
                opacity: _showMotivationInspirePopup ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    _motivationInspireList[_motivationInspireIndex],
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          if (_showBarrierInspirePopup)
            Center(
              child: AnimatedOpacity(
                opacity: _showBarrierInspirePopup ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    _barrierInspireList[_barrierInspireIndex],
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                    child: ScaleTransition(
                      scale: _headerAnim,
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
                            LearningStyleHeader(
                              mainBlue: mainBlue,
                              gold: gold,
                              cloudGrey: cloudGrey,
                              onGuide: () => _showGuide(context),
                            ),
                            const SizedBox(height: 18),
                            _AnimatedQuestionCard(
                              completed: (_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty,
                              borderColor: ((_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty) ? gold : cloudGrey,
                              child: LearningStylePreferenceCard(
                                preferenceOptions: _preferenceOptions,
                                selectedPreference: _selectedPreference,
                                showCustomPreferenceInput: _showCustomPreferenceInput,
                                customPreferenceController: _customPreferenceController,
                                customPreference: _customPreference,
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
                                    _selectedPreference = '';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            _AnimatedQuestionCard(
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
                            _AnimatedQuestionCard(
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
                            _AnimatedQuestionCard(
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
                            LearningStyleProgressActions(
                              progress: (cardWidth - 40) * (_completedCount / 4),
                              completedCount: _completedCount,
                              totalCount: 4,
                              mainBlue: mainBlue,
                              accentCoral: accentCoral,
                              cloudGrey: cloudGrey,
                              darkGrey: darkGrey,
                              lightBlue: lightBlue,
                              isSaveEnabled: ((_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty) &&
                                _selectedResources.isNotEmpty &&
                                _motivation.trim().length >= 10 &&
                                _barrier.trim().length >= 10,
                              onSave: _saveData,
                              onBack: () => Navigator.of(context).maybePop(),
                            ),
                          ],
                        ),
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
}

class _AnimatedQuestionCard extends StatelessWidget {
  final Widget child;
  final bool completed;
  final Color borderColor;
  const _AnimatedQuestionCard({required this.child, required this.completed, required this.borderColor});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: _LearningThinkingStyleScreenState.gold.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: borderColor,
              width: completed ? 2 : 1,
            ),
          ),
          child: child,
        ),
        if (completed)
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _LearningThinkingStyleScreenState.successGreen.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.check_circle, color: _LearningThinkingStyleScreenState.successGreen, size: 22),
              ),
            ),
          ),
      ],
    );
  }
} 