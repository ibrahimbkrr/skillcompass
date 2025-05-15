import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/features/profile/services/profile_service.dart';
import 'widgets/technical_profile_info_card.dart';
import 'widgets/technical_profile_multi_info_card.dart';
import 'widgets/technical_profile_status_selector.dart';
import 'widgets/technical_profile_multi_selector.dart';

class TechnicalProfileScreen extends StatefulWidget {
  const TechnicalProfileScreen({Key? key}) : super(key: key);

  @override
  State<TechnicalProfileScreen> createState() => _TechnicalProfileScreenState();
}

class _TechnicalProfileScreenState extends State<TechnicalProfileScreen> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';
  bool _isEditMode = false;
  late TabController _tabController;

  // --- State Variables ---
  String? _selectedPrimaryField;
  String? _selectedExperienceLevel;
  List<String> _selectedTechnologies = [];
  List<String> _selectedSkills = [];
  String? _projectExperience;
  double _technicalConfidence = 5.0;

  // --- Options Lists ---
  final List<String> _primaryFieldOptions = [
    'Frontend Geliştirme',
    'Backend Geliştirme',
    'Fullstack Geliştirme',
    'Mobil Uygulama Geliştirme',
    'Oyun Geliştirme',
    'Veri Bilimi / Analitiği',
    'Bulut Teknolojileri',
    'DevOps / SRE',
    'Siber Güvenlik',
    'UI/UX Tasarım',
    'Yapay Zeka / Makine Öğrenmesi',
    'Gömülü Sistemler / IoT',
    'Diğer',
  ];

  final List<String> _experienceLevelOptions = [
    'Başlangıç Seviyesi (0-1 yıl)',
    'Junior (1-2 yıl)',
    'Junior-Mid (2-3 yıl)',
    'Mid-level (3-5 yıl)',
    'Senior (5+ yıl)',
    'Lead / Principle (8+ yıl)',
  ];

  final List<String> _technologiesOptions = [
    'JavaScript', 'TypeScript', 'React', 'Vue.js', 'Angular',
    'Node.js', 'Python', 'Django', 'Flask', 'Java', 'Spring',
    'C#', '.NET', 'PHP', 'Laravel', 'Ruby', 'Rails',
    'Swift', 'Kotlin', 'Flutter', 'React Native',
    'MySQL', 'PostgreSQL', 'MongoDB', 'SQLite', 'Redis',
    'AWS', 'Azure', 'GCP', 'Docker', 'Kubernetes',
    'Git', 'CI/CD', 'Jenkins', 'GitHub Actions',
    'TensorFlow', 'PyTorch', 'Scikit-learn', 'Pandas', 'Numpy',
    'HTML', 'CSS', 'SASS/SCSS', 'Tailwind CSS', 'Bootstrap',
    'GraphQL', 'REST API', 'WebSockets',
    'Unity', 'Unreal Engine',
  ];

  final List<String> _skillsOptions = [
    'Algoritma Tasarımı', 'Veri Yapıları', 'Nesne Yönelimli Programlama', 
    'Fonksiyonel Programlama', 'Test Yazımı (TDD/BDD)', 'Kod Gözden Geçirme',
    'Veritabanı Tasarımı', 'API Tasarımı', 'Sistem Tasarımı',
    'Performans Optimizasyonu', 'Güvenlik Uygulamaları', 'Bellek Yönetimi',
    'Mikroservis Mimarisi', 'Monolitik Mimari', 'Serverless Mimari',
    'Clean Code / SOLID İlkeleri', 'Design Patterns', 'Continuous Integration',
    'Problem Çözme', 'Debugging', 'Refactoring', 'Code Documentation',
    'Responsive Design', 'Cross-platform Geliştirme', 'UI/UX Prensipleri',
    'Event-Driven Programming', 'Concurrency / Paralel Programlama',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await _profileService.loadTechnicalProfile();
      
      if (data != null) {
        setState(() {
          _selectedPrimaryField = data['primary_field'];
          _selectedExperienceLevel = data['experience_level'];
          _selectedTechnologies = List<String>.from(data['technologies'] ?? []);
          _selectedSkills = List<String>.from(data['skills'] ?? []);
          _projectExperience = data['project_experience'];
          _technicalConfidence = (data['technical_confidence'] ?? 5.0).toDouble();
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Profil verileri yüklenirken bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToFirestore() async {
    setState(() => _isSaving = true);
    try {
      final data = {
        'primary_field': _selectedPrimaryField,
        'experience_level': _selectedExperienceLevel,
        'technologies': _selectedTechnologies,
        'skills': _selectedSkills,
        'project_experience': _projectExperience,
        'technical_confidence': _technicalConfidence,
      };
      
      await _profileService.saveTechnicalProfile(data);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teknik profil başarıyla kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() => _isEditMode = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bilgiler kaydedilirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teknik Profil'),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Düzenle',
              onPressed: () => setState(() => _isEditMode = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Kaydet',
              onPressed: _isSaving ? null : _saveToFirestore,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _error.isNotEmpty
              ? Center(child: ErrorMessage(message: _error))
              : Column(
                  children: [
                    Material(
                      elevation: 2,
                      color: theme.colorScheme.surface,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Ana Bilgiler'),
                          Tab(text: 'Teknolojiler'),
                          Tab(text: 'Yetenekler'),
                        ],
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.colorScheme.onSurface,
                        indicatorColor: theme.colorScheme.primary,
                        indicatorWeight: 3,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPrimaryFieldTab(theme),
                          _buildTechnologiesTab(theme),
                          _buildSkillsTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPrimaryFieldTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechnicalProfileInfoCard(
            theme: theme,
            title: 'Ana Uzmanlık Alanı',
            value: _selectedPrimaryField ?? 'Belirtilmemiş',
            icon: Icons.code,
            description: 'Temel uzmanlık ve odak alanın',
          ),
          const SizedBox(height: 16),
          TechnicalProfileInfoCard(
            theme: theme,
            title: 'Deneyim Seviyesi',
            value: _selectedExperienceLevel ?? 'Belirtilmemiş',
            icon: Icons.timeline_outlined,
            description: 'Mevcut teknik deneyim seviyesi',
          ),
          const SizedBox(height: 16),
          TechnicalProfileInfoCard(
            theme: theme,
            title: 'Teknik Özgüven',
            value: _getTechnicalConfidenceText(),
            icon: Icons.insights,
            description: 'Teknik problemleri çözme konusundaki özgüvenin',
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Ana Uzmanlık Alanı',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TechnicalProfileStatusSelector(
              options: _primaryFieldOptions,
              selectedValue: _selectedPrimaryField,
              onChanged: (value) => setState(() => _selectedPrimaryField = value),
              isSaving: _isSaving,
            ),
            const SizedBox(height: 24),
            Text(
              'Deneyim Seviyesi',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TechnicalProfileStatusSelector(
              options: _experienceLevelOptions,
              selectedValue: _selectedExperienceLevel,
              onChanged: (value) => setState(() => _selectedExperienceLevel = value),
              isSaving: _isSaving,
            ),
            const SizedBox(height: 24),
            Text(
              'Teknik Özgüven (1-10)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Teknik problemleri çözme konusundaki özgüvenini değerlendir',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _technicalConfidence,
              min: 1,
              max: 10,
              divisions: 9,
              label: _technicalConfidence.round().toString(),
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
              onChanged: (value) => setState(() => _technicalConfidence = value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Düşük', style: theme.textTheme.bodySmall),
                Text('Orta', style: theme.textTheme.bodySmall),
                Text('Yüksek', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTechnologiesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechnicalProfileMultiInfoCard(
            theme: theme,
            title: 'Teknolojiler & Araçlar',
            values: _selectedTechnologies,
            icon: Icons.construction,
            description: 'Bildiğin teknolojiler, diller ve araçlar',
          ),
          const SizedBox(height: 16),
          TechnicalProfileInfoCard(
            theme: theme,
            title: 'Proje Deneyimi',
            value: _projectExperience?.isNotEmpty == true ? _projectExperience! : 'Belirtilmemiş',
            icon: Icons.assignment_outlined,
            description: 'Önemli projeler veya teknik deneyimler',
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Teknolojiler & Araçlar',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TechnicalProfileMultiSelector(
              options: _technologiesOptions,
              selectedValues: _selectedTechnologies,
              onChanged: (value) {
                setState(() {
                  if (_selectedTechnologies.contains(value)) {
                    _selectedTechnologies.remove(value);
                  } else {
                    _selectedTechnologies.add(value);
                  }
                });
              },
              isSaving: _isSaving,
            ),
            const SizedBox(height: 24),
            Text(
              'Proje Deneyimi',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _projectExperience,
              decoration: InputDecoration(
                hintText: 'Örn: 2 e-ticaret sitesi ve 1 mobil uygulama geliştirdim',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 5,
              onChanged: (value) => setState(() => _projectExperience = value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechnicalProfileMultiInfoCard(
            theme: theme,
            title: 'Teknik Beceriler',
            values: _selectedSkills,
            icon: Icons.engineering,
            description: 'Sahip olduğun teknik ve mühendislik becerileri',
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Teknik Beceriler',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TechnicalProfileMultiSelector(
              options: _skillsOptions,
              selectedValues: _selectedSkills,
              onChanged: (value) {
                setState(() {
                  if (_selectedSkills.contains(value)) {
                    _selectedSkills.remove(value);
                  } else {
                    _selectedSkills.add(value);
                  }
                });
              },
              isSaving: _isSaving,
            ),
          ],
        ],
      ),
    );
  }

  // Helper Methods
  String _getTechnicalConfidenceText() {
    final rating = _technicalConfidence.round();
    if (rating <= 3) return 'Düşük (${rating}/10)';
    if (rating <= 7) return 'Orta (${rating}/10)';
    return 'Yüksek (${rating}/10)';
  }
} 