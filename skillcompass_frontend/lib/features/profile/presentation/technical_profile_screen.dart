import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // flutter pub add uuid
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/core/widgets/custom_button.dart';
import 'package:skillcompass_frontend/core/widgets/custom_snackbar.dart';

// --- Veri Modelleri ---
class SkillEntry {
  String name;
  String level; // Beginner, Intermediate, Advanced

  SkillEntry({required this.name, required this.level});

  Map<String, dynamic> toMap() => {'skill': name, 'level': level};

  factory SkillEntry.fromMap(Map<String, dynamic> map) {
    return SkillEntry(
      name: map['skill'] ?? '',
      level: map['level'] ?? 'Beginner',
    );
  }
}

class ProjectEntry {
  String id;
  String name;
  String description;
  List<String> technologies;
  String? link;

  ProjectEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.technologies,
    this.link,
  });

  factory ProjectEntry.fromMap(Map<String, dynamic> map) {
    return ProjectEntry(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      technologies: List<String>.from(map['technologies'] ?? []),
      link: map['link'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'technologies': technologies,
      'link': link,
    };
  }
}
// -------------------------

class TechnicalProfileScreen extends StatefulWidget {
  const TechnicalProfileScreen({super.key});

  @override
  State<TechnicalProfileScreen> createState() => _TechnicalProfileScreenState();
}

