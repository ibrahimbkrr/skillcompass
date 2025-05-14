import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/features/profile/services/profile_service.dart';

class SupportCommunityScreen extends StatefulWidget {
  const SupportCommunityScreen({super.key});

  @override
  State<SupportCommunityScreen> createState() => _SupportCommunityScreenState();
}

class _SupportCommunityScreenState extends State<SupportCommunityScreen> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';
  bool _isEditMode = false;
  late TabController _tabController;

  // Form Alanları
  // Soru 1
  final Map<String, bool> _problemSolvingMethods = {
    'Stack Overflow / Forumlar': false,
    'ChatGPT / Yapay Zeka Araçları': false,
    'Resmi Dokümantasyonlar': false,
    'Mentora / Deneyimli Birine Sormak': false,
    'Deneme Yanılma / Kendi Başıma Çözmeye Çalışmak': false,
    'Konuyu Geçici Olarak Bırakıp Sonra Dönmek': false,
  };

  // Soru 2
  String? _feedbackPreference;
  final List<String> _feedbackOptions = [
    'Evet, çok isterim',
    'Evet, duruma göre',
    'Hayır, pek tercih etmem',
  ];
  final TextEditingController _feedbackDetailsController = TextEditingController();

  // Soru 3
  String? _mentorshipPreference;
  final List<String> _mentorshipOptions = [
    'Evet, aktif olarak arıyorum',
    'Evet, fırsat olursa değerlendiririm',
    'Belki, emin değilim',
    'Hayır, şu an için düşünmüyorum',
  ];
  final TextEditingController _mentorshipDetailsController = TextEditingController();

  // Soru 4
  final Map<String, bool> _communityActivityOptions = {
    'Discord Sunucuları': false,
    'Telegram Grupları': false,
    'LinkedIn Grupları': false,
    'Üniversite Kulüpleri / Öğrenci Toplulukları': false,
    'Yerel Meetup Grupları': false,
    'Online Forumlar (Stack Overflow dışında)': false,
    'GitHub Tartışmaları / Issues': false,
    'Aktif Değilim': false,
  };

  // Soru 5
  bool? _hasSupportCircle;
  final TextEditingController _supportCircleDetailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedData();
  }
  
  @override
  void dispose() {
    _feedbackDetailsController.dispose();
    _mentorshipDetailsController.dispose();
    _supportCircleDetailsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      final data = await _profileService.loadSupportCommunity();
      
      if (data != null) {
        _updateStateWithLoadedData(data);
      }
    } catch (e) {
      setState(() {
        _error = 'Destek ve topluluk verileri yüklenirken bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateStateWithLoadedData(Map<String, dynamic> data) {
    setState(() {
      List<String> savedMethods = List<String>.from(
        data['problemSolvingMethods'] ?? [],
      );
      _problemSolvingMethods.forEach((key, value) {
        _problemSolvingMethods[key] = savedMethods.contains(key);
      });
      
      _feedbackPreference = data['feedbackPreference'];
      if (!_feedbackOptions.contains(_feedbackPreference))
        _feedbackPreference = null;
      _feedbackDetailsController.text = data['feedbackDetails'] ?? '';
      
      _mentorshipPreference = data['mentorshipPreference'];
      if (!_mentorshipOptions.contains(_mentorshipPreference))
        _mentorshipPreference = null;
      _mentorshipDetailsController.text = data['mentorshipDetails'] ?? '';
      
      List<String> savedCommunities = List<String>.from(
        data['communityActivities'] ?? [],
      );
      _communityActivityOptions.forEach((key, value) {
        _communityActivityOptions[key] = savedCommunities.contains(key);
      });
      
      _hasSupportCircle = data['hasSupportCircle'];
      _supportCircleDetailsController.text = data['supportCircleDetails'] ?? '';
    });
  }

  Future<void> _saveToFirestore() async {
    setState(() => _isSaving = true);
    
    try {
      List<String> selectedProblemSolvingMethods = _problemSolvingMethods.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
          
      List<String> selectedCommunityActivities = _communityActivityOptions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
          
      final data = {
        'problemSolvingMethods': selectedProblemSolvingMethods,
        'feedbackPreference': _feedbackPreference,
        'feedbackDetails': _feedbackDetailsController.text,
        'mentorshipPreference': _mentorshipPreference,
        'mentorshipDetails': _mentorshipDetailsController.text,
        'communityActivities': selectedCommunityActivities,
        'hasSupportCircle': _hasSupportCircle,
        'supportCircleDetails': _supportCircleDetailsController.text,
      };
    
      await _profileService.saveSupportCommunity(data);
    
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Destek ve topluluk bilgileri başarıyla kaydedildi!'),
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
        title: const Text('Destek & Topluluk'),
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
                          Tab(text: 'Problem Çözme'),
                          Tab(text: 'Mentorluk & Geribildirim'),
                          Tab(text: 'Topluluklar'),
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
                          _buildProblemSolvingTab(theme),
                          _buildMentorshipFeedbackTab(theme),
                          _buildCommunitiesTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProblemSolvingTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: 'Problem Çözme Yöntemlerim',
            icon: Icons.lightbulb,
            description: 'Bir teknik problemle karşılaştığınızda kullandığınız yöntemler',
            content: _buildSelectedItemsList(_problemSolvingMethods, theme),
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Problem Çözme Yöntemleriniz',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bir teknik problemle karşılaştığınızda genellikle hangi yöntemleri kullanırsınız?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckboxList(_problemSolvingMethods, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildMentorshipFeedbackTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: 'Geribildirim Tercihi',
            icon: Icons.feedback,
            description: 'Kodunuz/projeleriniz hakkında geribildirim almak ister misiniz?',
            content: Text(
              _feedbackPreference ?? 'Belirtilmemiş',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _feedbackPreference == null
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (_feedbackDetailsController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              theme,
              title: 'Geribildirim Detayları',
              icon: Icons.comment,
              description: 'Geribildirimlere dair tercihleriniz',
              content: Text(
                _feedbackDetailsController.text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildInfoCard(
            theme,
            title: 'Mentorluk Tercihi',
            icon: Icons.person,
            description: 'Yazılım alanında bir mentor edinmek ister misiniz?',
            content: Text(
              _mentorshipPreference ?? 'Belirtilmemiş',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _mentorshipPreference == null
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (_mentorshipDetailsController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              theme,
              title: 'Mentorluk Detayları',
              icon: Icons.comment,
              description: 'Mentorluğa dair özel notlarınız',
              content: Text(
                _mentorshipDetailsController.text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Geribildirim Tercihi',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kodunuz/projeleriniz hakkında geribildirim almak ister misiniz?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(
              context,
              _feedbackOptions,
              _feedbackPreference,
              (value) => setState(() => _feedbackPreference = value),
            ),
            const SizedBox(height: 24),
            Text(
              'Geribildirim Detayları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _feedbackDetailsController,
              decoration: InputDecoration(
                hintText: 'Geribildirim almaya dair detayları yazabilirsiniz...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Mentorluk Tercihi',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Yazılım alanında bir mentor edinmek ister misiniz?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(
              context,
              _mentorshipOptions,
              _mentorshipPreference,
              (value) => setState(() => _mentorshipPreference = value),
            ),
            const SizedBox(height: 24),
            Text(
              'Mentorluk Detayları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mentorshipDetailsController,
              decoration: InputDecoration(
                hintText: 'Mentordan beklentileriniz, ilgilendiğiniz alanlar, vb...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommunitiesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: 'Topluluk Aktivitelerim',
            icon: Icons.groups,
            description: 'Aktif olduğunuz yazılım ve teknoloji toplulukları',
            content: _buildSelectedItemsList(_communityActivityOptions, theme),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            theme,
            title: 'Destek Çemberi',
            icon: Icons.people,
            description: 'Yazılım öğrenim/kariyer yolculuğunuzda size destek olan kişiler',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasSupportCircle != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _hasSupportCircle == true ? 'Evet, var' : 'Hayır, yok',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Belirtilmemiş',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                if (_supportCircleDetailsController.text.isNotEmpty)
                  Text(
                    _supportCircleDetailsController.text,
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Topluluk Aktiviteleriniz',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Aktif olduğunuz yazılım ve teknoloji topluluklarını seçin',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckboxList(_communityActivityOptions, theme),
            const SizedBox(height: 24),
            Text(
              'Destek Çemberi',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Yazılım öğrenim/kariyer yolculuğunuzda size destek olan kişiler var mı?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildBooleanSelector(
              context,
              _hasSupportCircle,
              (value) => setState(() => _hasSupportCircle = value),
            ),
            const SizedBox(height: 24),
            Text(
              'Destek Çemberi Detayları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _supportCircleDetailsController,
              decoration: InputDecoration(
                hintText: 'Size destek olan kişileri, destek şeklini, vb. yazabilirsiniz...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required String description,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedItemsList(Map<String, bool> items, ThemeData theme) {
    final selectedItems = items.entries.where((e) => e.value).map((e) => e.key).toList();
    
    if (selectedItems.isEmpty) {
      return Text(
        'Belirtilmemiş',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedItems.map((item) {
        return Chip(
          label: Text(item),
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          labelStyle: TextStyle(color: theme.colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxList(Map<String, bool> items, ThemeData theme) {
    return Column(
      children: items.entries.map((entry) {
        return Card(
          elevation: 0,
          color: entry.value ? theme.colorScheme.primary.withOpacity(0.1) : null,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: entry.value
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: entry.value ? 2 : 1,
            ),
          ),
          child: CheckboxListTile(
            title: Text(
              entry.key,
              style: TextStyle(
                fontWeight: entry.value ? FontWeight.bold : FontWeight.normal,
                color: entry.value
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            value: entry.value,
            activeColor: theme.colorScheme.primary,
            checkColor: theme.colorScheme.onPrimary,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  items[entry.key] = value;
                });
              }
            },
          ),
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
      ],
    );
  }
  
  Widget _buildBooleanSelector(
    BuildContext context, 
    bool? selectedValue, 
    Function(bool?) onChanged
  ) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.only(right: 8),
            color: selectedValue == true
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selectedValue == true
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                width: selectedValue == true ? 2 : 1,
              ),
            ),
            child: RadioListTile<bool>(
              title: Text(
                'Evet',
                style: TextStyle(
                  color: selectedValue == true
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: selectedValue == true ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              value: true,
              groupValue: selectedValue,
              onChanged: !_isSaving ? onChanged : null,
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        Expanded(
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.only(left: 8),
            color: selectedValue == false
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selectedValue == false
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                width: selectedValue == false ? 2 : 1,
              ),
            ),
            child: RadioListTile<bool>(
              title: Text(
                'Hayır',
                style: TextStyle(
                  color: selectedValue == false
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: selectedValue == false ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              value: false,
              groupValue: selectedValue,
              onChanged: !_isSaving ? onChanged : null,
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
} 