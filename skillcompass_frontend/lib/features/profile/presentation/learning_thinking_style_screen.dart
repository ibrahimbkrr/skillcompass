import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/services.dart';

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
                            // Üst Bilgi
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [mainBlue, gold],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.menu_book_rounded, color: gold, size: 36),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Öğrenme Stilinizi Keşfedin',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                          color: mainBlue,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        semanticsLabel: 'Öğrenme Stili Kartı Başlığı',
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Bilişim dünyasında nasıl öğreniyorsunuz? Tercihlerinizi paylaşın, size özel bir öğrenme planı oluşturalım.',
                                        style: GoogleFonts.inter(fontSize: 16, color: cloudGrey),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        semanticsLabel: 'Öğrenme Stili Kartı Açıklama',
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.explore, color: gold, size: 28),
                                  onPressed: () => _showGuide(context),
                                  tooltip: 'Rehber',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Öğrenme yolculuğunuzu şekillendirmek için ilk adımı atın!',
                              style: GoogleFonts.inter(fontSize: 15, color: mainBlue, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 18),
                            // Soru 1: Öğrenme Tercihi
                            _AnimatedQuestionCard(
                              completed: (_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty,
                              borderColor: ((_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty) ? gold : cloudGrey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bilişim konularını öğrenirken en çok hangi yöntemi tercih edersiniz?',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: _responsiveFont(context, 18),
                                      color: mainBlue,
                                    ),
                                    semanticsLabel: 'Öğrenme tercihi başlığı',
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _preferenceOptions.map((option) {
                                      final selected = _selectedPreference == option;
                                      return ChoiceChip(
                                        label: Text(
                                          option,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            color: selected ? Colors.white : mainBlue,
                                          ),
                                        ),
                                        selected: selected,
                                        backgroundColor: Colors.white,
                                        selectedColor: gold,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(color: selected ? gold : cloudGrey, width: 1.5),
                                        ),
                                        onSelected: (val) {
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
                                        avatar: option == 'Diğer' ? const Icon(Icons.add, size: 18, color: gold) : null,
                                      );
                                    }).toList(),
                                  ),
                                  if (_showCustomPreferenceInput) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _customPreferenceController,
                                            maxLength: 30,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontSize: _responsiveFont(context, 15),
                                              color: mainBlue,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Kendi yönteminizi yazın',
                                              counterText: '',
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: const BorderSide(color: cloudGrey, width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: const BorderSide(color: gold, width: 2),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              hintStyle: GoogleFonts.inter(color: lightBlue),
                                            ),
                                            onChanged: (val) => setState(() => _customPreference = val),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: _customPreference.trim().isNotEmpty
                                              ? () {
                                                  setState(() {
                                                    _selectedPreference = '';
                                                  });
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: gold,
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
                                  Text(
                                    'Size en uygun öğrenme yöntemini seçin. Bu, önerilerimizi kişiselleştirecek.',
                                    style: GoogleFonts.inter(
                                      fontSize: _responsiveFont(context, 14),
                                      color: lightBlue,
                                    ),
                                    semanticsLabel: 'Öğrenme tercihi ipucu',
                                  ),
                                ],
                              ),
                            ),
                            // Soru 2: Kaynaklar
                            _AnimatedQuestionCard(
                              completed: _selectedResources.isNotEmpty,
                              borderColor: _selectedResources.isNotEmpty ? gold : cloudGrey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Hangi kaynakları öğrenme sürecinizde sık kullanıyorsunuz?',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: _responsiveFont(context, 18),
                                            color: mainBlue,
                                          ),
                                          semanticsLabel: 'Öğrenme kaynakları başlığı',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_selectedResources.length}/3',
                                        style: GoogleFonts.inter(
                                          fontSize: _responsiveFont(context, 14),
                                          color: gold,
                                        ),
                                        semanticsLabel: 'Seçilen kaynak sayısı',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _resourceOptions.map((option) {
                                      final selected = _selectedResources.contains(option);
                                      return ChoiceChip(
                                        label: Text(
                                          option,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            color: selected ? Colors.white : mainBlue,
                                          ),
                                        ),
                                        selected: selected,
                                        backgroundColor: Colors.white,
                                        selectedColor: gold,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(color: selected ? gold : cloudGrey, width: 1.5),
                                        ),
                                        onSelected: (val) {
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
                                        avatar: option == 'Diğer' ? const Icon(Icons.add, size: 18, color: gold) : null,
                                      );
                                    }).toList(),
                                  ),
                                  if (_showCustomResourceInput) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _customResourceController,
                                            maxLength: 30,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontSize: _responsiveFont(context, 15),
                                              color: mainBlue,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Kendi kaynağınızı yazın',
                                              counterText: '',
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: const BorderSide(color: cloudGrey, width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: const BorderSide(color: gold, width: 2),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              hintStyle: GoogleFonts.inter(color: lightBlue),
                                            ),
                                            onChanged: (val) => setState(() => _customResource = val),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: _customResource.trim().isNotEmpty && _selectedResources.length < 3
                                              ? () {
                                                  setState(() {
                                                    _selectedResources.add(_customResource.trim());
                                                    _customResourceController.clear();
                                                    _customResource = '';
                                                    _showCustomResourceInput = false;
                                                  });
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: gold,
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
                                  Text(
                                    'En fazla 3 kaynağı seçin. Bu, öğrenme önerilerimizi şekillendirecek.',
                                    style: GoogleFonts.inter(
                                      fontSize: _responsiveFont(context, 14),
                                      color: lightBlue,
                                    ),
                                    semanticsLabel: 'Öğrenme kaynakları ipucu',
                                  ),
                                ],
                              ),
                            ),
                            // Soru 3: Motivasyon
                            _AnimatedQuestionCard(
                              completed: _motivation.trim().length >= 10,
                              borderColor: _motivation.trim().length >= 10 ? gold : cloudGrey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Bilişim öğrenirken sizi en çok ne motive eder?',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: _responsiveFont(context, 18),
                                            color: mainBlue,
                                          ),
                                          semanticsLabel: 'Öğrenme motivasyonu başlığı',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _showMotivationInspire,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: mainBlue.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.lightbulb, color: gold, size: 24, semanticLabel: 'İlham önerisi göster'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _motivationController,
                                    maxLength: 100,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontSize: _responsiveFont(context, 16),
                                      color: mainBlue,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Örneğin: Yeni teknolojiler keşfetmek ve projeler geliştirmek.',
                                      counterText: '',
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: cloudGrey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: gold, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      hintStyle: GoogleFonts.inter(color: lightBlue),
                                    ),
                                    onChanged: (val) => setState(() => _motivation = val),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Sizi motive eden şeyleri düşünün. Bu, öğrenme stratejinizi güçlendirecek.',
                                    style: GoogleFonts.inter(
                                      fontSize: _responsiveFont(context, 14),
                                      color: lightBlue,
                                    ),
                                    semanticsLabel: 'Öğrenme motivasyonu ipucu',
                                  ),
                                ],
                              ),
                            ),
                            // Soru 4: Engeller
                            _AnimatedQuestionCard(
                              completed: _barrier.trim().length >= 10,
                              borderColor: _barrier.trim().length >= 10 ? gold : cloudGrey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Öğrenme sürecinizde en büyük engeliniz nedir?',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: _responsiveFont(context, 18),
                                            color: mainBlue,
                                          ),
                                          semanticsLabel: 'Öğrenme engelleri başlığı',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _showBarrierInspire,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: mainBlue.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.lightbulb, color: gold, size: 24, semanticLabel: 'İlham önerisi göster'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _barrierController,
                                    maxLength: 100,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontSize: _responsiveFont(context, 16),
                                      color: mainBlue,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Örneğin: Zaman yönetimi veya karmaşık konular.',
                                      counterText: '',
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: cloudGrey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: gold, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      hintStyle: GoogleFonts.inter(color: lightBlue),
                                    ),
                                    onChanged: (val) => setState(() => _barrier = val),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Engellerinizi dürüstçe paylaşın. Size uygun çözümler önereceğiz.',
                                    style: GoogleFonts.inter(
                                      fontSize: _responsiveFont(context, 14),
                                      color: lightBlue,
                                    ),
                                    semanticsLabel: 'Öğrenme engelleri ipucu',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Progress bar ve butonlar
                            Row(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: cloudGrey,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        height: 7,
                                        width: (cardWidth - 40) * progress,
                                        decoration: BoxDecoration(
                                          color: mainBlue,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(Icons.explore, color: mainBlue, size: 20),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: mainBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '4/7',
                                    style: GoogleFonts.inter(
                                      fontSize: _responsiveFont(context, 14),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: ((_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty) &&
                                        _selectedResources.isNotEmpty &&
                                        _motivation.trim().length >= 10 &&
                                        _barrier.trim().length >= 10
                                    ? _saveData
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ((_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty) &&
                                          _selectedResources.isNotEmpty &&
                                          _motivation.trim().length >= 10 &&
                                          _barrier.trim().length >= 10
                                      ? accentCoral
                                      : cloudGrey,
                                  foregroundColor: ((_selectedPreference != null && _selectedPreference!.isNotEmpty) || _customPreference.isNotEmpty) &&
                                          _selectedResources.isNotEmpty &&
                                          _motivation.trim().length >= 10 &&
                                          _barrier.trim().length >= 10
                                      ? Colors.white
                                      : darkGrey,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _responsiveFont(context, 18),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('Kaydet ve İlerle'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Öğrenme stilinizi tanımlayarak yolculuğunuzu güçlendirin.',
                              style: GoogleFonts.inter(
                                fontSize: _responsiveFont(context, 14),
                                color: lightBlue,
                              ),
                              semanticsLabel: 'Kart tamamlama ipucu',
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: lightBlue,
                                  size: 24,
                                ),
                                onPressed: () => Navigator.of(context).maybePop(),
                                tooltip: 'Geri',
                              ),
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