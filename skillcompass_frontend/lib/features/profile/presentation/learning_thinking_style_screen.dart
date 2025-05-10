import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';

class LearningThinkingStyleScreen extends StatefulWidget {
  const LearningThinkingStyleScreen({super.key});

  @override
  State<LearningThinkingStyleScreen> createState() =>
      _LearningThinkingStyleScreenState();
}

class _LearningThinkingStyleScreenState
    extends State<LearningThinkingStyleScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- State Değişkenleri ---
  User? _currentUser;
  bool _isLoadingPage = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String _loadingError = '';
  late TabController _tabController;

  // Form Alanları
  final Map<String, bool> _learningMethodsOptions = {
    'Görsel Materyaller (Video, Sunum, Şema)': false,
    'Okuma (Doküman, Kitap, Blog Yazısı)': false,
    'Uygulama Yaparak (Proje, Kodlama Egzersizi)': false,
    'Dinleyerek (Podcast, Anlatım)': false,
    'Tartışarak / Öğreterek': false,
    'Yapılandırılmış Kurslar / Eğitimler': false,
    'Deneme Yanılma / Keşfederek': false,
    'Sosyal Öğrenme (Grup Çalışması, Mentorluk)': false,
    'Mikro Öğrenme (Kısa, Odaklı İçerikler)': false,
  };
  String? _selectedLearningStyle;
  final List<String> _learningStyleOptions = [
    'Uygulamacı (Yaparak öğrenirim)',
    'Teorik / Araştırmacı (Detayları ve nedenleri anlamayı severim)',
    'Görsel (Şemalar, videolarla daha iyi anlarım)',
    'İşitsel (Dinleyerek veya tartışarak öğrenirim)',
    'Okuyarak / Yazarak (Not alarak, okuyarak pekiştiririm)',
    'Adım Adım / Metodik (Sırayla ve planlı gitmeyi tercih ederim)',
    'Sosyal (Başkalarıyla etkileşimde öğrenirim)',
    'Analitik (Problem çözme ve analiz yaparak öğrenirim)',
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
    'GitHub / Açık Kaynak Projeler': false,
    'Teknik Web Siteleri (MDN, W3Schools vb.)': false,
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
    'Sosyal Öğrenme (Grup Çalışması)': false,
    'Blog Yazıları / Dokümantasyon Yazma': false,
    'Video İçerik Üretme': false,
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
    _tabController = TabController(length: 3, vsync: this);
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
    _tabController.dispose();
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
    // Öğrenme yöntemleri kontrolü
    if (_learningMethodsOptions.entries.where((e) => e.value).isEmpty) {
      _showFeedback('Lütfen en az bir öğrenme yöntemi seçin.', isError: true);
      return;
    }

    // Öğrenme tarzı kontrolü
    if (_selectedLearningStyle == null) {
      _showFeedback('Lütfen öğrenme tarzınızı seçin.', isError: true);
      return;
    }

    // Bilgi kaynakları kontrolü
    if (_infoSourcesOptions.entries.where((e) => e.value).isEmpty) {
      _showFeedback('Lütfen en az bir bilgi kaynağı seçin.', isError: true);
      return;
    }

    // Diğer bilgi kaynağı kontrolü
    if (_infoSourcesOptions['Diğer (Açıklayınız)'] == true &&
        _otherInfoSourceController.text.trim().isEmpty) {
      _showFeedback('Lütfen diğer bilgi kaynağını açıklayın.', isError: true);
      return;
    }

    // Pekiştirme yöntemleri kontrolü
    if (_retentionMethodsOptions.entries.where((e) => e.value).isEmpty) {
      _showFeedback('Lütfen en az bir pekiştirme yöntemi seçin.', isError: true);
      return;
    }

    // Diğer pekiştirme yöntemi kontrolü
    if (_retentionMethodsOptions['Diğer (Açıklayınız)'] == true &&
        _otherRetentionMethodController.text.trim().isEmpty) {
      _showFeedback('Lütfen diğer pekiştirme yöntemini açıklayın.', isError: true);
      return;
    }

    await _saveToFirestore();
    setState(() {
      _isEditing = false;
    });
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
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;
    final isLoading = userProvider.isLoading;
    final error = userProvider.error;
    if (isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }
    if (error != null) {
      return Scaffold(
        body: ErrorMessage(message: 'Hata: $error'),
      );
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenme ve Düşünme Stili'),
        elevation: 1,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // Değişiklikleri geri al
                      _loadSavedData();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.save_rounded),
                  onPressed: () {
                    _submitForm();
                  },
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Öğrenme Stili Profili'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Bu sayfada öğrenme ve düşünme stilinizi belirleyerek, SkillCompass\'ın size özel öneriler sunmasına yardımcı oluyoruz. Bu bilgiler, size en uygun öğrenme kaynaklarını ve yöntemlerini seçmemize olanak sağlar.\n\n'
                      '• Öğrenme yöntemlerinizi seçerek, hangi formatların size daha uygun olduğunu belirleyebiliriz. Bu sayede size özel içerik önerileri sunabiliriz.\n'
                      '• Öğrenme tarzınızı seçerek, size en uygun öğrenme stratejilerini ve yol haritasını oluşturabiliriz.\n'
                      '• Analitik düşünme eğiliminizi belirleyerek, zorluk seviyesi size uygun içerikler ve projeler önerebiliriz.\n'
                      '• Bilgi kaynaklarınızı seçerek, güvendiğiniz ve tercih ettiğiniz kaynaklardan içerik önerebiliriz.\n'
                      '• Öğrenmeyi pekiştirme yöntemlerinizi belirleyerek, kalıcı öğrenme için size özel stratejiler ve alıştırmalar geliştirebiliriz.\n\n'
                      'Bu bilgiler, SkillCompass\'ın size özel bir öğrenme deneyimi sunmasını sağlayacak ve beceri gelişiminizi hızlandıracaktır.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Anladım'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Temel Bilgiler'),
            Tab(text: 'Öğrenme Yöntemleri'),
            Tab(text: 'Pekiştirme'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(theme),
          _buildLearningMethodsTab(theme),
          _buildRetentionTab(theme),
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
              'Öğrenme Tarzın',
              _buildStatusSelector(
                theme,
                _learningStyleOptions,
                _selectedLearningStyle,
                (value) => setState(() => _selectedLearningStyle = value),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              'Analitik Düşünme Eğilimin',
              Column(
                children: [
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
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
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
            if (_isEditing) _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningMethodsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            theme,
            'Tercih Ettiğin Öğrenme Yöntemleri',
            _buildMultiSelector(
              theme,
              _learningMethodsOptions.keys.toList(),
              _learningMethodsOptions.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList(),
              (option) {
                setState(() {
                  _learningMethodsOptions[option] = !_learningMethodsOptions[option]!;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            theme,
            'Bilgi Kaynakların',
            _buildMultiSelector(
              theme,
              _infoSourcesOptions.keys.toList(),
              _infoSourcesOptions.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList(),
              (option) {
                setState(() {
                  _infoSourcesOptions[option] = !_infoSourcesOptions[option]!;
                });
              },
            ),
          ),
          if (_infoSourcesOptions['Diğer (Açıklayınız)'] == true)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                controller: _otherInfoSourceController,
                decoration: customInputDecoration(
                  context,
                  'Diğer Kaynağı Açıklayın',
                  Icons.edit_note_rounded,
                ),
                validator: (value) {
                  if (_infoSourcesOptions['Diğer (Açıklayınız)'] == true &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Lütfen diğer kaynağı açıklayın.';
                  }
                  return null;
                },
              ),
            ),
          if (_isEditing) _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildRetentionTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            theme,
            'Öğrenmeyi Pekiştirme Yöntemlerin',
            _buildMultiSelector(
              theme,
              _retentionMethodsOptions.keys.toList(),
              _retentionMethodsOptions.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList(),
              (option) {
                setState(() {
                  _retentionMethodsOptions[option] = !_retentionMethodsOptions[option]!;
                });
              },
            ),
          ),
          if (_retentionMethodsOptions['Diğer (Açıklayınız)'] == true)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                controller: _otherRetentionMethodController,
                decoration: customInputDecoration(
                  context,
                  'Diğer Yöntemi Açıklayın',
                  Icons.edit_note_rounded,
                ),
                maxLines: 3,
                validator: (value) {
                  if (_retentionMethodsOptions['Diğer (Açıklayınız)'] == true &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Lütfen diğer yöntemi açıklayın.';
                  }
                  return null;
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
                    Icons.school_outlined,
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
                        'Öğrenme stilinizi belirleyerek size özel öneriler alın',
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSectionDescription(title),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ),
      ],
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Öğrenme Tarzın':
        return Icons.psychology_alt_rounded;
      case 'Analitik Düşünme Eğilimin':
        return Icons.analytics_rounded;
      case 'Tercih Ettiğin Öğrenme Yöntemleri':
        return Icons.menu_book_rounded;
      case 'Bilgi Kaynakların':
        return Icons.source_rounded;
      case 'Öğrenmeyi Pekiştirme Yöntemlerin':
        return Icons.memory_rounded;
      default:
        return Icons.info_outline;
    }
  }

  String _getSectionDescription(String title) {
    switch (title) {
      case 'Öğrenme Tarzın':
        return 'Size en uygun öğrenme tarzını seçin. Bu seçim, öğrenme sürecinizi nasıl yapılandırdığınızı belirler.';
      case 'Analitik Düşünme Eğilimin':
        return 'Analitik düşünme ve problem çözme becerilerinizi değerlendirin. Bu bilgi, size uygun zorluk seviyesindeki içerikleri belirlememize yardımcı olur.';
      case 'Tercih Ettiğin Öğrenme Yöntemleri':
        return 'Size en uygun öğrenme yöntemlerini seçin. Birden fazla seçim yapabilirsiniz. Bu seçimler, size özel içerik önerileri almanızı sağlayacaktır.';
      case 'Bilgi Kaynakların':
        return 'Öğrenme sürecinizde güvendiğiniz ve tercih ettiğiniz bilgi kaynaklarını seçin. Birden fazla seçim yapabilirsiniz.';
      case 'Öğrenmeyi Pekiştirme Yöntemlerin':
        return 'Öğrendiklerinizi kalıcı hale getirmek için kullandığınız yöntemleri seçin. Birden fazla seçim yapabilirsiniz.';
      default:
        return '';
    }
  }

  Widget _buildStatusSelector(
    ThemeData theme,
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
              onChanged: _isEditing ? onChanged : null,
              activeColor: theme.colorScheme.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }).toList(),
        if (selectedValue == null && _isEditing)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Lütfen bir seçim yapın',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMultiSelector(
    ThemeData theme,
    List<String> options,
    List<String> selectedValues,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
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
        ),
        if (selectedValues.isEmpty && _isEditing)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Lütfen en az bir seçim yapın',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: _isSaving ? const Text('Kaydediliyor...') : const Text('Kaydet'),
              onPressed: _isSaving ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
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
        ],
      ),
    );
  }

  // --- Düzeltilmiş InputDecoration için Yardımcı Fonksiyon ---
  InputDecoration customInputDecoration(
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
