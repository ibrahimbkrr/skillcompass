import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('user_profile')
        .doc('identity_status_v2')
        .get();
    if (doc.exists) {
      final data = doc.data() ?? {};
      setState(() {
        _storyController.text = data['story'] ?? '';
        _selectedMotivations = List<String>.from(data['motivations'] ?? []);
        _customMotivationController.text = data['custom_motivation'] ?? '';
        _showCustomMotivation = data['custom_motivation'] != null && data['custom_motivation'].toString().isNotEmpty;
        _selectedImpact = data['impact'];
        _clarity = (data['clarity'] ?? 50).toDouble();
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _storyController.dispose();
    _customMotivationController.dispose();
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
    if (_selectedMotivations.isNotEmpty || (_showCustomMotivation && _customMotivationController.text.trim().isNotEmpty)) count++;
    if (_selectedImpact != null) count++;
    count++; // Slider her zaman tamamlanmış sayılır
    setState(() => _completedCount = count);
  }

  void _showInspirePopup() {
    setState(() {
      _inspireText = (_inspireExamples..shuffle()).first;
      _showInspire = true;
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isSaving = false;
          _errorText = 'Kullanıcı oturumu bulunamadı.';
        });
        return;
      }
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_profile')
          .doc('identity_status_v2')
          .set(data, SetOptions(merge: true));
      setState(() {
        _isSaving = false;
        _showSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.of(context).pop(true); // Sonraki karta geçiş için
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
    if (_selectedMotivations.isNotEmpty || (_showCustomMotivation && _customMotivationController.text.trim().isNotEmpty)) completedSteps++;
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
              child: AnimatedOpacity(
                opacity: _showInspire ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: accentBlue.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentBlue.withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    _inspireText!,
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                            // Progress bar
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
                                    '$completedSteps/$totalSteps',
                                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            // Simge + Başlık + Açıklama + Rehber
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [mainBlue, accentCoral],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.explore, color: Colors.white, size: 36),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Icon(Icons.navigation, color: accentCoral, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Kimsiniz ve Neredesiniz?',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                            color: mainBlue,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Bilişim dünyasındaki yerinizi tarif edin. Kendinizi nasıl görüyorsunuz, neyi temsil ediyorsunuz? Bu, kariyer yolculuğunuzun başlangıç noktası.',
                                        style: GoogleFonts.inter(fontSize: 16, color: darkGrey),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.tips_and_updates_rounded, color: mainBlue, size: 24),
                                  onPressed: () => _showGuide(context),
                                  tooltip: 'Rehber',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text('Hikayenizi anlatın, yolculuğunuzu birlikte şekillendirelim!',
                              style: GoogleFonts.inter(fontSize: 15, color: mainBlue, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 18),
                            // Soru 1: Bilişim Hikayesi
                            _AnimatedQuestionCard(
                              completed: _storyController.text.trim().length >= 10,
                              borderColor: _storyController.text.trim().length >= 10 ? mainBlue : cloudGrey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text('Kendinizi bir cümleyle nasıl anlatırsınız?',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue)),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _showInspirePopup,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: mainBlue.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.auto_awesome, color: mainBlue, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _storyController,
                                    maxLength: 100,
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16, color: mainBlue),
                                    decoration: InputDecoration(
                                      hintText: 'Örneğin: Kullanıcı odaklı mobil uygulamalar geliştiren bir Flutter tutkunu.',
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
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (_) {
                                      setState(() {});
                                      _updateCompletedCount();
                                    },
                                    autofocus: false,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (v) => v == null || v.trim().length < 10 ? 'Lütfen kendinizi tarif edin.' : null,
                                  ),
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
                                          child: Text(_inspireText!, style: GoogleFonts.inter(fontSize: 14, color: mainBlue)),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Text('Unvanınızdan ziyade tutkunuzu ve vizyonunuzu düşünün. Sizi ne tanımlar?',
                                    style: GoogleFonts.inter(fontSize: 14, color: darkGrey)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Soru 2: Motivasyon
                            _AnimatedQuestionCard(
                              completed: _selectedMotivations.isNotEmpty || (_showCustomMotivation && _customMotivationController.text.trim().isNotEmpty),
                              borderColor: (_selectedMotivations.isNotEmpty || (_showCustomMotivation && _customMotivationController.text.trim().isNotEmpty)) ? mainBlue : cloudGrey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text('Sizi motive eden nedir?',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${_selectedMotivations.length + (_showCustomMotivation && _customMotivationController.text.trim().isNotEmpty ? 1 : 0)}/3',
                                        style: GoogleFonts.inter(fontSize: 14, color: accentBlue)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _motivationOptions.map((motivation) {
                                      final selected = _selectedMotivations.contains(motivation);
                                      return ChoiceChip(
                                        label: Text(motivation, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: selected ? Colors.white : mainBlue)),
                                        selected: selected,
                                        backgroundColor: Colors.white,
                                        selectedColor: accentCoral,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(color: selected ? accentCoral : cloudGrey, width: 1.5),
                                        ),
                                        onSelected: (val) {
                                          setState(() {
                                            if (motivation == 'Diğer') {
                                              _showCustomMotivation = val;
                                              if (!val) _customMotivationController.clear();
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
                                        avatar: motivation == 'Diğer' ? const Icon(Icons.add, size: 18, color: accentCoral) : null,
                                      );
                                    }).toList(),
                                  ),
                                  if (_showCustomMotivation) ...[
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _customMotivationController,
                                      maxLength: 30,
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15, color: mainBlue),
                                      decoration: InputDecoration(
                                        hintText: 'Kendi motivasyonunuzu yazın',
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
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                      onChanged: (_) {
                                        setState(() {});
                                        _updateCompletedCount();
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text('Sizi sabah yataktan kaldıran şey nedir? Birden fazla seçebilirsiniz.',
                                    style: GoogleFonts.inter(fontSize: 14, color: darkGrey)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Soru 3: Etki Alanı
                            _AnimatedQuestionCard(
                              completed: _selectedImpact != null,
                              borderColor: _selectedImpact != null ? mainBlue : cloudGrey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('En büyük etkinizi nerede yaratıyorsunuz?',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue)),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: _selectedImpact,
                                    items: [
                                      const DropdownMenuItem<String>(value: null, child: Text('Seçiniz', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      ..._impactOptions.map((e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Row(
                                          children: [
                                            Icon(_impactIcons[e], color: mainBlue, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text(e, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: mainBlue), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ],
                                        ),
                                      )),
                                    ],
                                    onChanged: (val) => setState(() {
                                      _selectedImpact = val;
                                      _updateCompletedCount();
                                    }),
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
                                    validator: (v) => v == null ? 'Lütfen bir etki alanı seçin.' : null,
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Şu anda veya gelecekte en çok katkı sağladığınız alanı seçin.',
                                    style: GoogleFonts.inter(fontSize: 14, color: darkGrey)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Soru 4: Netlik Ölçümü
                            _AnimatedQuestionCard(
                              completed: true,
                              borderColor: mainBlue,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Kariyer kimliğiniz ne kadar net?',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue)),
                                  const SizedBox(height: 8),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: mainBlue,
                                      inactiveTrackColor: cloudGrey,
                                      thumbColor: accentCoral,
                                      overlayColor: accentCoral.withOpacity(0.2),
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                    ),
                                    child: Slider(
                                      value: _clarity,
                                      min: 0,
                                      max: 100,
                                      divisions: 100,
                                      onChanged: (val) => setState(() => _clarity = val),
                                    ),
                                  ),
                                  Text(_clarityText, style: GoogleFonts.inter(fontSize: 14, color: darkGrey)),
                                  const SizedBox(height: 6),
                                  Text('Ne kadar net olduğunuzu dürüstçe değerlendirin. Bu, size en uygun önerileri sunmamızı sağlayacak.',
                                    style: GoogleFonts.inter(fontSize: 14, color: darkGrey)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (_errorText != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(_errorText!, style: GoogleFonts.inter(color: Colors.red, fontSize: 14)),
                              ),
                            // Kaydet ve İlerle Butonu
                            AnimatedScale(
                              scale: _isSaving ? 0.95 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isFormValid && !_isSaving ? _saveData : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFormValid ? accentCoral : cloudGrey,
                                    foregroundColor: _isFormValid ? Colors.white : darkGrey,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                                    elevation: 0,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                        )
                                      : _showSuccess
                                          ? Icon(Icons.check_circle, color: successGreen, size: 28)
                                          : const Text('Kaydet ve İlerle'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Tüm sorulara yanıt vererek en iyi sonucu alın.', style: GoogleFonts.inter(fontSize: 14, color: lightBlue)),
                            const SizedBox(height: 8),
                            // Geri Butonu
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: lightBlue, size: 24),
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