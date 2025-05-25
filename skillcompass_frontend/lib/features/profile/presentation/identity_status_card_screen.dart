import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../../profile/services/profile_service.dart';
import 'widgets/common/profile_progress_header.dart';
import 'widgets/common/animated_question_card.dart';
import 'widgets/identity_story_card.dart';
import 'widgets/identity_motivation_card.dart';
import 'widgets/identity_impact_card.dart';
import 'widgets/identity_clarity_card.dart';
import 'widgets/identity_status_actions.dart';
import 'dart:async';

class IdentityStatusCardScreen extends StatefulWidget {
  const IdentityStatusCardScreen({super.key});

  @override
  State<IdentityStatusCardScreen> createState() => _IdentityStatusCardScreenState();
}

class _IdentityStatusCardScreenState extends State<IdentityStatusCardScreen> with SingleTickerProviderStateMixin {
  // --- Theme Colors ---
  static const Color mainBlue = Color(0xFF2A4B7C);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color bgSoftWhite = Color(0xFFF8FAFC);
  static const Color bgGradientEnd = Color(0xFFE6EAF0);
  static const Color cloudGrey = Color(0xFFA0AEC0);
  static const Color lightBlue = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF38A169);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color accentBlue = Color(0xFF3D5AFE);
  static const Color accentBlueDark = Color(0xFF1741B6);
  static const Color bgStart = Color(0xFFFFFFFF);
  static const Color bgEnd = Color(0xFFF0F4FA);
  static const Color lightGrey = Color(0xFFB0B0B0);
  static const Color green = Color(0xFF4CAF50);

  // --- Form State ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _customMotivationController = TextEditingController();
  String? _selectedImpact;
  List<String> _selectedMotivations = [];
  String? _customMotivation;
  double _clarity = 50;
  bool _showCustomMotivation = false;
  bool _isSaving = false;
  bool _showSuccess = false;
  String? _errorText;
  int _completedCount = 0;
  bool _showInspire = false;
  String? _inspireText;
  Timer? _inspireTimer;

  // --- Animation ---
  late AnimationController _animController;
  late Animation<double> _waveAnim;

  // --- Data ---
  final List<String> _inspireExamples = [
    'Veri hikayeleriyle dünyayı anlamlandıran bir analist.',
    'Siber tehditlere karşı dijital kaleler inşa eden bir güvenlik uzmanı.',
    'Yapay zekayla geleceği şekillendiren bir mühendis.',
    'Kullanıcı odaklı mobil uygulamalar geliştiren bir Flutter tutkunu.',
    'Topluma fayda sağlayan projeler üreten bir geliştirici.',
  ];
  final List<String> _motivationOptions = [
    'Yenilik ve Teknoloji',
    'Problem Çözme',
    'Kullanıcı Etkisi',
    'Liderlik ve Etki',
    'Öğrenme ve Gelişim',
    'Finansal Başarı',
    'Toplumsal Katkı',
    'Diğer',
  ];
  final List<String> _impactOptions = [
    'Ürün Geliştirme',
    'Veri ve Analitik',
    'Güvenlik ve Altyapı',
    'Tasarım ve Deneyim',
    'Strateji ve Yönetim',
    'Eğitim ve Mentorluk',
    'İnovasyon ve Araştırma',
  ];
  final Map<String, IconData> _impactIcons = {
    'Ürün Geliştirme': Icons.code,
    'Veri ve Analitik': Icons.bar_chart,
    'Güvenlik ve Altyapı': Icons.security,
    'Tasarım ve Deneyim': Icons.design_services,
    'Strateji ve Yönetim': Icons.leaderboard,
    'Eğitim ve Mentorluk': Icons.school,
    'İnovasyon ve Araştırma': Icons.lightbulb,
  };

  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _waveAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
    _fetchExistingData();
  }

  Future<void> _fetchExistingData() async {
    try {
      final data = await _profileService.loadIdentityStatus();
      if (data != null) {
        setState(() {
          _storyController.text = data['story'] ?? '';
          _selectedMotivations = List<String>.from(data['motivations'] ?? []);
          _customMotivationController.text = data['custom_motivation'] ?? '';
          _showCustomMotivation = data['custom_motivation'] != null && data['custom_motivation'].toString().isNotEmpty;
          _selectedImpact = data['impact'];
          _clarity = (data['clarity'] ?? 50).toDouble();
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'Profil verisi yüklenemedi: $e';
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _storyController.dispose();
    _customMotivationController.dispose();
    _inspireTimer?.cancel();
    _inspireTimer = null;
    super.dispose();
  }

  bool get _isFormValid {
    return _storyController.text.trim().length >= 10 &&
        (_selectedMotivations.isNotEmpty || (_showCustomMotivation && _customMotivationController.text.trim().isNotEmpty)) &&
        _selectedImpact != null;
  }

  void _updateCompletedCount() {
    int count = 0;
    if (_storyController.text.trim().length >= 10) count++;
    if (_selectedMotivations.isNotEmpty) count++;
    if (_selectedImpact != null) count++;
    count++; // Slider her zaman tamamlanmış sayılır
    setState(() => _completedCount = count);
  }

  void _showInspirePopup() {
    setState(() {
      _inspireText = (_inspireExamples..shuffle()).first;
      _showInspire = true;
    });
    _inspireTimer?.cancel();
    _inspireTimer = Timer(const Duration(milliseconds: 5000), () {
      if (mounted) setState(() => _showInspire = false);
    });
  }

  Future<void> _saveData() async {
    if (!_isFormValid) {
      setState(() => _errorText = 'Lütfen zorunlu alanları doldurun.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      final List<String> motivationsToSave = List.from(_selectedMotivations);
      String? customMotivation;
      if (_showCustomMotivation && _customMotivationController.text.trim().isNotEmpty) {
        customMotivation = _customMotivationController.text.trim();
        motivationsToSave.remove('Diğer');
      }
      final data = {
        'story': _storyController.text.trim(),
        'motivations': motivationsToSave,
        if (customMotivation != null) 'custom_motivation': customMotivation,
        'impact': _selectedImpact,
        'clarity': _clarity.round(),
      };
      await _profileService.saveIdentityStatus(data);
      setState(() {
        _isSaving = false;
        _showSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorText = 'Kayıt hatası: $e';
      });
    }
  }

  String get _clarityText {
    if (_clarity <= 25) return 'Henüz keşif aşamasındayım, rehberliğe ihtiyacım var.';
    if (_clarity <= 50) return 'Bazı fikirlerim var ama netleştirmem lazım.';
    if (_clarity <= 75) return 'Oldukça netim, ama yönlendirme faydalı olur.';
    return 'Tamamen netim, hedeflerime ulaşmak için plan istiyorum.';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width < 370 ? 6 : 12;
    final double cardPadding = size.width < 370 ? 10 : 20;
    final double maxCardWidth = 520;
    final double cardWidth = size.width - 2 * horizontalPadding < maxCardWidth
        ? size.width - 2 * horizontalPadding
        : maxCardWidth;
    final double borderRadius = 10;
    final double elevation = 6;
    int totalSteps = 4;
    int completedSteps = 0;
    if (_storyController.text.trim().length >= 10) completedSteps++;
    if (_selectedMotivations.isNotEmpty) completedSteps++;
    if (_selectedImpact != null) completedSteps++;
    completedSteps++; // Slider her zaman tamamlanmış sayılır
    final double progress = completedSteps / totalSteps;
    _updateCompletedCount();

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
          if (_showInspire && _inspireText != null)
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _showInspire && _inspireText != null
                    ? Container(
                        key: ValueKey(_inspireText),
                        constraints: const BoxConstraints(maxWidth: 340),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: accentBlue.withOpacity(0.97),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: accentBlue.withOpacity(0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          _inspireText!,
                          style: GoogleFonts.inter(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w600, height: 1.35),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                  child: ScaleTransition(
                    scale: _waveAnim,
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileProgressHeader(
                              completedSteps: completedSteps,
                              totalSteps: totalSteps,
                              progress: progress,
                              mainColor: mainBlue,
                              accentColor: accentCoral,
                              cardWidth: cardWidth,
                              icon: Icons.explore,
                              title: 'Kimsiniz ve Neredesiniz?',
                              description: 'Bilişim dünyasındaki yerinizi tarif edin. Kendinizi nasıl görüyorsunuz, neyi temsil ediyorsunuz? Bu, kariyer yolculuğunuzun başlangıç noktası.',
                              subtitle: 'Hikayenizi anlatın, yolculuğunuzu birlikte şekillendirelim!',
                            ),
                            const SizedBox(height: 18),
                            AnimatedQuestionCard(
                              completed: _storyController.text.trim().length >= 10,
                              borderColor: _storyController.text.trim().length >= 10 ? mainBlue : cloudGrey,
                              child: IdentityStoryCard(
                                storyController: _storyController,
                                showInspire: _showInspire,
                                inspireText: _inspireText,
                                onInspireTap: _showInspirePopup,
                                onChanged: (_) {
                                  setState(() {});
                                  _updateCompletedCount();
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            AnimatedQuestionCard(
                              completed: _selectedMotivations.isNotEmpty || (_showCustomMotivation && _customMotivationController.text.trim().isNotEmpty),
                              borderColor: (_selectedMotivations.isNotEmpty || (_showCustomMotivation && _customMotivationController.text.trim().isNotEmpty)) ? mainBlue : cloudGrey,
                              child: IdentityMotivationCard(
                                motivationOptions: _motivationOptions,
                                selectedMotivations: _selectedMotivations,
                                showCustomMotivation: _showCustomMotivation,
                                customMotivationController: _customMotivationController,
                                onMotivationSelected: (motivation, val) {
                                  setState(() {
                                    if (motivation == 'Diğer') {
                                      _showCustomMotivation = val;
                                      if (!val) {
                                        _customMotivationController.clear();
                                        _selectedMotivations.removeWhere((m) => !_motivationOptions.contains(m));
                                      }
                                    } else {
                                      if (val && _selectedMotivations.length < 3) {
                                        _selectedMotivations.add(motivation);
                                      } else if (!val) {
                                        _selectedMotivations.remove(motivation);
                                      }
                                    }
                                    _updateCompletedCount();
                                  });
                                },
                                onCustomMotivationChanged: (_) {
                                  setState(() {}); // Sadece textbox'ı güncelle, listeye ekleme
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            AnimatedQuestionCard(
                              completed: _selectedImpact != null,
                              borderColor: _selectedImpact != null ? mainBlue : cloudGrey,
                              child: IdentityImpactCard(
                                impactOptions: _impactOptions,
                                impactIcons: _impactIcons,
                                selectedImpact: _selectedImpact,
                                onChanged: (val) => setState(() {
                                  _selectedImpact = val;
                                  _updateCompletedCount();
                                }),
                              ),
                            ),
                            const SizedBox(height: 14),
                            AnimatedQuestionCard(
                              completed: true,
                              borderColor: mainBlue,
                              child: IdentityClarityCard(
                                clarity: _clarity,
                                onChanged: (val) => setState(() => _clarity = val),
                                clarityText: _clarityText,
                              ),
                            ),
                            const SizedBox(height: 18),
                            IdentityStatusActions(
                              isFormValid: _isFormValid,
                              isSaving: _isSaving,
                              showSuccess: _showSuccess,
                              errorText: _errorText,
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
        title: Text('Kimlik Durumu Kartı', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: mainBlue)),
        content: const Text(
          'Bu kart, sizi tanıyarak size özel bir yol haritası çizmeye başlıyor. Dürüst ve özgün cevaplar verin!\n\nÖrnek: "Kullanıcı odaklı mobil uygulamalar geliştiren bir Flutter tutkunu."',
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
                color: _IdentityStatusCardScreenState.lightBlue.withOpacity(0.10),
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
                      color: _IdentityStatusCardScreenState.successGreen.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.check_circle, color: _IdentityStatusCardScreenState.successGreen, size: 22),
              ),
            ),
          ),
      ],
    );
  }
} 