class _TechnicalProfileScreenState extends State<TechnicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  User? _currentUser;
  bool _isLoadingPage = true;
  bool _isSaving = false;
  String _loadingError = '';

  // --- State ---
  String? _selectedExperienceLevel;
  List<String> _selectedExpertiseAreas = [];
  List<String> _selectedMainTechnologies = [];
  String? _selectedTargetRole;
  String? _motivation;

  // --- Options ---
  final List<String> _experienceLevels = [
    'Yeni Başlayan (0-1 yıl)',
    'Junior (1-3 yıl)',
    'Mid-Level (3-5 yıl)',
    'Senior (5-8 yıl)',
    'Lead (8+ yıl)',
  ];
  final List<String> _expertiseAreas = [
    'Web Geliştirme',
    'Mobil Geliştirme',
    'Veri Bilimi',
    'Yapay Zeka',
    'Oyun Geliştirme',
    'DevOps',
    'Siber Güvenlik',
    'Gömülü Sistemler',
    'Diğer',
  ];
  final List<String> _mainTechnologies = [
    'Python', 'JavaScript', 'Java', 'C#', 'C++', 'TypeScript', 'Go', 'Dart',
    'React', 'Angular', 'Vue.js', 'Django', 'Flutter', 'Spring Boot', 'AWS', 'Azure', 'Google Cloud', 'Diğer',
  ];
  final List<String> _targetRoles = [
    'Frontend Geliştirici',
    'Backend Geliştirici',
    'Full Stack Geliştirici',
    'DevOps Mühendisi',
    'Mobil Geliştirici',
    'UI/UX Tasarımcı',
    'Veri Bilimci',
    'Siber Güvenlik Uzmanı',
    'Sistem Yöneticisi',
    'Proje Yöneticisi',
    'Diğer',
  ];

  int _currentStep = 0;

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
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('profile_data')
          .doc('technical_profile')
          .get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          _selectedExperienceLevel = data['experience_level'];
          _selectedExpertiseAreas = List<String>.from(data['expertise_areas'] ?? []);
          _selectedMainTechnologies = List<String>.from(data['main_technologies'] ?? []);
          _selectedTargetRole = data['target_role'];
          _motivation = data['motivation'];
        });
      }
    } catch (e) {
      _loadingError = 'Kaydedilmiş veriler yüklenirken bir sorun oluştu.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPage = false;
        });
      }
    }
  }

  Future<void> _saveToFirestore() async {
    if (_currentUser == null) return;
    setState(() => _isSaving = true);
    try {
      final data = {
        'experience_level': _selectedExperienceLevel,
        'expertise_areas': _selectedExpertiseAreas,
        'main_technologies': _selectedMainTechnologies,
        'target_role': _selectedTargetRole,
        'motivation': _motivation,
        'updated_at': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('profile_data')
          .doc('technical_profile')
          .set(data, SetOptions(merge: true));
      if (mounted) {
        _showFeedback('Teknik profil başarıyla kaydedildi!', isError: false);
        setState(() => _currentStep = _stepperSteps.length - 1);
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

  // --- Stepper Steps ---
  late final List<_StepperStep> _stepperSteps = [
    _StepperStep(
      title: 'Genel Teknik Seviye',
      description: 'Teknik yolculuğunda kendini hangi seviyede görüyorsun? Bu bilgi, sana uygun yol haritası ve içerik önerileri için kullanılır.',
      info: 'Örneğin: "Junior (1-3 yıl)", "Senior (5-8 yıl)" gibi.',
      icon: Icons.trending_up,
      color: Colors.indigo,
      contentBuilder: (context) => _buildStatusSelector(
        context,
        _experienceLevels,
        _selectedExperienceLevel,
        (value) => setState(() => _selectedExperienceLevel = value),
      ),
      isRequired: true,
      validator: () => _selectedExperienceLevel != null,
    ),
    _StepperStep(
      title: 'Uzmanlık Alanı',
      description: 'En çok odaklandığın teknik alan(lar) nedir? (Birden fazla seçebilirsin)',
      info: 'Örneğin: "Web Geliştirme", "Veri Bilimi", "DevOps" gibi.',
      icon: Icons.category,
      color: Colors.teal,
      contentBuilder: (context) => _buildMultiSelector(
        context,
        _expertiseAreas,
        _selectedExpertiseAreas,
        (value) {
          setState(() {
            if (_selectedExpertiseAreas.contains(value)) {
              _selectedExpertiseAreas.remove(value);
            } else {
              _selectedExpertiseAreas.add(value);
            }
          });
        },
      ),
      isRequired: true,
      validator: () => _selectedExpertiseAreas.isNotEmpty,
    ),
    _StepperStep(
      title: 'Ana Teknolojiler',
      description: 'En iyi bildiğin veya öğrenmek istediğin 3 ana teknolojiyi seç. (En fazla 3 seçim)',
      info: 'Örneğin: "React", "Python", "AWS" gibi.',
      icon: Icons.memory,
      color: Colors.deepPurple,
      contentBuilder: (context) => _buildMultiSelector(
        context,
        _mainTechnologies,
        _selectedMainTechnologies,
        (value) {
          setState(() {
            if (_selectedMainTechnologies.contains(value)) {
              _selectedMainTechnologies.remove(value);
            } else if (_selectedMainTechnologies.length < 3) {
              _selectedMainTechnologies.add(value);
            }
          });
        },
      ),
      isRequired: true,
      validator: () => _selectedMainTechnologies.isNotEmpty && _selectedMainTechnologies.length <= 3,
    ),
    _StepperStep(
      title: 'Hedeflenen Rol',
      description: 'Kariyerinde ulaşmak istediğin ana rolü seç.',
      info: 'Örneğin: "Backend Geliştirici", "Data Scientist" gibi.',
      icon: Icons.work,
      color: Colors.brown,
      contentBuilder: (context) => _buildStatusSelector(
        context,
        _targetRoles,
        _selectedTargetRole,
        (value) => setState(() => _selectedTargetRole = value),
      ),
      isRequired: true,
      validator: () => _selectedTargetRole != null,
    ),
    _StepperStep(
      title: 'Gelişim Motivasyonu (İsteğe Bağlı)',
      description: 'Seni en çok motive eden şey nedir? (Kısa bir cümleyle yazabilirsin)',
      info: 'Örneğin: "Yeni teknolojileri öğrenmek", "Takım lideri olmak", "Global projelerde yer almak" gibi.',
      icon: Icons.emoji_objects,
      color: Colors.orange,
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: _motivation,
          decoration: InputDecoration(
            labelText: 'Motivasyonun (isteğe bağlı)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.emoji_objects_outlined),
          ),
          maxLines: 2,
          onChanged: (value) => setState(() => _motivation = value),
        ),
      ),
      isRequired: false,
      validator: () => true,
    ),
    _StepperStep(
      title: 'Özet ve Onay',
      description: 'Tüm verdiğin bilgileri gözden geçir ve onayla.',
      info: 'Bilgilerini kontrol et. Kaydettikten sonra profilinde güncellenmiş olarak göreceksin.',
      icon: Icons.check_circle_outline,
      color: Colors.blueGrey,
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
        title: const Text('Teknik Profil'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Sayfa Hakkında',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Teknik Profil'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Bu sayfa, teknik profilinizi adım adım profesyonelce doldurmanız için tasarlanmıştır. Her adımda açıklamaları ve örnekleri dikkatlice okuyarak doldurmanız, size en uygun gelişim planlarını ve topluluk önerilerini sağlar.',
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

  Widget _buildDynamicInfoCard(ThemeData theme, int step, {Key? key}) {
    final info = _stepperSteps[step.clamp(0, _stepperSteps.length - 1)];
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

  Widget _buildStatusSelector(
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
            _buildSummaryRow('Genel Teknik Seviye', _selectedExperienceLevel),
            _buildSummaryRow('Uzmanlık Alanı', _selectedExpertiseAreas.join(', ')),
            _buildSummaryRow('Ana Teknolojiler', _selectedMainTechnologies.join(', ')),
            _buildSummaryRow('Hedeflenen Rol', _selectedTargetRole),
            _buildSummaryRow('Gelişim Motivasyonu', _motivation),
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
  final IconData icon;
  final Color color;
  final Widget Function(BuildContext) contentBuilder;
  final bool isRequired;
  final bool Function() validator;
  _StepperStep({
    required this.title,
    required this.description,
    required this.info,
    required this.icon,
    required this.color,
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
