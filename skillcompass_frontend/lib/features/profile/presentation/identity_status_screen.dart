import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/core/widgets/custom_button.dart';
import 'package:skillcompass_frontend/core/widgets/custom_snackbar.dart';

class IdentityStatusScreen extends StatefulWidget {
  const IdentityStatusScreen({super.key});

  @override
  State<IdentityStatusScreen> createState() => _IdentityStatusScreenState();
}

class _IdentityStatusScreenState extends State<IdentityStatusScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  int _currentStep = 0;

  // --- State ---
  String? _selectedCurrentStatus;
  String? _selectedEducationLevel;
  List<String> _selectedInterestAreas = [];
  String? _profileTagline;

  // --- Options ---
  final List<String> _currentStatusOptions = [
    'Bilişim alanını keşfediyorum / Yeni başlıyorum',
    'Öğrenme aşamasındayım (Kurs, okul, kendi kendine)',
    'İlk işimi/stajımı arıyorum / Yeni mezunum',
    'Junior seviyede çalışıyorum / Deneyim kazanıyorum',
    'Orta/Kıdemli seviyede profesyonelim',
    'Kariyer değişikliği yapıyorum / Alan değiştiriyorum',
    'Freelance çalışıyorum / Kendi işimi yapıyorum',
  ];
  final List<String> _educationLevelOptions = [
    'Lise / Dengi',
    'Ön Lisans',
    'Lisans',
    'Yüksek Lisans',
    'Doktora',
    'Bootcamp / Yoğun Kurs',
    'Kendi Kendine Öğrenme',
  ];
  final List<String> _interestAreaOptions = [
    'Yazılım Geliştirme',
    'Veri Bilimi',
    'Siber Güvenlik',
    'DevOps',
    'UI/UX Tasarım',
    'Proje Yönetimi',
    'Sistem Yönetimi',
    'Mobil Geliştirme',
    'Web Geliştirme',
    'Yapay Zeka',
    'Oyun Geliştirme',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('identity_status_v3')
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _selectedCurrentStatus = data['current_status'];
          _selectedEducationLevel = data['education_level'];
          _selectedInterestAreas = List<String>.from(data['interest_areas'] ?? []);
          _profileTagline = data['profile_tagline'];
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Bilgiler yüklenirken bir hata oluştu',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData() async {
    setState(() => _isSaving = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;
      final data = {
        'current_status': _selectedCurrentStatus,
        'education_level': _selectedEducationLevel,
        'interest_areas': _selectedInterestAreas,
        'profile_tagline': _profileTagline,
        'updated_at': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('identity_status_v3')
          .set(data, SetOptions(merge: true));
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Kimlik durumu başarıyla kaydedildi!',
          type: SnackBarType.success,
        );
        setState(() => _currentStep = _stepperSteps.length - 1);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Bilgiler kaydedilirken bir hata oluştu',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- Stepper Steps ---
  late final List<_StepperStep> _stepperSteps = [
    _StepperStep(
      title: 'Mevcut Durum',
      description: 'Kariyer yolculuğunun neresindesin? Bu bilgi, sana en uygun yol haritasını sunmamıza yardımcı olur.',
      info: 'Örneğin: "Junior seviyede çalışıyorum" veya "Bilişim alanını keşfediyorum" gibi.',
      contentBuilder: (context) => _buildRadioGroup(
        context,
        _currentStatusOptions,
        _selectedCurrentStatus,
        (value) => setState(() => _selectedCurrentStatus = value),
      ),
      isRequired: true,
      validator: () => _selectedCurrentStatus != null,
    ),
    _StepperStep(
      title: 'Eğitim Seviyesi',
      description: 'Eğitim geçmişin, sana özel içerik ve topluluk önerileri için kullanılır.',
      info: 'Örneğin: "Lisans" veya "Bootcamp / Yoğun Kurs" gibi.',
      contentBuilder: (context) => _buildRadioGroup(
        context,
        _educationLevelOptions,
        _selectedEducationLevel,
        (value) => setState(() => _selectedEducationLevel = value),
      ),
      isRequired: true,
      validator: () => _selectedEducationLevel != null,
    ),
    _StepperStep(
      title: 'İlgi Alanları',
      description: 'Bilişimde seni en çok heyecanlandıran alanlar hangileri? (Birden fazla seçebilirsin)',
      info: 'Örneğin: "Yazılım Geliştirme", "Veri Bilimi" gibi.',
      contentBuilder: (context) => _buildMultiSelector(
        context,
        _interestAreaOptions,
        _selectedInterestAreas,
        (value) {
          setState(() {
            if (_selectedInterestAreas.contains(value)) {
              _selectedInterestAreas.remove(value);
            } else {
              _selectedInterestAreas.add(value);
            }
          });
        },
      ),
      isRequired: true,
      validator: () => _selectedInterestAreas.isNotEmpty,
    ),
    _StepperStep(
      title: 'Kısa Profil Sloganı (İsteğe Bağlı)',
      description: 'Kendini 1 cümleyle tanımlar mısın? (Örn: "Yenilikçi ve çözüm odaklı bir yazılım geliştiriciyim.")',
      info: 'LinkedIn tarzı kısa bir cümle yazabilirsin.',
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: _profileTagline,
          decoration: InputDecoration(
            labelText: 'Profil Sloganın (isteğe bağlı)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.short_text_rounded),
          ),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Kimlik Durumu'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Sayfa Hakkında',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kimlik Durumu Profili'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Bu sayfa, kimlik ve kariyer durumunuzu adım adım profesyonelce belirlemeniz için tasarlanmıştır. SkillCompass, bu bilgilerle size özel yol haritaları ve öneriler sunar.\n\n'
                      'Her adımda açıklamaları ve örnekleri dikkatlice okuyarak doldurmanız, size en uygun gelişim planlarını ve topluluk önerilerini sağlar.',
                    ),
                  ),
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
      body: _isLoading
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
                        CustomSnackBar.show(
                          context: context,
                          message: 'Lütfen gerekli alanları doldurun.',
                          type: SnackBarType.error,
                        );
                      }
                    }
                  : null,
              onSave: _currentStep == _stepperSteps.length - 1 && !_isSaving
                  ? _saveUserData
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicInfoCard(ThemeData theme, int step, {Key? key}) {
    final List<_StepCardInfo> cardInfos = [
      _StepCardInfo(
        icon: Icons.person_outline,
        title: 'Kimlik Durumunuz',
        description: 'Kariyer yolculuğunuzun başlangıç noktası. Mevcut durumunuzu seçerek size en uygun yol haritasını oluşturun.',
        color: theme.colorScheme.primary,
      ),
      _StepCardInfo(
        icon: Icons.school_outlined,
        title: 'Eğitim Seviyesi',
        description: 'En yüksek eğitim seviyenizi seçin. Bu bilgi, size özel içerik ve topluluk önerileri için kullanılır.',
        color: theme.colorScheme.secondary,
      ),
      _StepCardInfo(
        icon: Icons.interests_outlined,
        title: 'İlgi Alanları',
        description: 'Bilişimde ilgilendiğiniz alanları seçin. Birden fazla alan seçebilirsiniz.',
        color: theme.colorScheme.tertiary,
      ),
      _StepCardInfo(
        icon: Icons.short_text_rounded,
        title: 'Kısa Profil Sloganı',
        description: 'Kendini 1 cümleyle tanımlar mısın?',
        color: theme.colorScheme.primary,
      ),
      _StepCardInfo(
        icon: Icons.check_circle_outline,
        title: 'Özet ve Onay',
        description: 'Tüm verdiğiniz bilgileri gözden geçirin ve onaylayın.',
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

  Widget _buildRadioGroup(
    BuildContext context,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: RadioListTile<String>(
            title: Text(
              option,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            value: option,
            groupValue: selectedValue,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelector(
    BuildContext context,
    List<String> options,
    List<String> selectedValues,
    Function(String) onChanged,
  ) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) => onChanged(option),
          selectedColor: theme.colorScheme.primaryContainer.withOpacity(0.7),
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            fontSize: 13,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
            width: 0.8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        );
      }).toList(),
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
            _buildSummaryRow('Mevcut Durum', _selectedCurrentStatus),
            _buildSummaryRow('Eğitim Seviyesi', _selectedEducationLevel),
            _buildSummaryRow('İlgi Alanları', _selectedInterestAreas.join(', ')),
            _buildSummaryRow('Profil Sloganı', _profileTagline),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value == null || value.isEmpty ? '-' : value),
          ),
        ],
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
            (_buildSummaryStepButton(theme)),
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

// Step başına kart bilgisi modeli
class _StepCardInfo {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  _StepCardInfo({required this.icon, required this.title, required this.description, required this.color});
}
