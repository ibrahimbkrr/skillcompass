import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';

// --- StepperStep Model ---
class _StepperStep {
  final String title;
  final String description;
  final String info;
  final Widget Function(BuildContext) contentBuilder;
  final bool isRequired;
  final bool Function() validator;
  _StepperStep({
    required this.title,
    required this.description,
    required this.info,
    required this.contentBuilder,
    required this.isRequired,
    required this.validator,
  });
}

// --- StepperBody Widget ---
class StepperBody extends StatelessWidget {
  final _StepperStep step;
  final int stepIndex;
  final int totalSteps;
  final bool isSaving;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onSave;
  const StepperBody({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.isSaving,
    this.onBack,
    this.onNext,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSummaryStep = step.title == 'Özet ve Onay';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text('${stepIndex + 1}', style: TextStyle(color: theme.colorScheme.onPrimary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                tooltip: 'Açıklama',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(step.title),
                      content: Text(step.info),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kapat'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 20),
          step.contentBuilder(context),
          const SizedBox(height: 32),
          if (!isSummaryStep)
            Row(
              children: [
                if (onBack != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    label: const Text('Geri'),
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(minimumSize: const Size(100, 48)),
                  ),
                if (onBack != null) const SizedBox(width: 12),
                if (onNext != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    label: const Text('İleri'),
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
                  ),
              ],
            ),
          if (isSummaryStep)
            _buildSummaryStepButton(theme),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSummaryStepButton(ThemeData theme) {
    return isSaving
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Onayla ve Kaydet'),
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
  }
}

// --- Step Card Info Model ---
class _StepCardInfo {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  _StepCardInfo({required this.icon, required this.title, required this.description, required this.color});
}

class LearningThinkingStyleScreen extends StatefulWidget {
  const LearningThinkingStyleScreen({super.key});

  @override
  State<LearningThinkingStyleScreen> createState() =>
      _LearningThinkingStyleScreenState();
}

class _LearningThinkingStyleScreenState
    extends State<LearningThinkingStyleScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- State Değişkenleri ---
  User? _currentUser;
  bool _isLoadingPage = true;
  bool _isSaving = false;
  String _loadingError = '';
  int _currentStep = 0;

  // Form Alanları
  String? _selectedLearningStyle;
  List<String> _selectedLearningMethods = [];
  List<String> _selectedInfoSources = [];
  double _analyticalThinkingRating = 5.0;
  String? _learningNote;

  // --- Options ---
  final List<String> _learningStyleOptions = [
    'Görsel (Görerek, şemalar ve grafiklerle)',
    'İşitsel (Dinleyerek, tartışarak, sesli anlatımla)',
    'Kinestetik (Yaparak, hareketle, uygulamalı)',
    'Okuma/Yazma (Yazarak, okuyarak, not alarak)',
    'Sosyal (Grup içinde, iş birliğiyle, tartışarak)',
    'Bireysel (Kendi başına, bağımsız çalışarak)',
    'Analitik (Mantıksal, adım adım, problem çözerek)',
    'Bütüncül (Genel resmi görerek, bağlantılar kurarak)',
  ];
  final List<String> _learningMethodsOptions = [
    'Proje Tabanlı Öğrenme (Gerçek projeler, uygulama)',
    'Mikro Öğrenme (Kısa, odaklı içerikler)',
    'Video Tabanlı Eğitim (YouTube, Udemy, interaktif videolar)',
    'Yapay Zeka Destekli Öğrenme (ChatGPT, AI araçları)',
    'Oyunlaştırma (Gamification, ödül ve seviye sistemi)',
    'Topluluk & Mentorluk (Discord, Slack, birebir mentorluk)',
    'Podcast & Sesli İçerik',
    'Blog & Makale Okuma',
    'Online Kurslar & Sertifika Programları',
    'Kodlama Platformları (LeetCode, HackerRank, Codewars)',
    'Simülasyon & Sanal Laboratuvarlar',
    'Canlı Webinar & Atölyeler',
    'Diğer',
  ];
  final List<String> _infoSourcesOptions = [
    'Resmi Dokümantasyonlar',
    'Stack Overflow / Q&A Platformları',
    'Video Platformları (YouTube vb.)',
    'Teknik Bloglar / Makaleler (Medium vb.)',
    'Yapay Zeka Araçları (ChatGPT vb.)',
    'Online Kurslar / Eğitim İçerikleri',
    'Kitaplar / E-kitaplar',
    'Forumlar / Topluluklar (Discord, Reddit vb.)',
    'Mentor / Deneyimli Kişiler',
    'GitHub / Açık Kaynak Projeler',
    'Teknik Web Siteleri (MDN, W3Schools vb.)',
    'Diğer',
  ];

  late final List<_StepperStep> _stepperSteps = [
    _StepperStep(
      title: 'Öğrenme Tarzı',
      description: 'Kendine en uygun olan bilimsel öğrenme stilini seç. Bu seçim, sana en verimli içerik ve yol haritası sunmamıza yardımcı olur.',
      info: 'Örneğin: "Görsel (Görerek, şemalarla)", "İşitsel (Dinleyerek)", "Kinestetik (Yaparak)" gibi. Öğrenme stilin, bilgiyi nasıl en iyi özümsediğini gösterir.',
      contentBuilder: (context) => _buildStatusSelector(
        context,
        _learningStyleOptions,
        _selectedLearningStyle,
        (value) => setState(() => _selectedLearningStyle = value),
      ),
      isRequired: true,
      validator: () => _selectedLearningStyle != null,
    ),
    _StepperStep(
      title: 'Öğrenme Yöntemleri',
      description: 'Sana en uygun ve motive edici modern öğrenme yöntemlerini seç. (Birden fazla seçebilirsin)',
      info: 'Örneğin: "Proje tabanlı öğrenme", "Yapay zeka destekli", "Topluluk/mentorluk" gibi. Yöntemlerin, öğrenme sürecini daha etkili ve sürdürülebilir kılar.',
      contentBuilder: (context) => _buildMultiSelector(
        context,
        _learningMethodsOptions,
        _selectedLearningMethods,
        (value) {
          setState(() {
            if (_selectedLearningMethods.contains(value)) {
              _selectedLearningMethods.remove(value);
            } else {
              _selectedLearningMethods.add(value);
            }
          });
        },
      ),
      isRequired: true,
      validator: () => _selectedLearningMethods.isNotEmpty,
    ),
    _StepperStep(
      title: 'Bilgi Kaynakları',
      description: 'Öğrenme sürecinde en çok başvurduğun bilgi kaynaklarını seç. (Birden fazla seçebilirsin)',
      info: 'Örneğin: "Resmi Dokümantasyonlar", "YouTube", "ChatGPT" gibi.',
      contentBuilder: (context) => _buildMultiSelector(
        context,
        _infoSourcesOptions,
        _selectedInfoSources,
        (value) {
          setState(() {
            if (_selectedInfoSources.contains(value)) {
              _selectedInfoSources.remove(value);
            } else {
              _selectedInfoSources.add(value);
            }
          });
        },
      ),
      isRequired: true,
      validator: () => _selectedInfoSources.isNotEmpty,
    ),
    _StepperStep(
      title: 'Analitik Düşünme Eğilimi',
      description: 'Analitik düşünme ve problem çözme becerini 1-10 arasında değerlendir. (1: Düşük, 10: Çok Yüksek)',
      info: 'Bu bilgi, sana uygun zorluk seviyesindeki içerikleri belirlememize yardımcı olur.',
      contentBuilder: (context) => Slider(
        value: _analyticalThinkingRating,
        min: 1,
        max: 10,
        divisions: 9,
        label: _analyticalThinkingRating.round().toString(),
        onChanged: (value) => setState(() => _analyticalThinkingRating = value),
      ),
      isRequired: true,
      validator: () => _analyticalThinkingRating >= 1 && _analyticalThinkingRating <= 10,
    ),
    _StepperStep(
      title: 'Kısa Not (İsteğe Bağlı)',
      description: 'Öğrenme sürecinle ilgili paylaşmak istediğin kısa bir notun var mı?',
      info: 'Örneğin: "En iyi grup çalışmasında öğreniyorum.", "Kısa videoları tercih ediyorum." gibi.',
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: _learningNote,
          decoration: InputDecoration(
            labelText: 'Kısa Not (isteğe bağlı)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.short_text_rounded),
          ),
          maxLines: 2,
          onChanged: (value) => setState(() => _learningNote = value),
        ),
      ),
      isRequired: false,
      validator: () => true,
    ),
    _StepperStep(
      title: 'Özet ve Onay',
      description: 'Tüm verdiğin bilgileri gözden geçir ve onayla.',
      info: 'Bilgilerini kontrol et. Kaydettikten sonra profilinde güncellenmiş olarak göreceksin.',
      contentBuilder: (context) => _buildSummaryCard(context),
      isRequired: true,
      validator: () => true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _loadSavedData();
    } else {
      setState(() {
        _isLoadingPage = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showFeedback('Önce giriş yapmalısınız.', isError: true);
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        }
      });
    }
  }

