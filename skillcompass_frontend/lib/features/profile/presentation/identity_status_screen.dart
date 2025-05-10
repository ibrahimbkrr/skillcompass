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

class _IdentityStatusScreenState extends State<IdentityStatusScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isEditing = false;
  late TabController _tabController;
  int _currentStep = 0;

  // Seçim değişkenleri
  String? _selectedCurrentStatus;
  String? _selectedEducationLevel;
  List<String> _selectedFields = [];
  List<String> _selectedActivities = [];
  List<String> _selectedInvestmentMethods = [];
  List<String> _selectedExpectations = [];

  // Seçenek listeleri
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

  final List<String> _fieldOptions = [
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

  final List<String> _activityOptions = [
    'Üniversite/Okul Dersleri',
    'Staj',
    'Online Kurslar',
    'Freelance Projeler',
    'Tam Zamanlı İş',
    'Yarı Zamanlı İş',
    'Kişisel Projeler',
    'İş Arama Süreci',
    'Açık Kaynak Katkı',
  ];

  final List<String> _investmentMethodOptions = [
    'Online Kurslar (Udemy, Coursera vb.)',
    'Teknik Kitaplar / Bloglar',
    'Kişisel Projeler',
    'Açık Kaynak Projeler',
    'Etkinlikler (Meetup, Konferans)',
    'Online Topluluklar',
    'Kodlama Platformları',
    'Teknoloji Podcastleri',
    'Mentorluk',
  ];

  final List<String> _expectationOptions = [
    'Kariyer yol haritası',
    'Eksik yönlerimin tespiti',
    'Teknik beceri geliştirme',
    'Motivasyon ve takip',
    'Mülakat hazırlığı',
    'Sektör trendleri',
    'Topluluk desteği',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          _selectedFields = List<String>.from(data['fields'] ?? []);
          _selectedActivities = List<String>.from(data['activities'] ?? []);
          _selectedInvestmentMethods = List<String>.from(data['investment_methods'] ?? []);
          _selectedExpectations = List<String>.from(data['expectations'] ?? []);
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;

      final data = {
        'current_status': _selectedCurrentStatus,
        'education_level': _selectedEducationLevel,
        'fields': _selectedFields,
        'activities': _selectedActivities,
        'investment_methods': _selectedInvestmentMethods,
        'expectations': _selectedExpectations,
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
          message: 'Bilgileriniz başarıyla kaydedildi',
          type: SnackBarType.success,
        );
        setState(() => _isEditing = false);
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kimlik Durumu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Temel Bilgiler'),
            Tab(text: 'İlgi Alanları'),
            Tab(text: 'Beklentiler'),
          ],
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Düzenle',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(theme),
                _buildInterestsTab(theme),
                _buildExpectationsTab(theme),
              ],
            ),
    );
  }

  Widget _buildBasicInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(theme),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              'Mevcut Durumunuz',
              _buildStatusSelector(
                theme,
                _currentStatusOptions,
                _selectedCurrentStatus,
                (value) => setState(() => _selectedCurrentStatus = value),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              'Eğitim Seviyeniz',
              _buildStatusSelector(
                theme,
                _educationLevelOptions,
                _selectedEducationLevel,
                (value) => setState(() => _selectedEducationLevel = value),
              ),
            ),
            if (_isEditing) _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            theme,
            'İlgilendiğiniz Alanlar',
            _buildMultiSelector(
              theme,
              _fieldOptions,
              _selectedFields,
              (value) {
                setState(() {
                  if (_selectedFields.contains(value)) {
                    _selectedFields.remove(value);
                  } else {
                    _selectedFields.add(value);
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            theme,
            'Mevcut Aktiviteleriniz',
            _buildMultiSelector(
              theme,
              _activityOptions,
              _selectedActivities,
              (value) {
                setState(() {
                  if (_selectedActivities.contains(value)) {
                    _selectedActivities.remove(value);
                  } else {
                    _selectedActivities.add(value);
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            theme,
            'Gelişim Yöntemleriniz',
            _buildMultiSelector(
              theme,
              _investmentMethodOptions,
              _selectedInvestmentMethods,
              (value) {
                setState(() {
                  if (_selectedInvestmentMethods.contains(value)) {
                    _selectedInvestmentMethods.remove(value);
                  } else {
                    _selectedInvestmentMethods.add(value);
                  }
                });
              },
            ),
          ),
          if (_isEditing) _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildExpectationsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            theme,
            'SkillCompass\'tan Beklentileriniz',
            _buildMultiSelector(
              theme,
              _expectationOptions,
              _selectedExpectations,
              (value) {
                setState(() {
                  if (_selectedExpectations.contains(value)) {
                    _selectedExpectations.remove(value);
                  } else {
                    _selectedExpectations.add(value);
                  }
                });
              },
            ),
          ),
          if (_isEditing) _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoş Geldiniz!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kimlik durumunuzu güncelleyerek size özel öneriler alın',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getSectionIcon(title),
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ),
      ],
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Mevcut Durumunuz':
        return Icons.work_outline;
      case 'Eğitim Seviyeniz':
        return Icons.school_outlined;
      case 'İlgilendiğiniz Alanlar':
        return Icons.code_outlined;
      case 'Mevcut Aktiviteleriniz':
        return Icons.event_note_outlined;
      case 'Gelişim Yöntemleriniz':
        return Icons.trending_up_outlined;
      case 'SkillCompass\'tan Beklentileriniz':
        return Icons.rocket_launch;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildStatusSelector(
    ThemeData theme,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Column(
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return Card(
          elevation: 0,
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            value: option,
            groupValue: selectedValue,
            onChanged: _isEditing ? onChanged : null,
            activeColor: theme.colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelector(
    ThemeData theme,
    List<String> options,
    List<String> selectedValues,
    Function(String) onChanged,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return FilterChip(
          label: Text(
            option,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: _isEditing ? (selected) => onChanged(option) : null,
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
          checkmarkColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          elevation: isSelected ? 2 : 0,
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              onPressed: _saveUserData,
              text: 'Kaydet',
              isLoading: _isLoading,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              onPressed: () {
                setState(() => _isEditing = false);
                _loadUserData();
              },
              text: 'İptal',
              isLoading: false,
              backgroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
