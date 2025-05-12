import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';

class CareerVisionScreen extends StatefulWidget {
  const CareerVisionScreen({super.key});

  @override
  State<CareerVisionScreen> createState() => _CareerVisionScreenState();
}

class _CareerVisionScreenState extends State<CareerVisionScreen> {
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
  String? _selectedOneYearGoal;
  String? _oneYearGoalDetail;
  String? _selectedFiveYearVision;
  String? _fiveYearVisionDetail;
  List<String> _selectedMotivationSources = [];
  String? _profileTagline;

  // --- Options ---
  final List<String> _oneYearGoalOptions = [
    'Yeni bir teknoloji öğrenmek',
    'İlk işimi/stajımı bulmak',
    'Bir projede liderlik yapmak',
    'Açık kaynak katkısı yapmak',
    'Kariyerimde terfi almak',
    'Kendi girişimimi başlatmak',
    'Diğer',
  ];
  final List<String> _fiveYearVisionOptions = [
    'Alanında uzmanlaşmak',
    'Uluslararası bir şirkette çalışmak',
    'Kendi şirketini kurmak',
    'Teknik lider olmak',
    'Global projelerde yer almak',
    'Akademik kariyer yapmak',
    'Diğer',
  ];
  final List<String> _motivationSourcesOptions = [
    'Öğrenme & Gelişim',
    'Problem Çözme',
    'Maddi Güvence',
    'Kariyerde Yükselme',
    'Etki Yaratma',
    'Esneklik',
    'Yaratıcılık',
    'Teknolojiye İlgi',
    'Diğer',
  ];

