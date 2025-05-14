import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skillcompass_frontend/features/profile/services/profile_service.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';

class SkillRadarChartScreen extends StatefulWidget {
  const SkillRadarChartScreen({super.key});

  @override
  State<SkillRadarChartScreen> createState() => _SkillRadarChartScreenState();
}

class _SkillRadarChartScreenState extends State<SkillRadarChartScreen> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  String _error = '';
  
  // Kullanıcının becerileri
  Map<String, double> _skillLevels = {};
  List<String> _skillCategories = [];
  
  // Kullanıcının teknoloji deneyimleri
  List<Map<String, dynamic>> _technologies = [];
  
  // İlerleme hedefleri
  Map<String, double> _targetLevels = {};
  
  @override
  void initState() {
    super.initState();
    _loadUserSkills();
  }
  
  Future<void> _loadUserSkills() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      // Teknik profili yükle
      final technicalProfile = await _profileService.loadTechnicalProfile();
      if (technicalProfile == null) {
        setState(() {
          _error = 'Teknik profil bulunamadı. Lütfen önce teknik profilinizi tamamlayın.';
          _isLoading = false;
        });
        return;
      }
      
      // Teknolojileri çıkarıp düzenle
      final techs = technicalProfile['technologies'] as List<dynamic>? ?? [];
      _technologies = techs.map((tech) {
        if (tech is Map<String, dynamic>) {
          return tech;
        } else {
          return {
            'name': tech.toString(),
            'level': 3.0,
            'category': 'Diğer'
          };
        }
      }).toList();
      
      // Ana yetenek alanlarını topla
      Map<String, List<double>> categoryScores = {};
      
      for (var tech in _technologies) {
        String category = tech['category'] ?? 'Diğer';
        double level = (tech['level'] ?? 3.0).toDouble();
        
        if (!categoryScores.containsKey(category)) {
          categoryScores[category] = [];
        }
        categoryScores[category]!.add(level);
      }
      
      // Her kategori için ortalama skor hesapla
      categoryScores.forEach((category, scores) {
        double sum = scores.reduce((a, b) => a + b);
        double average = sum / scores.length;
        _skillLevels[category] = average;
      });
      
      // Hedef seviyeler (default olarak mevcut seviyeden +1)
      _skillLevels.forEach((key, value) {
        _targetLevels[key] = value < 4.0 ? value + 1.0 : 5.0;
      });
      
      // Kategorileri alfabetik sırala
      _skillCategories = _skillLevels.keys.toList()..sort();
      
      // Eğer yeterli veri yoksa varsayılan kategorileri ekle
      if (_skillCategories.length < 5) {
        final defaultCategories = [
          'Frontend', 'Backend', 'Mobil', 'Veri', 'DevOps'
        ];
        
        for (var category in defaultCategories) {
          if (!_skillLevels.containsKey(category)) {
            _skillLevels[category] = 1.0;
            _targetLevels[category] = 2.0;
          }
        }
        
        _skillCategories = _skillLevels.keys.toList()..sort();
      }
      
    } catch (e) {
      setState(() {
        _error = 'Beceri verileri yüklenirken bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beceri Radar Haritası'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserSkills,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditSkillsDialog(context),
            tooltip: 'Becerileri Düzenle',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: LoadingIndicator())
        : _error.isNotEmpty
            ? Center(child: ErrorMessage(message: _error))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Beceri Dağılımı',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Farklı alanlardaki yetkinlik seviyeleriniz',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 300,
                              child: _buildRadarChart(theme),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(
                                  'Mevcut Seviye', 
                                  theme.colorScheme.primary,
                                  theme,
                                ),
                                const SizedBox(width: 24),
                                _buildLegendItem(
                                  'Hedef Seviye', 
                                  theme.colorScheme.secondary.withOpacity(0.7),
                                  theme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
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
                                'Gelişim Alanları',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: _skillCategories.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final category = _skillCategories[index];
                                    final level = _skillLevels[category] ?? 0;
                                    final target = _targetLevels[category] ?? level + 1;
                                    
                                    return _buildSkillProgressItem(
                                      category, 
                                      level, 
                                      target,
                                      theme,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRecommendationsDialog,
        label: const Text('Gelişim Önerileri'),
        icon: const Icon(Icons.lightbulb),
      ),
    );
  }
  
  Widget _buildRadarChart(ThemeData theme) {
    if (_skillCategories.isEmpty) {
      return const Center(child: Text('Henüz beceri verisi yok'));
    }
    
    return RadarChart(
      RadarChartData(
        radarBorderData: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        tickBorderData: const BorderSide(color: Colors.transparent),
        gridBorderData: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2), 
          width: 1,
        ),
        
        // Radar grafiği ölçeklendirilmesi
        radarBackgroundColor: theme.colorScheme.primary.withOpacity(0.05),
        ticksTextStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          fontSize: 10,
        ),
        
        // Ana tablo özellikleri
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: TextStyle(
          color: theme.colorScheme.onSurface, 
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        
        // Veri noktaları
        dataSets: [
          // Mevcut seviye
          RadarDataSet(
            fillColor: theme.colorScheme.primary.withOpacity(0.2),
            borderColor: theme.colorScheme.primary,
            entryRadius: 3,
            dataEntries: _skillCategories.map((category) {
              return RadarEntry(value: _skillLevels[category] ?? 0);
            }).toList(),
          ),
          
          // Hedef seviye
          RadarDataSet(
            fillColor: Colors.transparent,
            borderColor: theme.colorScheme.secondary.withOpacity(0.7),
            borderWidth: 2,
            entryRadius: 2,
            dataEntries: _skillCategories.map((category) {
              return RadarEntry(value: _targetLevels[category] ?? (_skillLevels[category] ?? 0) + 1);
            }).toList(),
          ),
        ],
        
        // Eksen ve ölçek
        tickCount: 5,
        ticksTextStyle: TextStyle(
          color: Colors.transparent,
          fontSize: 0,
        ),
        
        // Etiketler
        getTitle: (index, angle) {
          if (index >= _skillCategories.length) {
            return '';
          }
          return _skillCategories[index];
        },
      ),
      swapAnimationDuration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildSkillProgressItem(
    String category, 
    double level, 
    double target,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                '${level.toStringAsFixed(1)}/5.0',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              // Arka plan
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              
              // Mevcut seviye
              FractionallySizedBox(
                widthFactor: level / 5.0,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              
              // Hedef seviye
              Positioned(
                left: (target / 5.0) * MediaQuery.of(context).size.width * 0.7 - 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Başlangıç',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                'Uzman',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showEditSkillsDialog(BuildContext context) {
    final theme = Theme.of(context);
    Map<String, double> editedLevels = Map.from(_skillLevels);
    Map<String, double> editedTargets = Map.from(_targetLevels);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Beceri Seviyelerini Düzenle'),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setState) {
                return ListView(
                  shrinkWrap: true,
                  children: _skillCategories.map((category) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Mevcut:',
                              style: theme.textTheme.bodySmall,
                            ),
                            Expanded(
                              child: Slider(
                                value: editedLevels[category] ?? 1.0,
                                min: 1.0,
                                max: 5.0,
                                divisions: 8,
                                label: (editedLevels[category] ?? 1.0).toStringAsFixed(1),
                                onChanged: (value) {
                                  setState(() {
                                    editedLevels[category] = value;
                                    // Hedef seviye mevcut seviyeden küçük olamaz
                                    if ((editedTargets[category] ?? 1.0) < value) {
                                      editedTargets[category] = value;
                                    }
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: Text(
                                (editedLevels[category] ?? 1.0).toStringAsFixed(1),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Hedef:  ',
                              style: theme.textTheme.bodySmall,
                            ),
                            Expanded(
                              child: Slider(
                                value: editedTargets[category] ?? 1.0,
                                min: 1.0,
                                max: 5.0,
                                divisions: 8,
                                activeColor: theme.colorScheme.secondary,
                                label: (editedTargets[category] ?? 1.0).toStringAsFixed(1),
                                onChanged: (value) {
                                  setState(() {
                                    // Hedef seviye mevcut seviyeden küçük olamaz
                                    if (value >= (editedLevels[category] ?? 1.0)) {
                                      editedTargets[category] = value;
                                    }
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: Text(
                                (editedTargets[category] ?? 1.0).toStringAsFixed(1),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                );
              }
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _skillLevels = editedLevels;
                  _targetLevels = editedTargets;
                });
                Navigator.pop(context);
                
                // Firestore'a kaydet
                _saveSkillLevels();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _saveSkillLevels() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('skill_radar_chart')
          .set({
            'skill_levels': _skillLevels,
            'target_levels': _targetLevels,
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beceriler başarıyla kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showRecommendationsDialog() {
    final theme = Theme.of(context);
    
    // Analiz: en düşük ve en yüksek beceriler, gelişim önerileri
    List<MapEntry<String, double>> sortedSkills = _skillLevels.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    List<String> weakestSkills = sortedSkills.take(2).map((e) => e.key).toList();
    List<String> strongestSkills = sortedSkills.reversed.take(2).map((e) => e.key).toList();
    
    // Beceri geliştirme önerileri
    Map<String, List<String>> developmentSuggestions = {
      'Frontend': [
        "Modern JavaScript framework'leri öğrenin (React, Vue, Angular)",
        'CSS Grid ve Flexbox ile responsive tasarım yapın',
        'Web performans optimizasyonu konusunda uzmanlaşın',
      ],
      'Backend': [
        'REST API tasarım prensiplerine odaklanın',
        'Veritabanı optimizasyonu ve sorgu performansını geliştirin',
        'Güvenlik ve kimlik doğrulama konusunda uzmanlaşın',
      ],
      'Mobil': [
        'Çapraz platform çözümleri öğrenin (Flutter, React Native)',
        'Yerel cihaz özelliklerini kullanma konusunda uygulama geliştirin',
        'Mobil UX tasarım prensiplerini çalışın',
      ],
      'Veri': [
        'Veri görselleştirme araçlarını öğrenin',
        'Basit makine öğrenimi modellerini anlamaya çalışın',
        'SQL ve NoSQL veritabanlarıyla çalışın',
      ],
      'DevOps': [
        'Docker ve konteynerizasyon öğrenin',
        'CI/CD pipeline\'ları kurun',
        'Bulut servislerinde (AWS, Azure, GCP) temel bilgiler edinin',
      ],
      'Diğer': [
        'Açık kaynak projelere katkıda bulunun',
        'Daha fazla yan proje geliştirin',
        'Teknoloji blogları ve makaleler takip edin',
      ],
    };
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Gelişim Önerileri',
            style: theme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                
                // Beceri dengesi analizi
                Text(
                  'Beceri Dengesi Analizi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Zayıf alanlar
                if (weakestSkills.isNotEmpty) ...[
                  Text(
                    'Geliştirmeniz Gereken Alanlar:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...weakestSkills.map((skill) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_circle_up,
                            color: theme.colorScheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$skill (${_skillLevels[skill]?.toStringAsFixed(1) ?? "0.0"}/5.0)',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
                
                // Güçlü alanlar
                if (strongestSkills.isNotEmpty) ...[
                  Text(
                    'Güçlü Olduğunuz Alanlar:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...strongestSkills.map((skill) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$skill (${_skillLevels[skill]?.toStringAsFixed(1) ?? "0.0"}/5.0)',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
                
                // Gelişim önerileri
                if (weakestSkills.isNotEmpty) ...[
                  Text(
                    'Gelişim Önerileri',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...weakestSkills.map((skill) {
                    List<String> suggestions = developmentSuggestions[skill] ?? 
                        developmentSuggestions['Diğer'] ?? 
                        ['Projeler geliştirin', 'Eğitim materyalleri takip edin'];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          ...suggestions.map((suggestion) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      suggestion,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
                
                // Genel tavsiye
                Divider(color: theme.colorScheme.outline.withOpacity(0.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dengeli bir beceri seti, iş piyasasında daha değerli olmanızı sağlar.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anladım'),
            ),
          ],
        );
      },
    );
  }
} 