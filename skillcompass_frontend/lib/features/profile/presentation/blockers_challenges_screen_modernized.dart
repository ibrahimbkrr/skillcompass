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

class BlockersChallengesScreen extends StatefulWidget {
  const BlockersChallengesScreen({super.key});

  @override
  State<BlockersChallengesScreen> createState() => _BlockersChallengesScreenState();
}

class _BlockersChallengesScreenState extends State<BlockersChallengesScreen> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';
  bool _isEditMode = false;
  late TabController _tabController;

  // Form Alanları
  // Soru 1
  final Map<String, bool> _struggledTopicsOptions = {
    'Algoritmalar ve Veri Yapıları': false,
    'Backend Geliştirme / API Tasarımı': false,
    'Frontend Geliştirme / UI-UX': false,
    'Veritabanı Yönetimi / Sorgulama': false,
    'Mobil Uygulama Geliştirme': false,
    'DevOps / CI/CD / Cloud Teknolojileri': false,
    'Test Yazma / Hata Ayıklama (Debugging)': false,
    'State Yönetimi (Frontend/Mobil)': false,
    'Asenkron Programlama': false,
    'Git / Versiyon Kontrolü': false,
    'Sistem Tasarımı / Mimari': false,
    'Matematik / İstatistik Temelleri': false,
    'Diğer (Açıklayınız)': false,
  };
  final TextEditingController _topicDetailsController = TextEditingController();

  // Soru 2
  final Map<String, bool> _progressionBlockersOptions = {
    'Net bir öğrenme/kariyer planım yok': false,
    'Motivasyon eksikliği / Erteleme': false,
    'Kafa karışıklığı / Nereden başlayacağımı bilememe': false,
    'Yeterli zaman bulamama': false,
    'Yeterince pratik yapamama / Proje bulamama': false,
    'Kaynak yetersizliği / Doğru kaynağı bulamama': false,
    'Teknik zorluklar / Konuları anlayamama': false,
    'Çevremde destek / mentor eksikliği': false,
    'Kendine güvensizlik / "Yeterli değilim" hissi': false,
  };

  // Soru 3
  String? _feelingStuckStatus;
  final List<String> _feelingStuckOptions = ['Evet', 'Hayır', 'Bazen'];
  final TextEditingController _feelingStuckDetailsController = TextEditingController();

  // Soru 4
  final Map<String, bool> _codingChallengesOptions = {
    'Hataları Ayıklama (Debugging)': false,
    'Algoritma Tasarlama / Problem Çözme': false,
    'Kod Organizasyonu / Temiz Kod Yazma': false,
    'Yeni Kütüphane/Framework Öğrenme': false,
    'Boş Sayfa Sendromu / Nereden Başlayacağını Bilememe': false,
    'Performans Optimizasyonu': false,
    'Asenkron İşlemleri Yönetme': false,
    'Diğer (Açıklayınız)': false,
  };
  final TextEditingController _otherCodingChallengeController = TextEditingController();

  // Soru 5
  final TextEditingController _priorityLearnTopicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedData();
  }

  @override
  void dispose() {
    _topicDetailsController.dispose();
    _feelingStuckDetailsController.dispose();
    _otherCodingChallengeController.dispose();
    _priorityLearnTopicController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      final data = await _profileService.loadBlockersChallenges();
      
      if (data != null) {
        _updateStateWithLoadedData(data);
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

  void _updateStateWithLoadedData(Map<String, dynamic> data) {
    setState(() {
      List<String> savedTopics = List<String>.from(
        data['struggledTopics'] ?? [],
      );
      _struggledTopicsOptions.forEach((key, value) {
        _struggledTopicsOptions[key] = savedTopics.contains(key);
      });
      _topicDetailsController.text = data['struggledTopicsDetails'] ?? '';
      
      List<String> savedBlockers = List<String>.from(
        data['progressionBlockers'] ?? [],
      );
      _progressionBlockersOptions.forEach((key, value) {
        _progressionBlockersOptions[key] = savedBlockers.contains(key);
      });
      
      _feelingStuckStatus = data['feelingStuckStatus'];
      if (!_feelingStuckOptions.contains(_feelingStuckStatus))
        _feelingStuckStatus = null;
      _feelingStuckDetailsController.text = data['feelingStuckDetails'] ?? '';
      
      List<String> savedChallenges = List<String>.from(
        data['codingChallenges'] ?? [],
      );
      _codingChallengesOptions.forEach((key, value) {
        _codingChallengesOptions[key] = savedChallenges.contains(key);
      });
      
      _otherCodingChallengeController.text = data['otherCodingChallenge'] ?? '';
      _priorityLearnTopicController.text = data['priorityLearnTopic'] ?? '';
    });
  }

  Future<void> _saveToFirestore() async {
    setState(() => _isSaving = true);
    
    try {
      List<String> selectedStruggledTopics = _struggledTopicsOptions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
          
      List<String> selectedProgressionBlockers = _progressionBlockersOptions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
          
      List<String> selectedCodingChallenges = _codingChallengesOptions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
    
      final data = {
        'struggledTopics': selectedStruggledTopics,
        'struggledTopicsDetails': _topicDetailsController.text,
        'progressionBlockers': selectedProgressionBlockers,
        'feelingStuckStatus': _feelingStuckStatus,
        'feelingStuckDetails': _feelingStuckDetailsController.text,
        'codingChallenges': selectedCodingChallenges,
        'otherCodingChallenge': _otherCodingChallengeController.text,
        'priorityLearnTopic': _priorityLearnTopicController.text,
      };
    
      await _profileService.saveBlockersChallenges(data);
    
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zorluklar ve engeller başarıyla kaydedildi!'),
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
        title: const Text('Zorluklar & Engeller'),
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
                          Tab(text: 'Teknik Zorluklar'),
                          Tab(text: 'İlerleme Engelleri'),
                          Tab(text: 'Öncelikler'),
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
                          _buildTechnicalChallengesTab(theme),
                          _buildProgressionBlockersTab(theme),
                          _buildPrioritiesTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTechnicalChallengesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: 'Zorlandığınız Teknik Konular',
            icon: Icons.code,
            description: 'Öğrenirken veya uygulama yaparken zorlandığınız teknik konular',
            content: _buildSelectedItemsList(_struggledTopicsOptions, theme),
          ),
          const SizedBox(height: 16),
          if (_topicDetailsController.text.isNotEmpty) 
            _buildInfoCard(
              theme,
              title: 'Teknik Zorluk Detayları',
              icon: Icons.description,
              description: 'Zorlandığınız teknik konularla ilgili ek açıklamalar',
              content: Text(
                _topicDetailsController.text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          const SizedBox(height: 16),
          _buildInfoCard(
            theme,
            title: 'Kod Yazarken Karşılaştığınız Zorluklar',
            icon: Icons.bug_report,
            description: 'Kod yazarken sık karşılaştığınız zorluklar',
            content: _buildSelectedItemsList(_codingChallengesOptions, theme),
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Zorlandığınız Teknik Konular',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Öğrenirken veya uygulama yaparken zorlandığınız teknik konuları seçin',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckboxList(_struggledTopicsOptions, theme),
            const SizedBox(height: 24),
            Text(
              'Teknik Zorluk Detayları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _topicDetailsController,
              decoration: InputDecoration(
                hintText: 'Zorlandığınız teknik konularla ilgili detayları buraya yazabilirsiniz...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Kod Yazarken Karşılaştığınız Zorluklar',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kod yazarken sık karşılaştığınız zorlukları seçin',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckboxList(_codingChallengesOptions, theme),
            const SizedBox(height: 24),
            Text(
              'Diğer Kodlama Zorlukları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _otherCodingChallengeController,
              decoration: InputDecoration(
                hintText: 'Belirtilmeyen başka kodlama zorluklarınız varsa yazabilirsiniz...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressionBlockersTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: 'İlerleme Engelleriniz',
            icon: Icons.block,
            description: 'Kariyerinizde ilerlemenizi engelleyen faktörler',
            content: _buildSelectedItemsList(_progressionBlockersOptions, theme),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            theme,
            title: 'Takılma Hissi',
            icon: Icons.psychology,
            description: 'Öğrenme sürecinizde takıldığınızı veya duraksadığınızı hissediyor musunuz?',
            content: Text(
              _feelingStuckStatus ?? 'Belirtilmemiş',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _feelingStuckStatus == null
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (_feelingStuckDetailsController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              theme,
              title: 'Takılma Hissi Detayları',
              icon: Icons.comment,
              description: 'Takıldığınız konularla ilgili detaylar',
              content: Text(
                _feelingStuckDetailsController.text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'İlerleme Engelleriniz',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kariyerinizde ilerlemenizi engelleyen faktörleri seçin',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckboxList(_progressionBlockersOptions, theme),
            const SizedBox(height: 24),
            Text(
              'Takılma Hissi',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Öğrenme sürecinizde takıldığınızı veya duraksadığınızı hissediyor musunuz?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(
              context,
              _feelingStuckOptions,
              _feelingStuckStatus,
              (value) => setState(() => _feelingStuckStatus = value),
            ),
            const SizedBox(height: 24),
            Text(
              'Takılma Hissi Detayları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _feelingStuckDetailsController,
              decoration: InputDecoration(
                hintText: 'Takıldığınız konularla ilgili detayları yazabilirsiniz...',
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

  Widget _buildPrioritiesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            theme,
            title: 'Öncelikli Öğrenmek İstediğiniz Konu',
            icon: Icons.priority_high,
            description: 'Şu anda öncelikli olarak öğrenmek istediğiniz teknik konu',
            content: Text(
              _priorityLearnTopicController.text.isEmpty
                  ? 'Belirtilmemiş'
                  : _priorityLearnTopicController.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _priorityLearnTopicController.text.isEmpty
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 24),
            Text(
              'Öncelikli Öğrenmek İstediğiniz Konu',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Şu anda öncelikli olarak öğrenmek istediğiniz teknik konuyu yazın',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priorityLearnTopicController,
              decoration: InputDecoration(
                hintText: 'Örn: React.js, Flutter, Machine Learning, AWS, Docker...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 2,
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