  late final List<_StepperStep> _stepperSteps = [
    _StepperStep(
      title: '1 Yıllık Hedef',
      description: 'Önümüzdeki 1 yıl içinde ulaşmak istediğin ana kariyer hedefini seç. Bu hedef, kısa vadeli planlarını ve odak noktalarını belirlemede yardımcı olur.',
      info: 'Kısa vadede ulaşmak istediğin ana hedefini seçerek, odaklanacağın alanı netleştir. Bu, gelişim planlarını daha verimli yapmanı sağlar.',
      contentBuilder: (context) => _buildStatusSelector(
        context,
        _oneYearGoalOptions,
        _selectedOneYearGoal,
        (value) => setState(() => _selectedOneYearGoal = value),
      ),
      isRequired: true,
      validator: () => _selectedOneYearGoal != null,
    ),
    _StepperStep(
      title: '1 Yıllık Hedef Detayı',
      description: 'Bu hedefle ilgili spesifik detayları paylaşmak ister misin? (İsteğe bağlı)',
      info: 'Örneğin: "Yeni bir teknoloji öğrenmek istiyorum: Flutter.", "Açık kaynak projelere katkı sağlamak istiyorum." gibi.',
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: _oneYearGoalDetail,
          decoration: _inputDecoration(context, 'Bu hedefle ilgili detaylar (isteğe bağlı)', Icons.edit_note_rounded),
          maxLines: 2,
          onChanged: (value) => setState(() => _oneYearGoalDetail = value),
        ),
      ),
      isRequired: false,
      validator: () => true,
    ),
    _StepperStep(
      title: '5 Yıllık Vizyon',
      description: 'Uzun vadede, 5 yıl sonra kariyerinde nerede olmak istediğini seç. Bu vizyon, büyük resme odaklanmanı ve motivasyonunu artırmanı sağlar.',
      info: 'Büyük resmi düşün! 5 yıl sonra kendini nerede görmek istiyorsun? Uzun vadeli vizyonun, motivasyonunu ve yol haritanı şekillendirir.',
      contentBuilder: (context) => _buildStatusSelector(
        context,
        _fiveYearVisionOptions,
        _selectedFiveYearVision,
        (value) => setState(() => _selectedFiveYearVision = value),
      ),
      isRequired: true,
      validator: () => _selectedFiveYearVision != null,
    ),
    _StepperStep(
      title: '5 Yıllık Vizyon Detayı',
      description: 'Bu vizyonla ilgili detayları paylaşmak ister misin? (İsteğe bağlı)',
      info: 'Örneğin: "Global projelerde yer almak istiyorum.", "Teknik lider olmak istiyorum." gibi.',
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: _fiveYearVisionDetail,
          decoration: _inputDecoration(context, 'Bu vizyonla ilgili detaylar (isteğe bağlı)', Icons.edit_note_rounded),
          maxLines: 3,
          onChanged: (value) => setState(() => _fiveYearVisionDetail = value),
        ),
      ),
      isRequired: false,
      validator: () => true,
    ),
    _StepperStep(
      title: 'Motivasyon Kaynakları',
      description: 'Kariyerinde seni en çok motive eden kaynakları seç. (Birden fazla seçebilirsin)',
      info: 'Seni motive eden kaynakları seçerek, SkillCompass\'ın sana daha iyi destek olmasını sağlayabilir.',
      contentBuilder: (context) => _buildMultiSelector(
        context,
        _motivationSourcesOptions,
        _selectedMotivationSources,
        (value) {
          setState(() {
            if (_selectedMotivationSources.contains(value)) {
              _selectedMotivationSources.remove(value);
            } else {
              _selectedMotivationSources.add(value);
            }
          });
        },
      ),
      isRequired: true,
      validator: () => _selectedMotivationSources.isNotEmpty,
    ),
    _StepperStep(
      title: 'Kısa Profil Sloganı',
      description: 'Kendini 1 cümleyle tanımlar mısın? (İsteğe bağlı)',
      info: 'Örneğin: "Yenilikçi ve çözüm odaklı bir yazılım geliştiriciyim." gibi LinkedIn tarzı kısa bir cümle yazabilirsin.',
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: _profileTagline,
          decoration: _inputDecoration(context, 'Profil Sloganın (isteğe bağlı)', Icons.short_text_rounded),
          maxLines: 2,
          onChanged: (value) => setState(() => _profileTagline = value),
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
              .doc('career_vision_v5')
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (mounted) {
          setState(() {
            _selectedOneYearGoal = data['one_year_goal'];
            _oneYearGoalDetail = data['one_year_goal_detail'];
            _selectedFiveYearVision = data['five_year_vision'];
            _fiveYearVisionDetail = data['five_year_vision_detail'];
            _selectedMotivationSources = List<String>.from(data['motivation_sources'] ?? []);
            _profileTagline = data['profile_tagline'];
          });
        }
      }
    } catch (e) {
      print("HATA: career_vision_v5 verisi yüklenemedi: $e");
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
    setState(() => _isSaving = true);
    try {
      if (_currentUser == null) return;
      final data = {
        'one_year_goal': _selectedOneYearGoal,
        'one_year_goal_detail': _oneYearGoalDetail,
        'five_year_vision': _selectedFiveYearVision,
        'five_year_vision_detail': _fiveYearVisionDetail,
        'motivation_sources': _selectedMotivationSources,
        'profile_tagline': _profileTagline,
        'updated_at': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('profile_data')
          .doc('career_vision_v5')
          .set(data, SetOptions(merge: true));
      if (mounted) {
        _showFeedback('Kariyer vizyonu başarıyla kaydedildi!', isError: false);
      }
    } catch (e) {
      _showFeedback('Bilgiler kaydedilirken bir hata oluştu.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kariyer Vizyonu'),
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
            _buildSummaryRow('1 Yıllık Hedef', _selectedOneYearGoal),
            _buildSummaryRow('1 Yıllık Hedef Detayı', _oneYearGoalDetail),
            _buildSummaryRow('5 Yıllık Vizyon', _selectedFiveYearVision),
            _buildSummaryRow('5 Yıllık Vizyon Detayı', _fiveYearVisionDetail),
            _buildSummaryRow('Motivasyon Kaynakları', _selectedMotivationSources.join(', ')),
            _buildSummaryRow('Profil Sloganı', _profileTagline),
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
        icon: Icons.looks_one_rounded,
        title: '1 Yıllık Hedef',
        description: 'Önümüzdeki 1 yıl içinde ulaşmak istediğin ana kariyer hedefini seç.',
        color: theme.colorScheme.primary,
      ),
      _StepCardInfo(
        icon: Icons.edit_note_rounded,
        title: '1 Yıllık Hedef Detayı',
        description: 'Bu hedefle ilgili spesifik detayları paylaşmak ister misin?',
        color: theme.colorScheme.secondary,
      ),
      _StepCardInfo(
        icon: Icons.looks_5_rounded,
        title: '5 Yıllık Vizyon',
        description: '5 yıl sonra kariyerinde nerede olmak istediğini seç.',
        color: theme.colorScheme.tertiary,
      ),
      _StepCardInfo(
        icon: Icons.edit_note_rounded,
        title: '5 Yıllık Vizyon Detayı',
        description: 'Bu vizyonla ilgili detayları paylaşmak ister misin?',
        color: theme.colorScheme.secondary,
      ),
      _StepCardInfo(
        icon: Icons.favorite_rounded,
        title: 'Motivasyon Kaynakları',
        description: 'Kariyerinde seni en çok motive eden kaynakları seç.',
        color: theme.colorScheme.primary,
      ),
      _StepCardInfo(
        icon: Icons.short_text_rounded,
        title: 'Kısa Profil Sloganı',
        description: 'Kendini 1 cümleyle tanımlar mısın?',
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

  // --- Feedback Helper ---
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

  // --- Input Decoration Helper ---
  InputDecoration _inputDecoration(BuildContext context, String label, IconData? prefixIcon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: label.contains("Açıklayın") || label.contains("detaylar")
          ? 'Detayları buraya yazın...'
          : null,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 20, color: theme.colorScheme.onSurfaceVariant)
          : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14.0,
        vertical: 16.0,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }
}

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
