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

class InnerObstaclesScreen extends StatefulWidget {
  const InnerObstaclesScreen({super.key});

  @override
  State<InnerObstaclesScreen> createState() => _InnerObstaclesScreenState();
}

class _InnerObstaclesScreenState extends State<InnerObstaclesScreen> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';
  bool _isEditMode = false;
  late TabController _tabController;

  // Form Alanları
  // Soru 1
  final Map<String, bool> _internalBlockersOptions = {
    'Kendime Yeterince İnanmıyorum / Yetersizlik Hissi': false,
    'Mükemmeliyetçilik (Başlayamama/Bitirememe)': false,
    'Kendimi Başkalarıyla Kıyaslama': false,
    'Erteleme Alışkanlığı / Zaman Yönetimi Zorluğu': false,
    'Kararsızlık / Odaklanma Güçlüğü': false,
    'Yeni Şeylere Başlamaktan Çekinme': false,
    'Motivasyon Eksikliği / İsteksizlik': false,
    'Eleştirilme veya Yargılanma Korkusu': false,
    'Diğer (Açıklayınız)': false,
  };
  final TextEditingController _otherInternalBlockerController = TextEditingController();

  // Soru 2
  String? _fearOfFailureStatus;
  final List<String> _fearOfFailureOptions = ['Evet', 'Hayır', 'Bazen'];
  final TextEditingController _fearOfFailureDetailsController = TextEditingController();

  // Soru 3
  final TextEditingController _gaveUpSituationController = TextEditingController();

  // Soru 4
  final TextEditingController _prerequisiteBeliefController = TextEditingController();

  // Soru 5
  final TextEditingController _appExpectationController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedData();
  }

  @override
  void dispose() {
    _otherInternalBlockerController.dispose();
    _fearOfFailureDetailsController.dispose();
    _gaveUpSituationController.dispose();
    _prerequisiteBeliefController.dispose();
    _appExpectationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      final data = await _profileService.loadInnerObstacles();
      
      if (data != null) {
        _updateStateWithLoadedData(data);
      }
    } catch (e) {
      setState(() {
        _error = 'İç engeller verileri yüklenirken bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateStateWithLoadedData(Map<String, dynamic> data) {
    setState(() {
      // Soru 1
      List<String> savedBlockers = List<String>.from(
        data['internalBlockers'] ?? [],
      );
      _internalBlockersOptions.forEach((key, value) {
        _internalBlockersOptions[key] = savedBlockers.contains(key);
      });
      _otherInternalBlockerController.text = data['otherInternalBlocker'] ?? '';
      
      // Soru 2
      _fearOfFailureStatus = data['fearOfFailureStatus'];
      if (!_fearOfFailureOptions.contains(_fearOfFailureStatus))
        _fearOfFailureStatus = null;
      _fearOfFailureDetailsController.text = data['fearOfFailureDetails'] ?? '';
      
      // Soru 3
      _gaveUpSituationController.text = data['gaveUpSituation'] ?? '';
      
      // Soru 4
      _prerequisiteBeliefController.text = data['prerequisiteBelief'] ?? '';
      
      // Soru 5
      _appExpectationController.text = data['appExpectation'] ?? '';
    });
  }

  Future<void> _saveToFirestore() async {
    setState(() => _isSaving = true);
    
    try {
      List<String> selectedInternalBlockers = _internalBlockersOptions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
      
      final data = {
        'internalBlockers': selectedInternalBlockers,
        'otherInternalBlocker': _otherInternalBlockerController.text,
        'fearOfFailureStatus': _fearOfFailureStatus,
        'fearOfFailureDetails': _fearOfFailureDetailsController.text,
        'gaveUpSituation': _gaveUpSituationController.text,
        'prerequisiteBelief': _prerequisiteBeliefController.text,
        'appExpectation': _appExpectationController.text,
      };
    
      await _profileService.saveInnerObstacles(data);
    
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İç engeller bilgileriniz başarıyla kaydedildi!'),
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
        title: const Text('İç Engeller'),
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
                          Tab(text: 'İç Engeller'),
                          Tab(text: 'Başarısızlık Korkusu'),
                          Tab(text: 'İnançlar ve Beklentiler'),
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
                          _buildInternalObstaclesTab(theme),
                          _buildFearOfFailureTab(theme),
                          _buildBeliefsExpectationsTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInternalObstaclesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: 'İç Engellerim',
            icon: Icons.psychology,
            description: 'Gelişiminizi engelleyen içsel faktörler',
            content: _buildSelectedItemsList(_internalBlockersOptions, theme),
          ),
          const SizedBox(height: 16),
          if (_otherInternalBlockerController.text.isNotEmpty) 
            _buildInfoCard(
              theme,
              title: 'Diğer İç Engeller',
              icon: Icons.more_horiz,
              description: 'Belirtilen engeller dışındaki içsel engelleriniz',
              content: Text(
                _otherInternalBlockerController.text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'İç Engelleriniz',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sizi engelleyen içsel faktörleri seçin',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckboxList(_internalBlockersOptions, theme),
            const SizedBox(height: 24),
            Text(
              'Diğer İç Engel Detayları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _otherInternalBlockerController,
              decoration: InputDecoration(
                hintText: 'Yukarıdaki seçeneklerde belirtilmeyen iç engellerinizi yazabilirsiniz...',
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

  Widget _buildFearOfFailureTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: 'Başarısızlık Korkusu',
            icon: Icons.warning,
            description: 'Başarısız olma kaygısı yaşıyor musunuz?',
            content: Text(
              _fearOfFailureStatus ?? 'Belirtilmemiş',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _fearOfFailureStatus == null
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (_fearOfFailureDetailsController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              theme,
              title: 'Başarısızlık Korkusu Detayları',
              icon: Icons.comment,
              description: 'Başarısızlık korkusuna dair deneyimleriniz',
              content: Text(
                _fearOfFailureDetailsController.text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildInfoCard(
            theme,
            title: 'Vazgeçtiğiniz Durumlar',
            icon: Icons.cancel,
            description: 'Zorlandığınız için vazgeçtiğiniz projeler veya öğrenme süreçleri',
            content: Text(
              _gaveUpSituationController.text.isEmpty 
                ? 'Belirtilmemiş' 
                : _gaveUpSituationController.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _gaveUpSituationController.text.isEmpty
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Başarısızlık Korkusu',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Başarısız olma kaygısı yaşıyor musunuz?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(
              context,
              _fearOfFailureOptions,
              _fearOfFailureStatus,
              (value) => setState(() => _fearOfFailureStatus = value),
            ),
            const SizedBox(height: 24),
            Text(
              'Başarısızlık Korkusu Detayları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fearOfFailureDetailsController,
              decoration: InputDecoration(
                hintText: 'Başarısızlık korkusuyla ilgili deneyimlerinizi yazabilirsiniz...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Vazgeçtiğiniz Durumlar',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _gaveUpSituationController,
              decoration: InputDecoration(
                hintText: 'Zorlandığınız için vazgeçtiğiniz projeler veya öğrenme süreçlerini yazabilirsiniz...',
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

  Widget _buildBeliefsExpectationsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: 'Ön Koşul İnancım',
            icon: Icons.lightbulb,
            description: 'Yazılımda ilerlemek için sahip olmak gerektiğine inandığınız ön koşullar',
            content: Text(
              _prerequisiteBeliefController.text.isEmpty 
                ? 'Belirtilmemiş' 
                : _prerequisiteBeliefController.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _prerequisiteBeliefController.text.isEmpty
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            theme,
            title: 'Uygulama Beklentileriniz',
            icon: Icons.star,
            description: 'SkillCompass uygulamasından beklentileriniz',
            content: Text(
              _appExpectationController.text.isEmpty 
                ? 'Belirtilmemiş' 
                : _appExpectationController.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _appExpectationController.text.isEmpty
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Ön Koşul İnancınız',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Yazılımda ilerlemek için sahip olmak gerektiğine inandığınız ön koşullar',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prerequisiteBeliefController,
              decoration: InputDecoration(
                hintText: 'Örnek: Matematik yeteneği, özel bir eğitim, belirli bir zeka seviyesi...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Uygulama Beklentileriniz',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'SkillCompass uygulamasından beklentileriniz',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _appExpectationController,
              decoration: InputDecoration(
                hintText: 'SkillCompass uygulamasından beklentilerinizi yazabilirsiniz...',
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
} 