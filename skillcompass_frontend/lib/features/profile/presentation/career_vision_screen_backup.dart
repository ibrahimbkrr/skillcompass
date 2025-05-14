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

class CareerVisionScreen extends StatefulWidget {
  const CareerVisionScreen({super.key});

  @override
  State<CareerVisionScreen> createState() => _CareerVisionScreenState();
}

class _CareerVisionScreenState extends State<CareerVisionScreen> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';
  bool _isEditMode = false;
  late TabController _tabController;

  // --- State Değişkenleri ---
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
      final data = await _profileService.loadCareerVision();
      
      if (data != null) {
        setState(() {
          _selectedOneYearGoal = data['one_year_goal'];
          _oneYearGoalDetail = data['one_year_goal_detail'];
          _selectedFiveYearVision = data['five_year_vision'];
          _fiveYearVisionDetail = data['five_year_vision_detail'];
          _selectedMotivationSources = List<String>.from(data['motivation_sources'] ?? []);
          _profileTagline = data['profile_tagline'];
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
        'one_year_goal': _selectedOneYearGoal,
        'one_year_goal_detail': _oneYearGoalDetail,
        'five_year_vision': _selectedFiveYearVision,
        'five_year_vision_detail': _fiveYearVisionDetail,
        'motivation_sources': _selectedMotivationSources,
        'profile_tagline': _profileTagline,
      };
      
      await _profileService.saveCareerVision(data);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kariyer vizyonu başarıyla kaydedildi!'),
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
        title: const Text('Kariyer Vizyonu'),
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
                          Tab(text: 'Kısa Vade'),
                          Tab(text: 'Uzun Vade'),
                          Tab(text: 'Motivasyon'),
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
                          _buildShortTermTab(theme),
                          _buildLongTermTab(theme),
                          _buildMotivationTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildShortTermTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: '1 Yıllık Hedef',
            value: _selectedOneYearGoal ?? 'Belirtilmemiş',
            icon: Icons.looks_one_rounded,
            description: 'Kısa vadede ulaşmak istediğin ana kariyer hedefin',
          ),
          const SizedBox(height: 16),
          if (_oneYearGoalDetail?.isNotEmpty == true) ...[
            _buildInfoCard(
              theme,
              title: 'Hedef Detayı',
              value: _oneYearGoalDetail!,
              icon: Icons.edit_note_rounded,
              description: 'Kısa vadeli hedefin hakkında ek detaylar',
            ),
            const SizedBox(height: 16),
          ],
          if (_profileTagline?.isNotEmpty == true) ...[
            _buildInfoCard(
              theme,
              title: 'Profil Sloganı',
              value: _profileTagline!,
              icon: Icons.short_text_rounded,
              description: 'Kendini tanımlayan kısa bir slogan',
            ),
            const SizedBox(height: 16),
          ],
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              '1 Yıllık Hedef',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Önümüzdeki 1 yıl içinde ulaşmak istediğin ana kariyer hedefini seç',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(
              context,
              _oneYearGoalOptions,
              _selectedOneYearGoal,
              (value) => setState(() => _selectedOneYearGoal = value),
            ),
            const SizedBox(height: 24),
            Text(
              '1 Yıllık Hedef Detayı',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu hedefle ilgili spesifik detayları paylaşmak ister misin? (İsteğe bağlı)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _oneYearGoalDetail,
              decoration: InputDecoration(
                hintText: 'Hedefle ilgili detayları buraya yazın...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
              onChanged: (value) => setState(() => _oneYearGoalDetail = value),
            ),
            const SizedBox(height: 24),
            Text(
              'Profil Sloganı',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kendini 1 cümleyle tanımlar mısın? (İsteğe bağlı)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _profileTagline,
              decoration: InputDecoration(
                hintText: 'Örn: Yenilikçi ve çözüm odaklı bir yazılım geliştiriciyim',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 2,
              onChanged: (value) => setState(() => _profileTagline = value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLongTermTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: '5 Yıllık Vizyon',
            value: _selectedFiveYearVision ?? 'Belirtilmemiş',
            icon: Icons.looks_5_rounded,
            description: 'Uzun vadede kariyerinde nerede olmak istediğin',
          ),
          const SizedBox(height: 16),
          if (_fiveYearVisionDetail?.isNotEmpty == true) ...[
            _buildInfoCard(
              theme,
              title: 'Vizyon Detayı',
              value: _fiveYearVisionDetail!,
              icon: Icons.edit_note_rounded,
              description: 'Uzun vadeli vizyonun hakkında ek detaylar',
            ),
            const SizedBox(height: 16),
          ],
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              '5 Yıllık Vizyon',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Uzun vadede, 5 yıl sonra kariyerinde nerede olmak istediğini seç',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(
              context,
              _fiveYearVisionOptions,
              _selectedFiveYearVision,
              (value) => setState(() => _selectedFiveYearVision = value),
            ),
            const SizedBox(height: 24),
            Text(
              '5 Yıllık Vizyon Detayı',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu vizyonla ilgili detayları paylaşmak ister misin? (İsteğe bağlı)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _fiveYearVisionDetail,
              decoration: InputDecoration(
                hintText: 'Vizyonla ilgili detayları buraya yazın...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
              onChanged: (value) => setState(() => _fiveYearVisionDetail = value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMotivationTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMultiInfoCard(
            theme,
            title: 'Motivasyon Kaynakları',
            values: _selectedMotivationSources,
            icon: Icons.favorite_rounded,
            description: 'Kariyerinde seni en çok motive eden faktörler',
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Motivasyon Kaynakları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kariyerinde seni en çok motive eden kaynakları seç (Birden fazla seçebilirsin)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildMultiSelector(
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
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required String description,
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
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: value == 'Belirtilmemiş'
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiInfoCard(
    ThemeData theme, {
    required String title,
    required List<String> values,
    required IconData icon,
    required String description,
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
            values.isEmpty
                ? Text(
                    'Belirtilmemiş',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: values.map((item) {
                      return Chip(
                        label: Text(item),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        labelStyle: TextStyle(color: theme.colorScheme.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
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

  Widget _buildMultiSelector(
    BuildContext context,
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
    );
  }
}
