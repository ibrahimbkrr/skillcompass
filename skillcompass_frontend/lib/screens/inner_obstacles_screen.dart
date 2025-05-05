import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InnerObstaclesScreen extends StatefulWidget {
  const InnerObstaclesScreen({super.key});

  @override
  State<InnerObstaclesScreen> createState() => _InnerObstaclesScreenState();
}

class _InnerObstaclesScreenState extends State<InnerObstaclesScreen> {
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
  final Map<String, bool> _internalBlockersOptions = {
    'Kendime Yeterince İnanmıyorum / Yetersizlik Hissi':
        false, // Yeniden ifade edildi
    'Mükemmeliyetçilik (Başlayamama/Bitirememe)': false,
    'Kendimi Başkalarıyla Kıyaslama': false, // Yeniden ifade edildi
    'Erteleme Alışkanlığı / Zaman Yönetimi Zorluğu': false, // Genişletildi
    'Kararsızlık / Odaklanma Güçlüğü': false, // Genişletildi
    'Yeni Şeylere Başlamaktan Çekinme': false, // Yeniden ifade edildi
    'Motivasyon Eksikliği / İsteksizlik': false, // Yeniden ifade edildi
    'Eleştirilme veya Yargılanma Korkusu': false, // Yeniden ifade edildi
    'Diğer (Açıklayınız)': false,
  };
  final TextEditingController _otherInternalBlockerController =
      TextEditingController(); // Diğer için

  // Soru 2
  String? _fearOfFailureStatus;
  final List<String> _fearOfFailureOptions = ['Evet', 'Hayır', 'Bazen'];
  final TextEditingController _fearOfFailureDetailsController =
      TextEditingController();

  // Soru 3
  final TextEditingController _gaveUpSituationController =
      TextEditingController();

  // Soru 4
  final TextEditingController _prerequisiteBeliefController =
      TextEditingController();

  // Soru 5
  final TextEditingController _appExpectationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _loadSavedData();
    } else {
      /* Hata/Yönlendirme */
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
              .doc('inner_obstacles_v2') // Versiyon 2
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (mounted) {
          _updateStateWithLoadedData(data);
        }
      }
    } catch (e) {
      /* Hata */
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
  // --------------------------------------------------

  @override
  void dispose() {
    _otherInternalBlockerController.dispose();
    _fearOfFailureDetailsController.dispose();
    _gaveUpSituationController.dispose();
    _prerequisiteBeliefController.dispose();
    _appExpectationController.dispose();
    super.dispose();
  }

  // --- Firestore'a Kaydetme ---
  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      /* Hata */
      return;
    }

    List<String> selectedInternalBlockers =
        _internalBlockersOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

    Map<String, dynamic> obstaclesData = {
      'internalBlockers': selectedInternalBlockers,
      'otherInternalBlocker':
          _internalBlockersOptions['Diğer (Açıklayınız)'] == true
              ? _otherInternalBlockerController.text.trim()
              : null,
      'fearOfFailureStatus': _fearOfFailureStatus,
      'fearOfFailureDetails':
          (_fearOfFailureStatus == 'Evet' || _fearOfFailureStatus == 'Bazen')
              ? _fearOfFailureDetailsController.text.trim()
              : null,
      'gaveUpSituation': _gaveUpSituationController.text.trim(),
      'prerequisiteBelief': _prerequisiteBeliefController.text.trim(),
      'appExpectation': _appExpectationController.text.trim(),
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
          .doc('inner_obstacles_v2') // Versiyon 2
          .set(obstaclesData, SetOptions(merge: true));
      if (mounted) {
        /* Başarı + Geri Dön */
      }
    } catch (e) {
      /* Hata */
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
    // Manuel validasyonlar
    if (!_internalBlockersOptions.containsValue(true)) {
      _showFeedback('Lütfen 1. soruda en az bir engel seçin.', isError: true);
      return;
    }
    if (_fearOfFailureStatus == null) {
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
      /* Yükleniyor */
    }
    if (_loadingError.isNotEmpty && !_isLoadingPage) {
      /* Hata */
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil: İçsel Engeller'), elevation: 1),
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
                icon: Icons.block_rounded,
                questionText: 'Seni En Çok Zorlayan İçsel Durumlar',
                child: Column(
                  children: [
                    ..._internalBlockersOptions.keys
                        .map(
                          (blocker) => CheckboxListTile(
                            title: Text(
                              blocker,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: _internalBlockersOptions[blocker],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _internalBlockersOptions[blocker] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    if (_internalBlockersOptions['Diğer (Açıklayınız)'] == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          controller: _otherInternalBlockerController,
                          decoration: _inputDecoration(
                            context,
                            'Diğer İçsel Engeli Açıklayın',
                            Icons.edit_note_rounded,
                          ),
                          validator: (value) {
                            if (_internalBlockersOptions['Diğer (Açıklayınız)'] ==
                                    true &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Lütfen diğer engeli açıklayın.';
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
                icon: Icons.sentiment_very_dissatisfied_rounded,
                questionText: 'Başarısızlık Korkusu',
                child: Column(
                  children: [
                    Text(
                      'Bir konuda başarısız olma korkusu seni hiç geri çekti mi?',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._fearOfFailureOptions
                        .map(
                          (option) => RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _fearOfFailureStatus,
                            onChanged: (String? value) {
                              setState(() {
                                _fearOfFailureStatus = value;
                              });
                            },
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    if (_fearOfFailureStatus == 'Evet' ||
                        _fearOfFailureStatus == 'Bazen')
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _fearOfFailureDetailsController,
                          decoration: _inputDecoration(
                            context,
                            'Nerede, ne zaman veya nasıl geri çekti? (isteğe bağlı)',
                            Icons.edit_note_rounded,
                          ),
                          maxLines: 3,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 3 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.undo_rounded,
                questionText: 'Vazgeçme Anıları',
                child: TextFormField(
                  controller: _gaveUpSituationController,
                  decoration: _inputDecoration(
                    context,
                    'En son bir hedef koyup vazgeçtiğin durumu anlatır mısın? (isteğe bağlı)',
                    Icons.edit_note_rounded,
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 4 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.lock_outline_rounded,
                questionText: 'Ön Koşul İnançları',
                child: TextFormField(
                  controller: _prerequisiteBeliefController,
                  decoration: _inputDecoration(
                    context,
                    '"Şunu yapmadan/olmadan olmaz" dediğin bir şey var mı? (isteğe bağlı)',
                    Icons.edit_note_rounded,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 5 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.star_border_purple500_rounded,
                questionText: 'SkillCompass\'tan Beklentin',
                child: TextFormField(
                  controller: _appExpectationController,
                  decoration: _inputDecoration(
                    context,
                    'Seni gerçekten ne motive eder? Nasıl yardımcı olabiliriz?',
                    Icons.edit_note_rounded,
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen beklentini kısaca belirt.';
                    }
                    return null;
                  },
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
                  label.contains("durumu anlatır mısın") ||
                  label.contains("dediğin şey") ||
                  label.contains("nasıl yardımcı")
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
