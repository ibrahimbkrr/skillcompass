import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlockersChallengesScreen extends StatefulWidget {
  const BlockersChallengesScreen({super.key});

  @override
  State<BlockersChallengesScreen> createState() =>
      _BlockersChallengesScreenState();
}

class _BlockersChallengesScreenState extends State<BlockersChallengesScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection('users')
              .doc(_currentUser!.uid)
              .collection('profile_data')
              .doc('blockers_challenges_v3') // Versiyon 3
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (mounted) {
          _updateStateWithLoadedData(data);
        }
      }
    } catch (e) {
      print("HATA: blockers_challenges_v3 verisi yüklenemedi: $e");
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
  Future<void> _saveToFirestore() async {
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
      'struggledTopicsDetails':
          _struggledTopicsOptions['Diğer (Açıklayınız)'] == true
              ? _topicDetailsController.text.trim()
              : null,
      'progressionBlockers': selectedProgressionBlockers,
      'feelingStuckStatus': _feelingStuckStatus,
      'feelingStuckDetails':
          (_feelingStuckStatus == 'Evet' || _feelingStuckStatus == 'Bazen')
              ? _feelingStuckDetailsController.text.trim()
              : null,
      'codingChallenges': selectedCodingChallenges,
      'otherCodingChallenge':
          _codingChallengesOptions['Diğer (Açıklayınız)'] == true
              ? _otherCodingChallengeController.text.trim()
              : null,
      'priorityLearnTopic': _priorityLearnTopicController.text.trim(),
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
          .doc('blockers_challenges_v3') // Versiyon 3
          .set(blockersData, SetOptions(merge: true));
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
    await _saveToFirestore();
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
                          decoration: _inputDecoration(
                            context,
                            'Diğer Zorlandığınız Konuyu Açıklayın',
                            Icons.edit_note_rounded,
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
                          decoration: _inputDecoration(
                            context,
                            'Bu hissin nedenini kısaca açıklayın (isteğe bağlı)',
                            Icons.edit_note_rounded,
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
                          decoration: _inputDecoration(
                            context,
                            'Diğer Zorluğu Açıklayın',
                            Icons.edit_note_rounded,
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
                  decoration: _inputDecoration(
                    context,
                    '"Şu konuyu öğrenmeden ilerleyemem" dediğin şey (isteğe bağlı)',
                    Icons.vpn_key_rounded,
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
          label.contains("açıklayın") ||
                  label.contains("detay") ||
                  label.contains("şey ne") ||
                  label.contains("dediğin şey") ||
                  label.contains("konu var mı")
              ? 'Detayları buraya yazın...'
              : null,
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