  Future<void> _loadSavedData() async {
    if (_currentUser == null) return;
    setState(() {
      _isLoadingPage = true;
      _loadingError = '';
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection('users')
              .doc(_currentUser!.uid)
              .collection('profile_data')
              .doc('learning_thinking_style_v2')
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (mounted) {
          setState(() {
            _selectedLearningStyle = data['learning_style'];
            _selectedLearningMethods = List<String>.from(data['learning_methods'] ?? []);
            _selectedInfoSources = List<String>.from(data['info_sources'] ?? []);
            _analyticalThinkingRating = (data['analytical_thinking'] ?? 5.0).toDouble();
            _learningNote = data['learning_note'];
          });
        }
      }
    } catch (e) {
      print("HATA: learning_thinking_style_v2 verisi yüklenemedi: $e");
      _loadingError = 'Kaydedilmiş veriler yüklenirken bir sorun oluştu.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPage = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    if (_currentUser == null) return;
    setState(() => _isSaving = true);
    try {
      final data = {
        'learning_style': _selectedLearningStyle,
        'learning_methods': _selectedLearningMethods,
        'info_sources': _selectedInfoSources,
        'analytical_thinking': _analyticalThinkingRating,
        'learning_note': _learningNote,
        'updated_at': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('profile_data')
          .doc('learning_thinking_style_v2')
          .set(data, SetOptions(merge: true));
      if (mounted) {
        _showFeedback('Öğrenme stili başarıyla kaydedildi!', isError: false);
      }
    } catch (e) {
      _showFeedback('Bilgiler kaydedilirken bir hata oluştu.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showFeedback(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenme ve Düşünme Stili'),
        elevation: 1,
      ),
      body: _isLoadingPage
          ? const Center(child: CircularProgressIndicator())
          : _buildStepper(theme),
    );
  }

  Widget _buildStepper(ThemeData theme) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _buildDynamicInfoCard(theme, _currentStep, key: ValueKey(_currentStep)),
        ),
        LinearProgressIndicator(
          value: (_currentStep + 1) / _stepperSteps.length,
          minHeight: 6,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: StepperBody(
              key: ValueKey(_currentStep),
              step: _stepperSteps[_currentStep],
              stepIndex: _currentStep,
              totalSteps: _stepperSteps.length,
              isSaving: _isSaving,
              onBack: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
              onNext: _currentStep < _stepperSteps.length - 1
                  ? () {
                      if (_stepperSteps[_currentStep].validator()) {
                        setState(() => _currentStep++);
                      } else {
                        _showFeedback('Lütfen gerekli alanları doldurun.', isError: true);
                      }
                    }
                  : null,
              onSave: _currentStep == _stepperSteps.length - 1 && !_isSaving
                  ? _saveToFirestore
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector(
    BuildContext context,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((option) {
          final isSelected = selectedValue == option;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: RadioListTile<String>(
              title: Text(
                option,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
              value: option,
              groupValue: selectedValue,
              onChanged: !_isSaving ? onChanged : null,
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }).toList(),
        if (selectedValue == null && _isSaving)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Lütfen bir seçim yapın',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMultiSelector(
    BuildContext context,
    List<String> options,
    List<String> selectedValues,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (_isSaving) return;
                onChanged(option);
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              elevation: isSelected ? 2 : 0,
            );
          }).toList(),
        ),
        if (selectedValues.isEmpty && _isSaving)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Lütfen en az bir seçim yapın',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Özet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSummaryRow('Öğrenme Tarzı', _selectedLearningStyle),
            _buildSummaryRow('Öğrenme Yöntemleri', _selectedLearningMethods.join(', ')),
            _buildSummaryRow('Bilgi Kaynakları', _selectedInfoSources.join(', ')),
            _buildSummaryRow('Analitik Düşünme', _analyticalThinkingRating.toString()),
            _buildSummaryRow('Kısa Not', _learningNote),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text((value == null || value.isEmpty) ? '-' : value),
          ),
        ],
      ),
    );
  }

  // --- Dynamic Info Card ---
  Widget _buildDynamicInfoCard(ThemeData theme, int step, {Key? key}) {
    final List<_StepCardInfo> cardInfos = [
      _StepCardInfo(
        icon: Icons.psychology_alt_rounded,
        title: 'Öğrenme Tarzı',
        description: 'Kendine en uygun olan bilimsel öğrenme stilini seç. Bu seçim, sana en verimli içerik ve yol haritası sunmamıza yardımcı olur.',
        color: theme.colorScheme.primary,
      ),
      _StepCardInfo(
        icon: Icons.menu_book_rounded,
        title: 'Öğrenme Yöntemleri',
        description: 'Sana en uygun ve motive edici modern öğrenme yöntemlerini seç. (Birden fazla seçebilirsin)',
        color: theme.colorScheme.secondary,
      ),
      _StepCardInfo(
        icon: Icons.source_rounded,
        title: 'Bilgi Kaynakları',
        description: 'Öğrenme sürecinde en çok başvurduğun bilgi kaynaklarını seç. (Birden fazla seçebilirsin)',
        color: theme.colorScheme.tertiary,
      ),
      _StepCardInfo(
        icon: Icons.analytics_rounded,
        title: 'Analitik Düşünme',
        description: 'Analitik düşünme ve problem çözme becerini 1-10 arasında değerlendir.',
        color: theme.colorScheme.primary,
      ),
      _StepCardInfo(
        icon: Icons.short_text_rounded,
        title: 'Kısa Not',
        description: 'Öğrenme sürecinle ilgili paylaşmak istediğin kısa bir notun var mı?',
        color: theme.colorScheme.secondary,
      ),
      _StepCardInfo(
        icon: Icons.check_circle_outline,
        title: 'Özet ve Onay',
        description: 'Tüm verdiğin bilgileri gözden geçir ve onayla.',
        color: theme.colorScheme.primary,
      ),
    ];
    final info = cardInfos[step.clamp(0, cardInfos.length - 1)];
    return Card(
      key: key,
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: info.color.withOpacity(0.08),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                info.icon,
                color: info.color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: info.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
