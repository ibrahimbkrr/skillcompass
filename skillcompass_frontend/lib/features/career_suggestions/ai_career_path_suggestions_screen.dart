import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillcompass_frontend/features/profile/services/profile_service.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';

class AICareerPathSuggestionsScreen extends StatefulWidget {
  const AICareerPathSuggestionsScreen({super.key});

  @override
  State<AICareerPathSuggestionsScreen> createState() => _AICareerPathSuggestionsScreenState();
}

class _AICareerPathSuggestionsScreenState extends State<AICareerPathSuggestionsScreen> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  bool _isGenerating = false;
  String _error = '';

  // Kullanıcı verileri
  Map<String, dynamic>? _technicalProfile;
  Map<String, dynamic>? _learningStyle;
  Map<String, dynamic>? _careerVision;

  // Öneri sonuçları
  List<CareerPathSuggestion> _suggestions = [];
  
  // Form elemanları
  final _additionalInfoController = TextEditingController();
  String _selectedExperienceLevel = 'Orta Seviye';
  int _selectedTimeframe = 2;
  bool _includeRemoteOnly = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      // Kullanıcının profilini yükle
      _technicalProfile = await _profileService.loadTechnicalProfile();
      _learningStyle = await _profileService.loadLearningStyle();
      _careerVision = await _profileService.loadCareerVision();
      
      if (_technicalProfile == null) {
        _error = 'Lütfen önce teknik profilinizi tamamlayın';
      }
      
    } catch (e) {
      setState(() {
        _error = 'Kullanıcı verileri yüklenirken bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _generateSuggestions() async {
    if (_technicalProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Öneri oluşturmak için teknik profilinizi doldurmalısınız'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // Önerileri oluştur (gerçek projede API çağrısı yapılacak)
      await Future.delayed(const Duration(seconds: 2));
      
      // Kullanıcı verilerini kullanarak öneriler oluştur
      _suggestions = _createMockSuggestions();
      
      // Firestore'a kaydet
      await _saveSuggestionsToFirestore();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
  
  List<CareerPathSuggestion> _createMockSuggestions() {
    // Bu fonksiyon, gerçek API yerine mock veri üretir
    // Gerçek uygulamada backende istek gönderilecek
    
    final techs = _technicalProfile?['technologies'] as List<dynamic>? ?? [];
    final skills = techs.map((t) => t is Map ? t['name'] : t.toString()).toList();
    
    final interests = _careerVision?['interests'] as List<dynamic>? ?? [];
    
    return [
      CareerPathSuggestion(
        title: 'Full-Stack Yazılım Geliştirici',
        description: '${skills.take(3).join(", ")} becerilerinize dayalı olarak, full-stack geliştirme kariyeri sizin için ideal bir yol olabilir. Bu rol, hem frontend hem de backend bileşenlerle çalışmanızı gerektirir.',
        matchScore: 95,
        requiredSkills: [
          'JavaScript', 'React', 'Node.js', 'SQL', 'REST API'
        ],
        roadmap: [
          'Frontend framework\'lerinde uzmanlaş (${_getRandomFramework()})',
          'Backend teknolojilerini öğren (Express.js, Django veya Spring Boot)',
          'Veritabanı tasarımı ve optimizasyonu konusunda bilgi edin',
          'Bulut hizmetleri (AWS/Azure) öğren',
          'DevOps prensiplerini uygula',
        ],
        salary: '\$70,000 - \$120,000',
        demandTrend: 'Yükselen',
        remotePotential: 'Yüksek',
      ),
      CareerPathSuggestion(
        title: 'Veri Bilimci',
        description: 'Analitik düşünce yapınız ve matematik/istatistik ilginiz, veri bilimi alanında başarılı olmanızı sağlayabilir.',
        matchScore: 88,
        requiredSkills: [
          'Python', 'R', 'SQL', 'İstatistik', 'Veri Görselleştirme'
        ],
        roadmap: [
          'Python ile veri analizi kütüphanelerini öğren (Pandas, NumPy)',
          'Makine öğrenimi algoritmaları ve uygulamaları konusunda bilgi edin',
          'SQL ile veri sorgulama becerilerini geliştir',
          'Veri görselleştirme araçlarını öğren (Tableau, Power BI)',
          'Büyük veri teknolojilerine giriş yap (Spark, Hadoop)',
        ],
        salary: '\$80,000 - \$140,000',
        demandTrend: 'Çok Yüksek',
        remotePotential: 'Orta-Yüksek',
      ),
      CareerPathSuggestion(
        title: 'DevOps Mühendisi',
        description: 'Sistem yönetimi ve otomasyon ilginiz, DevOps alanında başarılı olmanıza katkı sağlayabilir.',
        matchScore: 82,
        requiredSkills: [
          'Linux', 'Docker', 'Kubernetes', 'CI/CD', 'Bulut Hizmetleri'
        ],
        roadmap: [
          'Linux sistem yönetimi becerilerini geliştir',
          'Konteyner teknolojilerini öğren (Docker, Kubernetes)',
          'CI/CD pipeline\'ları kurmayı öğren (Jenkins, GitLab CI)',
          'Tercihen AWS, Azure veya GCP gibi bir bulut platformunda uzmanlaş',
          'Altyapı-Kod (Infrastructure as Code) yaklaşımını benimse',
        ],
        salary: '\$90,000 - \$130,000',
        demandTrend: 'Yüksek',
        remotePotential: 'Çok Yüksek',
      ),
    ];
  }
  
  String _getRandomFramework() {
    final frameworks = ['React', 'Vue.js', 'Angular', 'Svelte'];
    frameworks.shuffle();
    return frameworks.first;
  }
  
  Future<void> _saveSuggestionsToFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final suggestionsData = _suggestions.map((s) => s.toMap()).toList();
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('career_data')
          .doc('suggestions')
          .set({
            'suggestions': suggestionsData,
            'created_at': FieldValue.serverTimestamp(),
            'parameters': {
              'experience_level': _selectedExperienceLevel,
              'timeframe': _selectedTimeframe,
              'remote_only': _includeRemoteOnly,
              'additional_info': _additionalInfoController.text,
            }
          }, SetOptions(merge: true));
      
    } catch (e) {
      throw Exception('Öneriler kaydedilirken hata oluştu: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kariyer Yolu Önerileri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _error.isNotEmpty
              ? Center(child: ErrorMessage(message: _error))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildParametersCard(theme),
                      const SizedBox(height: 16),
                      if (_isGenerating) 
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              children: [
                                LoadingIndicator(),
                                SizedBox(height: 16),
                                Text('Kariyer önerileri oluşturuluyor...\nLütfen bekleyin'),
                              ],
                            ),
                          ),
                        )
                      else if (_suggestions.isNotEmpty)
                        ..._suggestions.map((suggestion) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildSuggestionCard(suggestion, theme),
                          ),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.insights,
                                  size: 64,
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Kariyer yolu önerilerinizi görmek için tercihleri yapın ve "Önerileri Oluştur" butonuna basın',
                                  style: theme.textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: _suggestions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Öneriler kaydedildi. Sonuçları profil sayfanızdan görüntüleyebilirsiniz.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              label: const Text('Sonuçları Kaydet'),
              icon: const Icon(Icons.save),
            )
          : null,
    );
  }
  
  Widget _buildParametersCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kariyer Önerisi Parametreleri',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Deneyim Seviyesi
            Text(
              'Deneyim Seviyesi',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedExperienceLevel,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: [
                'Başlangıç Seviyesi',
                'Orta Seviye',
                'İleri Seviye',
                'Uzman Seviye',
              ].map((level) => DropdownMenuItem(
                value: level,
                child: Text(level),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedExperienceLevel = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Zaman Çerçevesi
            Text(
              'Hedeflenen Zaman Çerçevesi (Yıl)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _selectedTimeframe.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_selectedTimeframe yıl',
              onChanged: (value) {
                setState(() {
                  _selectedTimeframe = value.toInt();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 yıl', style: theme.textTheme.bodySmall),
                Text('5 yıl', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            
            // Uzaktan Çalışma
            Row(
              children: [
                Checkbox(
                  value: _includeRemoteOnly,
                  onChanged: (value) {
                    setState(() {
                      _includeRemoteOnly = value ?? false;
                    });
                  },
                ),
                const Text('Sadece uzaktan çalışmaya uygun rolleri göster'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Ek Bilgiler
            Text(
              'Ek Bilgiler ve Tercihleriniz',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _additionalInfoController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Özel tercihleriniz, ilgi alanlarınız veya hedefleriniz...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateSuggestions,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isGenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Önerileri Oluştur'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestionCard(CareerPathSuggestion suggestion, ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Eşleşme Skoru
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_graph,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${suggestion.matchScore}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // İçerik
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Açıklama
                Text(
                  suggestion.description,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                
                // Gerekli Beceriler
                Text(
                  'Gerekli Beceriler',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestion.requiredSkills.map((skill) => Chip(
                    label: Text(skill),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                
                // Yol Haritası
                Text(
                  'Kariyer Yol Haritası',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: suggestion.roadmap.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                
                // Alt Bilgiler
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Maaş Aralığı',
                        suggestion.salary,
                        Icons.payments,
                        theme,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Talep Trendi',
                        suggestion.demandTrend,
                        Icons.trending_up,
                        theme,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Uzaktan Çalışma',
                        suggestion.remotePotential,
                        Icons.home_work,
                        theme,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Alt Butonlar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Favorilere ekleme işlevi
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favorilere eklendi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Favorilere Ekle'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // Detaylı bilgi gösterme işlevi
                    _showDetailsDialog(suggestion, theme);
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Detaylar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(String title, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.secondary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  void _showDetailsDialog(CareerPathSuggestion suggestion, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(suggestion.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Eğitim Kaynakları',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('• Udemy - The Complete Web Developer Course'),
                const Text('• Coursera - Google IT Automation with Python'),
                const Text('• freeCodeCamp - Responsive Web Design'),
                const Text('• edX - CS50\'s Introduction to Computer Science'),
                const SizedBox(height: 16),
                
                Text(
                  'Sektör Trendi',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('Bu alandaki işler önümüzdeki 5 yıl boyunca %22 büyüme gösterecek. Özellikle uzaktan çalışma pozisyonları artış gösteriyor.'),
                const SizedBox(height: 16),
                
                Text(
                  'Tahmini Zaman Çizelgesi',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('• 3-6 ay: Temel becerileri öğrenme'),
                const Text('• 6-12 ay: Junior seviye rol için hazırlık'),
                const Text('• 1-2 yıl: İlk profesyonel deneyim'),
                const Text('• 2-3 yıl: Orta seviye rollere geçiş'),
                const Text('• 3-5 yıl: Deneyimli profesyonel seviye'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}

// Kariyer önerisi veri yapısı
class CareerPathSuggestion {
  final String title;
  final String description;
  final int matchScore;
  final List<String> requiredSkills;
  final List<String> roadmap;
  final String salary;
  final String demandTrend;
  final String remotePotential;
  
  CareerPathSuggestion({
    required this.title,
    required this.description,
    required this.matchScore,
    required this.requiredSkills,
    required this.roadmap,
    required this.salary,
    required this.demandTrend,
    required this.remotePotential,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'match_score': matchScore,
      'required_skills': requiredSkills,
      'roadmap': roadmap,
      'salary': salary,
      'demand_trend': demandTrend,
      'remote_potential': remotePotential,
    };
  }
} 