import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/services/profile_service.dart';
import 'widgets/common/themed_card_header.dart';
import 'widgets/common/themed_back_button.dart';
import 'widgets/common/animated_question_card.dart';
import 'widgets/common/inspiration_popup.dart';
import 'widgets/common/profile_progress_header.dart';
import 'dart:async';

class TechnicalProfileCardScreen extends StatefulWidget {
  const TechnicalProfileCardScreen({super.key});

  @override
  State<TechnicalProfileCardScreen> createState() => _TechnicalProfileCardScreenState();
}

class _TechnicalProfileCardScreenState extends State<TechnicalProfileCardScreen> with SingleTickerProviderStateMixin {
  // --- Theme Colors ---
  static const Color mainBlue = Color(0xFF2A4B7C); // Deniz Mavisi
  static const Color accentCoral = Color(0xFFFF6B6B); // Mercan Kırmızısı
  static const Color bgSoftWhite = Color(0xFFF8FAFC);
  static const Color bgGradientEnd = Color(0xFFE6EAF0);
  static const Color cloudGrey = Color(0xFFA0AEC0);
  static const Color lightBlue = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF38A169);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color neonTurquoise = Color(0xFF00D4B4); // Neon Turkuaz
  static const Color gold = Color(0xFFFFD700); // Gold

  // --- Animation ---
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  // --- Soru 1 State ---
  final Map<String, List<String>> _skillCategories = {
    "Programlama Dilleri": ["Python", "JavaScript", "Dart", "Java", "C++", "Go", "Rust", "Diğer"],
    "Frameworkler ve Kütüphaneler": ["Flutter", "React", "Django", "TensorFlow", "Node.js", "Diğer"],
    "Veritabanları ve Araçlar": ["Firebase", "MongoDB", "SQL", "PostgreSQL", "Docker", "Kubernetes", "Diğer"],
    "Tasarım ve Prototipleme": ["Figma", "Adobe XD", "Sketch", "Diğer"],
    "Diğer Yetkinlikler": ["API geliştirme", "CI/CD", "Bulut Bilişim (AWS, Azure)", "Siber Güvenlik", "Diğer"],
  };
  final Set<String> _expandedCategories = {};
  final List<String> _selectedSkills = [];
  String _customSkill = '';
  final TextEditingController _customSkillController = TextEditingController();
  bool _showCustomSkillInput = false;

  // --- Soru 2 State ---
  final TextEditingController _highlightSkillController = TextEditingController();
  String _highlightSkill = '';
  final List<String> _highlightExamples = [
    "Python ile veri analizi.",
    "React ile dinamik web arayüzleri.",
    "AWS ile bulut altyapısı kurma.",
    "Flutter ile mobil uygulama geliştirme.",
  ];

  // --- Soru 3 State ---
  final List<String> _learningApproaches = [
    "Uygulamalı Projeler (Kod yazarak, proje geliştirerek öğrenirim)",
    "Video Eğitimler (Udemy, YouTube gibi platformlarla öğrenirim)",
    "Dokümantasyon ve Makaleler (Resmi dokümanlar, bloglar okurum)",
    "Mentorluk ve Ekip Çalışması (Deneyimli kişilerden öğrenirim)",
    "Online Topluluklar (Stack Overflow, Discord gibi platformlarda öğrenirim)",
    "Yapılandırılmış Kurslar (Coursera, edX gibi sertifikalı programlar)",
  ];
  String? _selectedLearningApproach;

  // --- Soru 4 State ---
  double _confidence = 50;

  // --- Progress ---
  int get _completedCount {
    int count = 0;
    if (_selectedSkills.isNotEmpty) count++;
    if (_highlightSkill.trim().length >= 10) count++;
    if (_selectedLearningApproach != null) count++;
    count++; // Slider her zaman tamamlanmış sayılır
    return count;
  }

  final ProfileService _profileService = ProfileService();

  // --- Soru 2 İlham Popup State ---
  bool _showInspire = false;
  String? _inspireText;
  int _inspireIndex = 0;
  Timer? _inspireTimer;

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
    try {
      final data = await _profileService.loadTechnicalProfile();
      if (data != null) {
        setState(() {
          _selectedSkills.clear();
          _selectedSkills.addAll(List<String>.from(data['skills'] ?? []));
          _highlightSkill = data['highlight_skill'] ?? '';
          _highlightSkillController.text = _highlightSkill;
          _selectedLearningApproach = data['learning_approach'];
          _confidence = (data['confidence'] ?? 50).toDouble();
        });
      }
    } catch (e) {
      // Hata yönetimi
      // setState(() { _errorText = 'Teknik profil verisi yüklenemedi: $e'; });
    }
  }

  Future<void> _saveData() async {
    final data = {
      'skills': _selectedSkills,
      'highlight_skill': _highlightSkill.trim(),
      'learning_approach': _selectedLearningApproach,
      'confidence': _confidence.round(),
    };
    try {
      await _profileService.saveTechnicalProfile(data);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      // Hata yönetimi
      // setState(() { _errorText = 'Kayıt hatası: $e'; });
    }
  }

  void _showHighlightInspirationPopup() {
    if (_highlightExamples.isEmpty) return;
    _inspireTimer?.cancel();
    setState(() {
      _inspireText = (_highlightExamples..shuffle()).first;
      _showInspire = true;
    });
    _inspireTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showInspire = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _customSkillController.dispose();
    _highlightSkillController.dispose();
    _inspireTimer?.cancel();
    _inspireTimer = null;
    super.dispose();
  }

  String get _confidenceText {
    if (_confidence <= 25) return "Henüz yolun başındayım, temel becerilere ihtiyacım var.";
    if (_confidence <= 50) return "Bazı becerilerim var, ama daha çok pratik yapmalıyım.";
    if (_confidence <= 75) return "Kendime güveniyorum, ama daha fazla uzmanlaşabilirim.";
    return "Becerilerimde çok iyiyim, ileri düzey projelere hazırım.";
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
    final int totalSteps = 4;
    final double progress = _completedCount / totalSteps;

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
                            icon: Icons.engineering,
                            title: 'Teknik Profil',
                            description: 'Teknik becerilerinizi, öne çıkan yeteneklerinizi ve öğrenme yaklaşımınızı paylaşın.',
                          ),
                          const SizedBox(height: 18),
                          AnimatedQuestionCard(
                            completed: _selectedSkills.isNotEmpty,
                            borderColor: _selectedSkills.isNotEmpty ? neonTurquoise : cloudGrey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text('Hangi becerilere ve araçlara hakimsiniz?',
                                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${_selectedSkills.length}/10',
                                      style: GoogleFonts.inter(fontSize: 14, color: neonTurquoise)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Kategoriler ve alt beceriler
                                Column(
                                  children: _skillCategories.entries.map((entry) {
                                    final category = entry.key;
                                    final skills = entry.value;
                                    final expanded = _expandedCategories.contains(category);
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (expanded) {
                                                _expandedCategories.remove(category);
                                              } else {
                                                _expandedCategories.add(category);
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Icon(expanded ? Icons.expand_less : Icons.expand_more, color: mainBlue),
                                              const SizedBox(width: 4),
                                              Text(category, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16, color: mainBlue)),
                                            ],
                                          ),
                                        ),
                                        AnimatedCrossFade(
                                          firstChild: const SizedBox.shrink(),
                                          secondChild: Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: skills.map((skill) {
                                              if (skill == 'Diğer') {
                                                return ActionChip(
                                                  label: Text('Yeni Beceri Ekle', style: GoogleFonts.inter(color: neonTurquoise, fontWeight: FontWeight.w500)),
                                                  avatar: Icon(Icons.add, color: neonTurquoise, size: 18),
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    side: BorderSide(color: neonTurquoise, width: 1.2),
                                                  ),
                                                  onPressed: () {
                                                    setState(() => _showCustomSkillInput = true);
                                                  },
                                                );
                                              }
                                              final selected = _selectedSkills.contains(skill);
                                              return ChoiceChip(
                                                label: Text(skill, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: selected ? Colors.white : mainBlue)),
                                                selected: selected,
                                                backgroundColor: Colors.white,
                                                selectedColor: neonTurquoise,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  side: BorderSide(color: selected ? neonTurquoise : cloudGrey, width: 1.5),
                                                ),
                                                onSelected: (val) {
                                                  setState(() {
                                                    if (val && _selectedSkills.length < 10) {
                                                      _selectedSkills.add(skill);
                                                    } else if (!val) {
                                                      _selectedSkills.remove(skill);
                                                    }
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ),
                                          crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                          duration: const Duration(milliseconds: 300),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                    );
                                  }).toList(),
                                ),
                                if (_showCustomSkillInput) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _customSkillController,
                                          maxLength: 30,
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15, color: mainBlue),
                                          decoration: InputDecoration(
                                            hintText: 'Kendi becerinizi yazın',
                                            counterText: '',
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: cloudGrey, width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: neonTurquoise, width: 2),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            hintStyle: GoogleFonts.inter(color: lightBlue),
                                          ),
                                          onChanged: (val) => setState(() => _customSkill = val),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: _customSkill.trim().isNotEmpty && _selectedSkills.length < 10
                                            ? () {
                                                setState(() {
                                                  _selectedSkills.add(_customSkill.trim());
                                                  _customSkillController.clear();
                                                  _customSkill = '';
                                                  _showCustomSkillInput = false;
                                                });
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: neonTurquoise,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        ),
                                        child: const Text('Ekle'),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 10),
                                // Yetenek Bulutu
                                if (_selectedSkills.isNotEmpty)
                                  Wrap(
                                    spacing: 0,
                                    runSpacing: 0,
                                    children: _selectedSkills.map((skill) {
                                      final angle = (skill.hashCode % 7 - 3) * 0.07;
                                      return Transform.rotate(
                                        angle: angle,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          child: Chip(
                                            label: Text(skill, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                                            backgroundColor: neonTurquoise,
                                            elevation: 2,
                                            deleteIcon: Icon(Icons.close, color: Colors.white, size: 18),
                                            onDeleted: () {
                                              setState(() => _selectedSkills.remove(skill));
                                            },
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                const SizedBox(height: 6),
                                Text('Mevcut becerilerinizi seçin veya ekleyin. Ne kadar detaylı olursanız, önerilerimiz o kadar isabetli olur.',
                                  style: GoogleFonts.inter(fontSize: 14, color: lightBlue)),
                              ],
                            ),
                          ),
                          // --- Soru 2: Hangi Beceri Sizi Parlatıyor? ---
                          FadeTransition(
                            opacity: _scaleAnim,
                            child: AnimatedQuestionCard(
                              completed: _highlightSkill.trim().length >= 10,
                              borderColor: _highlightSkill.trim().length >= 10 ? neonTurquoise : cloudGrey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text('En çok hangi becerinizle öne çıkıyorsunuz?',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue)),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _showHighlightInspirationPopup,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: mainBlue.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.auto_awesome, color: neonTurquoise, size: 20, semanticLabel: 'İlham önerisi göster'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _highlightSkillController,
                                    maxLength: 100,
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16, color: mainBlue),
                                    decoration: InputDecoration(
                                      hintText: 'Örneğin: Flutter ile mobil uygulama geliştirme.',
                                      counterText: '',
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: cloudGrey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: accentCoral, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      hintStyle: GoogleFonts.inter(color: lightBlue),
                                    ),
                                    onChanged: (val) => setState(() => _highlightSkill = val),
                                  ),
                                  // İlham popup'ı kimlik durumu kartındaki gibi, TextField'ın hemen altında
                                  if (_showInspire && _inspireText != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: AnimatedOpacity(
                                        opacity: _showInspire ? 1 : 0,
                                        duration: const Duration(milliseconds: 300),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: mainBlue.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(_inspireText!, style: GoogleFonts.inter(fontSize: 14)),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Text('Sizi tanımlayan veya en gurur duyduğunuz beceriyi tarif edin. Bu, sizi neyin farklı kıldığını gösterir.',
                                    style: GoogleFonts.inter(fontSize: 14, color: lightBlue)),
                                ],
                              ),
                            ),
                          ),
                          // --- Soru 3: Teknik Öğrenme Yaklaşımınız Nedir? ---
                          FadeTransition(
                            opacity: _scaleAnim,
                            child: AnimatedQuestionCard(
                              completed: _selectedLearningApproach != null,
                              borderColor: _selectedLearningApproach != null ? neonTurquoise : cloudGrey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Yeni becerileri nasıl öğreniyorsunuz?',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue)),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: (_selectedLearningApproach != null && _learningApproaches.contains(_selectedLearningApproach)) ? _selectedLearningApproach : null,
                                    items: [
                                      const DropdownMenuItem<String>(value: null, child: Text('Seçiniz', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      ..._learningApproaches.map((e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: mainBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      )),
                                    ],
                                    onChanged: (val) => setState(() => _selectedLearningApproach = val),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: cloudGrey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: mainBlue, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    validator: (v) => v == null ? 'Lütfen bir öğrenme yöntemi seçin.' : null,
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Size en uygun öğrenme yöntemini seçin. Bu, size özel kaynak önerileri sunmamızı yardımcı olacak.',
                                    style: GoogleFonts.inter(fontSize: 14, color: lightBlue)),
                                ],
                              ),
                            ),
                          ),
                          // --- Soru 4: Teknik Güven Seviyeniz Nedir? ---
                          FadeTransition(
                            opacity: _scaleAnim,
                            child: AnimatedQuestionCard(
                              completed: true,
                              borderColor: neonTurquoise,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Becerilerinize ne kadar güveniyorsunuz?',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue)),
                                  const SizedBox(height: 8),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: neonTurquoise,
                                      inactiveTrackColor: cloudGrey,
                                      thumbColor: accentCoral,
                                      overlayColor: accentCoral.withOpacity(0.2),
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                    ),
                                    child: Slider(
                                      value: _confidence,
                                      min: 0,
                                      max: 100,
                                      divisions: 100,
                                      onChanged: (val) => setState(() => _confidence = val),
                                    ),
                                  ),
                                  Text(_confidenceText, style: GoogleFonts.inter(fontSize: 14, color: darkGrey)),
                                  const SizedBox(height: 6),
                                  Text('Dürüstçe değerlendirin. Bu, size uygun zorluk seviyesinde öneriler sunmamızı sağlayacak.',
                                    style: GoogleFonts.inter(fontSize: 14, color: lightBlue)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _selectedSkills.isNotEmpty && _highlightSkill.trim().length >= 10 && _selectedLearningApproach != null
                                  ? _saveData
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedSkills.isNotEmpty && _highlightSkill.trim().length >= 10 && _selectedLearningApproach != null ? accentCoral : cloudGrey,
                                foregroundColor: _selectedSkills.isNotEmpty && _highlightSkill.trim().length >= 10 && _selectedLearningApproach != null ? Colors.white : darkGrey,
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
        title: Text('Teknik Profil Kartı', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: mainBlue)),
        content: const Text(
          'Becerilerinizi dürüstçe değerlendirin. Mevcut yetkinlikleriniz ve öğrenme tarzınız, kariyer planınızı şekillendirecek.',
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
                color: _TechnicalProfileCardScreenState.neonTurquoise.withOpacity(0.10),
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
                      color: _TechnicalProfileCardScreenState.successGreen.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.check_circle, color: _TechnicalProfileCardScreenState.successGreen, size: 22),
              ),
            ),
          ),
      ],
    );
  }
} 