import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LearningThinkingStyleScreen extends StatefulWidget {
  const LearningThinkingStyleScreen({super.key});

  @override
  State<LearningThinkingStyleScreen> createState() =>
      _LearningThinkingStyleScreenState();
}

class _LearningThinkingStyleScreenState
    extends State<LearningThinkingStyleScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- State Değişkenleri ---
  User? _currentUser;
  bool _isLoadingPage = true;
  bool _isSaving = false;
  String _loadingError = '';

  // Form Alanları
  final Map<String, bool> _learningMethodsOptions = {
    'Görsel Materyaller (Video, Sunum, Şema)': false,
    'Okuma (Doküman, Kitap, Blog Yazısı)': false,
    'Uygulama Yaparak (Proje, Kodlama Egzersizi)': false,
    'Dinleyerek (Podcast, Anlatım)': false,
    'Tartışarak / Öğreterek': false,
    'Yapılandırılmış Kurslar / Eğitimler': false,
    'Deneme Yanılma / Keşfederek': false,
  };
  String? _selectedLearningStyle;
  final List<String> _learningStyleOptions = [
    'Uygulamacı (Yaparak öğrenirim)',
    'Teorik / Araştırmacı (Detayları ve nedenleri anlamayı severim)',
    'Görsel (Şemalar, videolarla daha iyi anlarım)',
    'İşitsel (Dinleyerek veya tartışarak öğrenirim)',
    'Okuyarak / Yazarak (Not alarak, okuyarak pekiştiririm)',
    'Adım Adım / Metodik (Sırayla ve planlı gitmeyi tercih ederim)',
  ];
  double _analyticalThinkingRating = 5.0;
  final Map<String, bool> _infoSourcesOptions = {
    'Resmi Dokümantasyonlar': false,
    'Stack Overflow / Q&A Platformları': false,
    'Video Platformları (YouTube vb.)': false,
    'Teknik Bloglar / Makaleler (Medium vb.)': false,
    'Yapay Zeka Araçları (ChatGPT vb.)': false,
    'Online Kurslar / Eğitim İçerikleri': false,
    'Kitaplar / E-kitaplar': false,
    'Forumlar / Topluluklar (Discord, Reddit vb.)': false,
    'Mentor / Deneyimli Kişiler': false,
    'Diğer (Açıklayınız)': false,
  };
  final TextEditingController _otherInfoSourceController =
      TextEditingController();
  final Map<String, bool> _retentionMethodsOptions = {
    'Özet Çıkarma / Not Tutma': false,
    'Pratik Projeler Yapma': false,
    'Konuyu Başkasına Anlatma': false,
    'Flashcard / Ezber Kartları Kullanma': false,
    'Düzenli Tekrar / Aralıklı Öğrenme': false,
    'Kodlama Egzersizleri Çözme': false,
    'Zihin Haritaları Oluşturma': false,
    'Diğer (Açıklayınız)': false,
  };
  final TextEditingController _otherRetentionMethodController =
      TextEditingController();

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
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection('users')
              .doc(_currentUser!.uid)
              .collection('profile_data')
              .doc('learning_thinking_style_v2')
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (mounted) {
          _updateStateWithLoadedData(data);
        }
      }
    } catch (e) {
      print("HATA: learning_thinking_style_v2 verisi yüklenemedi: $e");
      _loadingError = 'Kaydedilmiş veriler yüklenirken bir sorun oluştu.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPage = false;
        });
      }
    }
  }

  void _updateStateWithLoadedData(Map<String, dynamic> data) {
    setState(() {
      List<String> savedMethods = List<String>.from(
        data['preferredLearningMethods'] ?? [],
      );
      _learningMethodsOptions.forEach((key, value) {
        _learningMethodsOptions[key] = savedMethods.contains(key);
      });
      _selectedLearningStyle = data['learningStyle'];
      if (!_learningStyleOptions.contains(_selectedLearningStyle))
        _selectedLearningStyle = null;
      _analyticalThinkingRating =
          (data['analyticalThinkingRating'] ?? 5.0).toDouble();
      List<String> savedSources = List<String>.from(data['infoSources'] ?? []);
      _infoSourcesOptions.forEach((key, value) {
        _infoSourcesOptions[key] = savedSources.contains(key);
      });
      _otherInfoSourceController.text = data['otherInfoSource'] ?? '';
      List<String> savedRetention = List<String>.from(
        data['retentionMethods'] ?? [],
      );
      _retentionMethodsOptions.forEach((key, value) {
        _retentionMethodsOptions[key] = savedRetention.contains(key);
      });
      _otherRetentionMethodController.text = data['otherRetentionMethod'] ?? '';
    });
  }

  @override
  void dispose() {
    _otherInfoSourceController.dispose();
    _otherRetentionMethodController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showFeedback('Oturum bulunamadı.', isError: true);
      return;
    }

    List<String> selectedLearningMethods =
        _learningMethodsOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<String> selectedInfoSources =
        _infoSourcesOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<String> selectedRetentionMethods =
        _retentionMethodsOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

    Map<String, dynamic> learningData = {
      'preferredLearningMethods': selectedLearningMethods,
      'learningStyle': _selectedLearningStyle,
      'analyticalThinkingRating': _analyticalThinkingRating.round(),
      'infoSources': selectedInfoSources,
      'otherInfoSource':
          _infoSourcesOptions['Diğer (Açıklayınız)'] == true
              ? _otherInfoSourceController.text.trim()
              : null,
      'retentionMethods': selectedRetentionMethods,
      'otherRetentionMethod':
          _retentionMethodsOptions['Diğer (Açıklayınız)'] == true
              ? _otherRetentionMethodController.text.trim()
              : null,
      'lastUpdated': Timestamp.now(),
    };

    setState(() {
      _isSaving = true;
    });
    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('learning_thinking_style_v2')
          .set(learningData, SetOptions(merge: true));
      if (mounted) {
        _showFeedback(
          'Öğrenme ve düşünme stili bilgileri kaydedildi!',
          isError: false,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Öğrenme Stili v2): $e");
      _showFeedback('Bilgiler kaydedilirken bir hata oluştu.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_selectedLearningStyle == null) {
      _showFeedback('Lütfen 2. soruyu yanıtlayın.', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      _showFeedback(
        'Lütfen formdaki işaretli alanları düzeltin.',
        isError: true,
      );
      return;
    }
    await _saveToFirestore();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoadingPage) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yükleniyor...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadingError.isNotEmpty && !_isLoadingPage) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _loadingError,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil: Düşünme & Öğrenme'),
        elevation: 1,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: _isSaving ? Container() : const Icon(Icons.save_rounded),
          label:
              _isSaving
                  ? const SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Kaydet ve Geri Dön'),
          onPressed: _isSaving ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            textStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 20.0,
          bottom: 100.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.menu_book_rounded,
                questionText: 'Tercih Ettiğin Öğrenme Yöntemleri',
                child: Column(
                  children:
                      _learningMethodsOptions.keys
                          .map(
                            (method) => CheckboxListTile(
                              title: Text(
                                method,
                                style: theme.textTheme.bodyLarge,
                              ),
                              value: _learningMethodsOptions[method],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _learningMethodsOptions[method] = newValue!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: false,
                              contentPadding: EdgeInsets.zero,
                              activeColor: colorScheme.primary,
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 24.0),
              // --- Soru 2 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.psychology_alt_rounded,
                questionText: 'Öğrenme Tarzın',
                child: Column(
                  children:
                      _learningStyleOptions
                          .map(
                            (style) => RadioListTile<String>(
                              title: Text(
                                style,
                                style: theme.textTheme.bodyLarge,
                              ),
                              value: style,
                              groupValue: _selectedLearningStyle,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedLearningStyle = value;
                                });
                              },
                              dense: false,
                              contentPadding: EdgeInsets.zero,
                              activeColor: colorScheme.primary,
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 24.0),
              // --- Soru 3 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.analytics_rounded,
                questionText: 'Analitik Düşünme Yaklaşımın',
                child: Column(
                  children: [
                    Text(
                      'Algoritma, problem çözme, sistem mantığı gibi konulara ne kadar yatkınsın?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: _analyticalThinkingRating,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _analyticalThinkingRating.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _analyticalThinkingRating = value;
                        });
                      },
                      activeColor: colorScheme.primary,
                      inactiveColor: colorScheme.primaryContainer.withOpacity(
                        0.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '1\n(Zorlanıyorum)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '10\n(Çok Yatkınım)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              // --- Soru 4 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.search_rounded,
                questionText: 'Bilgiye Ulaşma Kaynakların',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Takıldığında veya araştırma yaparken ilk nereye bakarsın?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    ..._infoSourcesOptions.keys
                        .map(
                          (source) => CheckboxListTile(
                            title: Text(
                              source,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: _infoSourcesOptions[source],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _infoSourcesOptions[source] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    if (_infoSourcesOptions['Diğer (Açıklayınız)'] == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          controller: _otherInfoSourceController,
                          decoration: _inputDecoration(
                            context,
                            'Diğer Kaynağı Açıklayın',
                            Icons.edit_note_rounded,
                          ),
                          validator: (value) {
                            if (_infoSourcesOptions['Diğer (Açıklayınız)'] ==
                                    true &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Lütfen diğer kaynağı açıklayın.';
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              // --- Soru 5 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.memory_rounded,
                questionText: 'Öğrenmeyi Pekiştirme Yöntemlerin',
                child: Column(
                  children: [
                    ..._retentionMethodsOptions.keys
                        .map(
                          (method) => CheckboxListTile(
                            title: Text(
                              method,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: _retentionMethodsOptions[method],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _retentionMethodsOptions[method] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    if (_retentionMethodsOptions['Diğer (Açıklayınız)'] == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          controller: _otherRetentionMethodController,
                          decoration: _inputDecoration(
                            context,
                            'Diğer Yöntemi Açıklayın',
                            Icons.edit_note_rounded,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (_retentionMethodsOptions['Diğer (Açıklayınız)'] ==
                                    true &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Lütfen diğer yöntemi açıklayın.';
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  // --- Düzeltilmiş Yardımcı Kart Widget'ı ---
  Widget _buildQuestionCard({
    required BuildContext context,
    required IconData icon,
    required String questionText,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    questionText,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0), // Başlık ve içerik arası boşluk
            child, // Asıl input widget'ları
          ],
        ),
      ),
    );
  }
  // ------------------------------------------

  // --- Düzeltilmiş InputDecoration için Yardımcı Fonksiyon ---
  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData? prefixIcon,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText:
          label.contains("Açıklayın") ? 'Detayları buraya yazın...' : null,
      prefixIcon:
          prefixIcon != null
              ? Icon(
                prefixIcon,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              )
              : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14.0,
        vertical: 16.0,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }

  // ------------------------------------------
}
