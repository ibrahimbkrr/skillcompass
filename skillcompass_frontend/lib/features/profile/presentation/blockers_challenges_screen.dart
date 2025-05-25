import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/services/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';

class BlockersChallengesScreen extends StatefulWidget {
  const BlockersChallengesScreen({super.key});

  @override
  State<BlockersChallengesScreen> createState() =>
      _BlockersChallengesScreenState();
}

class _BlockersChallengesScreenState extends State<BlockersChallengesScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileService _profileService = ProfileService();

  // --- State Değişkenleri ---
  User? _currentUser;
  bool _isLoadingPage = true;
  bool _isSaving = false;
  String _loadingError = '';

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
  final TextEditingController _feelingStuckDetailsController =
      TextEditingController();

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
  final TextEditingController _otherCodingChallengeController =
      TextEditingController();

  // Soru 5
  final TextEditingController _priorityLearnTopicController =
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

  // --- Kayıtlı Veriyi Yükleme ---
  Future<void> _loadSavedData() async {
    if (_currentUser == null) return;
    setState(() {
      _isLoadingPage = true;
      _loadingError = '';
    });
    try {
      final data = await _profileService.loadBlockersChallenges();
      if (data != null) {
        if (mounted) {
          _updateStateWithLoadedData(data);
        }
      }
    } catch (e) {
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
  // --------------------------------------------------

  @override
  void dispose() {
    _topicDetailsController.dispose();
    _feelingStuckDetailsController.dispose();
    _otherCodingChallengeController.dispose();
    _priorityLearnTopicController.dispose();
    super.dispose();
  }

  // --- Firestore'a Kaydetme ---
  Future<void> _saveToBackend() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showFeedback('Oturum bulunamadı.', isError: true);
      return;
    }
    List<String> selectedStruggledTopics =
        _struggledTopicsOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<String> selectedProgressionBlockers =
        _progressionBlockersOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<String> selectedCodingChallenges =
        _codingChallengesOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    Map<String, dynamic> blockersData = {
      'struggledTopics': selectedStruggledTopics,
      'struggledTopicsDetails': _topicDetailsController.text.trim(),
      'progressionBlockers': selectedProgressionBlockers,
      'feelingStuckStatus': _feelingStuckStatus,
      'feelingStuckDetails': _feelingStuckDetailsController.text.trim(),
      'codingChallenges': selectedCodingChallenges,
      'otherCodingChallenge': _otherCodingChallengeController.text.trim(),
      'priorityLearnTopic': _priorityLearnTopicController.text.trim(),
    };
    setState(() {
      _isSaving = true;
    });
    try {
      await _profileService.saveBlockersChallenges(blockersData);
      if (mounted) {
        _showFeedback(
          'Engeller ve eksikler bilgisi kaydedildi!',
          isError: false,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Engeller v3): $e");
      _showFeedback('Bilgiler kaydedilirken bir hata oluştu.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  // ------------------------------------

  // --- Form Gönderme ---
  Future<void> _submitForm() async {
    if (_feelingStuckStatus == null) {
      _showFeedback('Lütfen 3. soruyu yanıtlayın.', isError: true);
      return;
    }
    if (!_codingChallengesOptions.containsValue(true)) {
      _showFeedback('Lütfen 4. soruda en az bir zorluk seçin.', isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showFeedback(
        'Lütfen formdaki işaretli alanları düzeltin.',
        isError: true,
      );
      return;
    }
    await _saveToBackend();
  }
  // ------------------------------------

  // --- Geri Bildirim Gösterme ---
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
  // ------------------------------------

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
        title: const Text('Profil: Engeller & Gelişim'),
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
                icon: Icons.warning_amber_rounded,
                questionText: 'Zorlandığın Teknik Konular',
                child: Column(
                  children: [
                    ..._struggledTopicsOptions.keys
                        .map(
                          (topic) => CheckboxListTile(
                            title: Text(
                              topic,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: _struggledTopicsOptions[topic],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _struggledTopicsOptions[topic] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    if (_struggledTopicsOptions['Diğer (Açıklayınız)'] == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          controller: _topicDetailsController,
                          decoration: customInputDecoration(
                            context,
                            'Engel/Zorluk',
                            Icons.block,
                          ),
                          validator: (value) {
                            if (_struggledTopicsOptions['Diğer (Açıklayınız)'] ==
                                    true &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Lütfen diğer konuyu açıklayın.';
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 2 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.pan_tool_alt_rounded,
                questionText: 'İlerlemene Engel Olan Nedenler',
                child: Column(
                  children:
                      _progressionBlockersOptions.keys
                          .map(
                            (blocker) => CheckboxListTile(
                              title: Text(
                                blocker,
                                style: theme.textTheme.bodyLarge,
                              ),
                              value: _progressionBlockersOptions[blocker],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _progressionBlockersOptions[blocker] =
                                      newValue!;
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

              // --- Soru 3 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.sentiment_dissatisfied_rounded,
                questionText: 'İlerleyememe Hissi',
                child: Column(
                  children: [
                    Text(
                      'Teknik bilgin olmasına rağmen ilerleyemiyormuş gibi hissediyor musun?',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._feelingStuckOptions
                        .map(
                          (option) => RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _feelingStuckStatus,
                            onChanged: (String? value) {
                              setState(() {
                                _feelingStuckStatus = value;
                              });
                            },
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    if (_feelingStuckStatus == 'Evet' ||
                        _feelingStuckStatus == 'Bazen')
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _feelingStuckDetailsController,
                          decoration: customInputDecoration(
                            context,
                            'Çözüm',
                            Icons.lightbulb,
                          ),
                          maxLines: 3,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 4 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.code_off_rounded,
                questionText: 'Kod Yazarken En Çok Zorlayan Şeyler',
                child: Column(
                  children: [
                    ..._codingChallengesOptions.keys
                        .map(
                          (challenge) => CheckboxListTile(
                            title: Text(
                              challenge,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: _codingChallengesOptions[challenge],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _codingChallengesOptions[challenge] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    if (_codingChallengesOptions['Diğer (Açıklayınız)'] == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          controller: _otherCodingChallengeController,
                          decoration: customInputDecoration(
                            context,
                            'Engel/Zorluk',
                            Icons.block,
                          ),
                          validator: (value) {
                            if (_codingChallengesOptions['Diğer (Açıklayınız)'] ==
                                    true &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Lütfen diğer zorluğu açıklayın.';
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
                icon: Icons.key_rounded,
                questionText: 'Öncelikli Öğrenme Konusu',
                child: TextFormField(
                  controller: _priorityLearnTopicController,
                  decoration: customInputDecoration(
                    context,
                    'Çözüm',
                    Icons.lightbulb,
                  ),
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
            const SizedBox(height: 16.0),
            child, // Asıl input widget'ları
          ],
        ),
      ),
    );
  }
  // ------------------------------------------
}
