import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/services/profile_service.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'widgets/common/themed_card_header.dart';
import 'widgets/common/themed_back_button.dart';
import 'widgets/common/animated_question_card.dart';
import 'widgets/common/inspiration_popup.dart';
import 'widgets/common/profile_progress_header.dart';
import 'dart:async';

double _responsiveFont(BuildContext context, num base) {
  final scale = MediaQuery.textScalerOf(context).scale(1.0);
  return (base * scale).clamp(16, 20).toDouble();
}

class CareerVisionCardScreen extends StatefulWidget {
  const CareerVisionCardScreen({super.key});

  @override
  State<CareerVisionCardScreen> createState() => _CareerVisionCardScreenState();
}

class _CareerVisionCardScreenState extends State<CareerVisionCardScreen> with SingleTickerProviderStateMixin {
  // --- Theme Colors ---
  static const Color mainBlue = Color(0xFF2A4B7C);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color bgSoftWhite = Color(0xFFF8FAFC);
  static const Color bgGradientEnd = Color(0xFFE6EAF0);
  static const Color cloudGrey = Color(0xFFA0AEC0);
  static const Color lightBlue = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF38A169);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color gold = Color(0xFFD4A017); // Altın Sarısı

  // --- Animation ---
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  // --- Soru 1 ve 2 State ---
  bool _showInspireShortTerm = false;
  String? _inspireTextShortTerm;
  Timer? _inspireTimerShortTerm;
  bool _showInspireLongTerm = false;
  String? _inspireTextLongTerm;
  Timer? _inspireTimerLongTerm;
  final List<String> _shortTermExamples = [
    "Veri analizi projelerinde lider bir analist.",
    "Bir açık kaynak projesine katkıda bulunan geliştirici.",
    "UI/UX tasarımıyla bir ürünün kullanıcı deneyimini iyileştiren tasarımcı.",
    "Flutter ile 2 mobil uygulama yayınlamış bir geliştirici.",
  ];
  final List<String> _longTermExamples = [
    "Yapay zeka projelerinde küresel çapta tanınan bir mühendis.",
    "Kendi mobil uygulamasını milyonlarca kullanıcıya ulaştıran bir girişimci.",
    "Siber güvenlikte bir ekibi yöneten uzman.",
    "Bir teknoloji startup'ında teknik lider.",
  ];

  // --- Soru 3 State ---
  final List<String> _priorityOptions = [
    "Beceri Geliştirme",
    "Networking",
    "Proje Deneyimi",
    "Liderlik ve Yönetim",
    "Girişimcilik",
    "Sertifikasyon ve Eğitim",
    "İş-Yaşam Dengesi",
    "Diğer"
  ];
  final List<String> _selectedPriorities = [];
  String _customPriority = '';
  final TextEditingController _customPriorityController = TextEditingController();
  bool _showCustomPriorityInput = false;

  // --- Soru 4 State ---
  double _progress = 50;

  // --- Progress ---
  int get _completedCount {
    int count = 0;
    if (_shortTermExamples.isNotEmpty) count++;
    if (_longTermExamples.isNotEmpty) count++;
    if (_selectedPriorities.isNotEmpty) count++;
    count++; // Slider her zaman tamamlanmış sayılır
    return count;
  }

  final LayerLink _shortTermLink = LayerLink();
  OverlayEntry? _shortTermOverlay;

  // İlham overlay için ek state
  final LayerLink _longTermLink = LayerLink();
  OverlayEntry? _longTermOverlay;
  int _currentLongTermIndex = 0;

  final ProfileService _profileService = ProfileService();

  void _showInspireShortTermPopup() {
    setState(() {
      _inspireTextShortTerm = (_shortTermExamples..shuffle()).first;
      _showInspireShortTerm = true;
    });
    _inspireTimerShortTerm?.cancel();
    _inspireTimerShortTerm = Timer(const Duration(milliseconds: 5000), () {
      if (mounted) setState(() => _showInspireShortTerm = false);
    });
  }

  void _showInspireLongTermPopup() {
    setState(() {
      _inspireTextLongTerm = (_longTermExamples..shuffle()).first;
      _showInspireLongTerm = true;
    });
    _inspireTimerLongTerm?.cancel();
    _inspireTimerLongTerm = Timer(const Duration(milliseconds: 5000), () {
      if (mounted) setState(() => _showInspireLongTerm = false);
    });
  }

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final data = await _profileService.loadCareerVision();
      if (data != null) {
        setState(() {
          _selectedPriorities.clear();
          _selectedPriorities.addAll(List<String>.from(data['priorities'] ?? []));
          _progress = (data['progress'] ?? 50).toDouble();
        });
      }
    } catch (e) {
      // Hata yönetimi
    }
  }

  Future<void> _saveData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final data = {
      'priorities': _selectedPriorities,
      'progress': _progress.round(),
    };
    try {
      await _profileService.saveCareerVision(data);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      // Hata yönetimi
    }
  }

  String get _progressText {
    if (_progress <= 25) return "Yolun başındayım, rehber bir plana ihtiyacım var.";
    if (_progress <= 50) return "Bazı adımlar attım, ama daha yolum var.";
    if (_progress <= 75) return "Hedeflerime yaklaşıyorum, stratejik önerilere açığım.";
    return "Hedeflerime çok yakınım, son adımları planlıyorum.";
  }

  @override
  void dispose() {
    _animController.dispose();
    _customPriorityController.dispose();
    _inspireTimerShortTerm?.cancel();
    _inspireTimerShortTerm = null;
    _inspireTimerLongTerm?.cancel();
    _inspireTimerLongTerm = null;
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
    final double progress = 4 / 7; // %57

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
                            accentColor: accentCoral,
                            cardWidth: cardWidth,
                            icon: Icons.flag_rounded,
                            title: 'Kariyer Vizyonu',
                            description: 'Kısa ve uzun vadeli kariyer hedeflerinizi, motivasyonunuzu ve vizyonunuzu paylaşın.',
                          ),
                          const SizedBox(height: 18),
                          AnimatedQuestionCard(
                            completed: _shortTermExamples.isNotEmpty,
                            borderColor: _shortTermExamples.isNotEmpty ? gold : cloudGrey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1 yıl içinde hangi rolde veya konumda olmak istiyorsunuz?',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: _responsiveFont(context, 18),
                                    color: mainBlue,
                                  ),
                                  semanticsLabel: 'Kısa vadeli kariyer hedefi başlığı',
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CompositedTransformTarget(
                                        link: _shortTermLink,
                                        child: TextField(
                                          maxLength: 100,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontSize: _responsiveFont(context, 16),
                                            color: mainBlue,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "Örneğin: Flutter ile 2 mobil uygulama yayınlamış bir geliştirici.",
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
                                          onChanged: (val) => setState(() => _shortTermExamples.first = val),
                                          textInputAction: TextInputAction.next,
                                          autofocus: false,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _showInspireShortTermPopup,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: mainBlue.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.lightbulb,
                                          color: gold,
                                          size: 24,
                                          semanticLabel: 'İlham önerisi göster',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_showInspireShortTerm && _inspireTextShortTerm != null)
                                  AnimatedOpacity(
                                    opacity: _showInspireShortTerm ? 1 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: mainBlue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _inspireTextShortTerm!,
                                        style: GoogleFonts.inter(fontSize: 14, color: mainBlue, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  '1 yıl içinde ulaşılabilir bir hedef düşünün. Rol, proje veya bir başarı olabilir.',
                                  style: GoogleFonts.inter(
                                    fontSize: _responsiveFont(context, 14),
                                    color: lightBlue,
                                  ),
                                  semanticsLabel: 'Kısa vadeli hedef ipucu',
                                ),
                              ],
                            ),
                          ),
                          AnimatedQuestionCard(
                            completed: _longTermExamples.isNotEmpty,
                            borderColor: _longTermExamples.isNotEmpty ? gold : cloudGrey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '5 yıl içinde kendinizi nerede hayal ediyorsunuz?',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: _responsiveFont(context, 18),
                                          color: mainBlue,
                                        ),
                                        semanticsLabel: 'Uzun vadeli kariyer hedefi başlığı',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _showInspireLongTermPopup,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: mainBlue.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.lightbulb,
                                          color: gold,
                                          size: 24,
                                          semanticLabel: 'İlham önerisi göster',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  maxLength: 100,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: _responsiveFont(context, 16),
                                    color: mainBlue,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Örneğin: Bir teknoloji startup'ında teknik lider.",
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
                                  onChanged: (val) => setState(() => _longTermExamples.first = val),
                                ),
                                const SizedBox(height: 8),
                                if (_showInspireLongTerm && _inspireTextLongTerm != null)
                                  AnimatedOpacity(
                                    opacity: _showInspireLongTerm ? 1 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: mainBlue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _inspireTextLongTerm!,
                                        style: GoogleFonts.inter(fontSize: 14, color: mainBlue, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  'Büyük düşünün! 5 yıl içinde ulaşmak istediğiniz vizyonu tarif edin.',
                                  style: GoogleFonts.inter(
                                    fontSize: _responsiveFont(context, 14),
                                    color: lightBlue,
                                  ),
                                  semanticsLabel: 'Uzun vadeli hedef ipucu',
                                ),
                              ],
                            ),
                          ),
                          AnimatedQuestionCard(
                            completed: _selectedPriorities.isNotEmpty,
                            borderColor: _selectedPriorities.isNotEmpty ? gold : cloudGrey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Hedeflerinize ulaşmak için neler ön planda?',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: _responsiveFont(context, 18),
                                          color: mainBlue,
                                        ),
                                        semanticsLabel: 'Öncelikler başlığı',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedPriorities.length}/3',
                                      style: GoogleFonts.inter(
                                        fontSize: _responsiveFont(context, 14),
                                        color: gold,
                                      ),
                                      semanticsLabel: 'Seçilen öncelik sayısı',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _priorityOptions.map((priority) {
                                    final selected = _selectedPriorities.contains(priority);
                                    return ChoiceChip(
                                      label: Text(
                                        priority,
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
                                          if (priority == 'Diğer') {
                                            _showCustomPriorityInput = val;
                                            if (!val) _customPriorityController.clear();
                                          } else {
                                            if (val && _selectedPriorities.length < 3) {
                                              _selectedPriorities.add(priority);
                                            } else if (!val) {
                                              _selectedPriorities.remove(priority);
                                            }
                                          }
                                        });
                                      },
                                      avatar: priority == 'Diğer'
                                          ? const Icon(Icons.add, size: 18, color: gold)
                                          : null,
                                    );
                                  }).toList(),
                                ),
                                if (_showCustomPriorityInput) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _customPriorityController,
                                          maxLength: 30,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontSize: _responsiveFont(context, 15),
                                            color: mainBlue,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Kendi önceliğinizi yazın',
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
                                          onChanged: (val) => setState(() => _customPriority = val),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: _customPriority.trim().isNotEmpty && _selectedPriorities.length < 3
                                            ? () {
                                                setState(() {
                                                  _selectedPriorities.add(_customPriority.trim());
                                                  _customPriorityController.clear();
                                                  _customPriority = '';
                                                  _showCustomPriorityInput = false;
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
                                if (_selectedPriorities.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _selectedPriorities.map((priority) {
                                      return Container(
                                        constraints: BoxConstraints(maxWidth: 200),
                                        child: Chip(
                                          label: Text(
                                            priority,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          backgroundColor: gold,
                                          elevation: 2,
                                          deleteIcon: Icon(Icons.close, color: Colors.white, size: 18),
                                          onDeleted: () {
                                            setState(() => _selectedPriorities.remove(priority));
                                          },
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  'Hedeflerinize ulaşmak için en önemli 3 alanı seçin. Size özel bir yol haritası çizeceğiz.',
                                  style: GoogleFonts.inter(
                                    fontSize: _responsiveFont(context, 14),
                                    color: lightBlue,
                                  ),
                                  semanticsLabel: 'Önemli alanlar başlığı',
                                ),
                              ],
                            ),
                          ),
                          AnimatedQuestionCard(
                            completed: true,
                            borderColor: gold,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hedeflerinize ulaşmaya ne kadar yakınsınız?',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: _responsiveFont(context, 18),
                                    color: mainBlue,
                                  ),
                                  semanticsLabel: 'Hedeflere yakınlık başlığı',
                                ),
                                const SizedBox(height: 8),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: mainBlue,
                                    inactiveTrackColor: cloudGrey,
                                    thumbColor: gold,
                                    overlayColor: gold.withOpacity(0.2),
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                  ),
                                  child: Slider(
                                    value: _progress,
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    onChanged: (val) => setState(() => _progress = val),
                                    label: 'Hedeflere yakınlık: ${_progress.round()}%',
                                  ),
                                ),
                                Text(
                                  _progressText,
                                  style: GoogleFonts.inter(
                                    fontSize: _responsiveFont(context, 14),
                                    color: darkGrey,
                                  ),
                                  semanticsLabel: 'Hedeflere yakınlık metni',
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Mevcut durumunuzu dürüstçe değerlendirin. Bu, size en uygun adımları önermemizi sağlayacak.',
                                  style: GoogleFonts.inter(
                                    fontSize: _responsiveFont(context, 14),
                                    color: lightBlue,
                                  ),
                                  semanticsLabel: 'Mevcut durum ipucu',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _selectedPriorities.isNotEmpty
                                  ? _saveData
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedPriorities.isNotEmpty ? accentCoral : cloudGrey,
                                foregroundColor: _selectedPriorities.isNotEmpty ? Colors.white : darkGrey,
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
                            'Hedeflerinizi netleştirerek kariyer planınızı güçlendirin.',
                            style: GoogleFonts.inter(
                              fontSize: _responsiveFont(context, 14),
                              color: lightBlue,
                            ),
                            semanticsLabel: 'Kariyer planı güçlendirme ipucu',
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

  void _showGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Kariyer Vizyonu Kartı',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: mainBlue),
        ),
        content: const Text(
          'Bu kart, geleceğinizi planlamanıza yardımcı olur. Hedeflerinizi netleştirin ve nasıl ulaşacağınızı düşünün.',
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