import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IdentityStatusScreen extends StatefulWidget {
  const IdentityStatusScreen({super.key});

  @override
  State<IdentityStatusScreen> createState() => _IdentityStatusScreenState();
}

class _IdentityStatusScreenState extends State<IdentityStatusScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- State Değişkenleri ---
  User? _currentUser;
  bool _isLoadingPage = true;
  bool _isSaving = false;
  String _loadingError = '';

  // Form Alanları
  String? _selectedCurrentStatus;
  final List<String> _currentStatusOptions = [
    'Bilişim alanını keşfediyorum / Yeni başlıyorum.',
    'Öğrenme aşamasındayım (Kurs, okul, kendi kendine).',
    'İlk işimi/stajımı arıyorum / Yeni mezunum.',
    'Junior seviyede çalışıyorum / Deneyim kazanıyorum.',
    'Orta/Kıdemli seviyede profesyonelim.',
    'Kariyer değişikliği yapıyorum / Alan değiştiriyorum.',
    'Freelance çalışıyorum / Kendi işimi yapıyorum.',
  ];
  String? _selectedAcademicStage;
  final List<String> _academicStageOptions = [
    'Hazırlık Sınıfı',
    '1. Sınıf',
    '2. Sınıf',
    '3. Sınıf',
    '4. Sınıf',
    '5+ Sınıf / Uzatma',
    'Yeni Mezun (0-1 yıl)',
    'Mezun (1+ yıl)',
    'Yüksek Lisans Öğrencisi',
    'Yüksek Lisans Mezunu',
    'Doktora Öğrencisi',
    'Doktora Mezunu',
    'Bootcamp / Yoğun Kurs',
    'Okul Dışı / Kendi Kendine Öğrenen',
    'Lise / Dengi',
  ];
  final Map<String, bool> _academicFieldsOptions = {
    'Bilgisayar Mühendisliği': false,
    'Yazılım Mühendisliği': false,
    'Elektrik-Elektronik Mühendisliği': false,
    'Matematik / İstatistik': false,
    'Yönetim Bilişim Sistemleri (MIS)': false,
    'Endüstri Mühendisliği': false,
    'Web Geliştirme Bootcamp': false,
    'Veri Bilimi Bootcamp': false,
    'Mobil Geliştirme Bootcamp': false,
    'Diğer Mühendislik Alanı': false,
    'Diğer Sayısal Alan': false,
    'Diğer Sözel/Eşit Ağırlık Alanı': false,
    'Alan Dışı / Kendi Kendine Öğrenme': false,
    'Diğer (Açıklayınız)': false,
  };
  final TextEditingController _otherAcademicFieldController =
      TextEditingController();
  final Map<String, bool> _currentActivitiesOptions = {
    'Üniversite/Okul Dersleri': false,
    'Staj': false,
    'Online Kurslar/Bootcamp': false,
    'Freelance Projeler': false,
    'Tam Zamanlı İş': false,
    'Yarı Zamanlı İş': false,
    'Kişisel Projeler': false,
    'İş Arama Süreci': false,
    'Açık Kaynak Katkı': false,
  };
  final Map<String, bool> _investmentMethodsOptions = {
    'Online Kurslar (Udemy, Coursera vb.)': false,
    'Teknik Kitaplar / Bloglar / Makaleler': false,
    'Kişisel Projeler Geliştirme': false,
    'Açık Kaynak Projelere Katkı': false,
    'Etkinlikler (Meetup, Webinar, Konferans)': false,
    'Online Topluluklar (Discord, Forum vb.)': false,
    'Kodlama Platformları (LeetCode vb.)': false,
    'Teknoloji Podcastleri / Yayınları': false,
    'Mentorluk (Almak/Vermek)': false,
  };
  final Map<String, bool> _appExpectationsOptions = {
    'Bana özel bir kariyer yol haritası çizilmesi': false,
    'Eksik yönlerimin tespit edilmesi ve öneriler sunulması': false,
    'Teknik becerilerimi geliştirmek için kaynak/proje önerileri': false,
    'Motivasyonumu yüksek tutacak takip ve geri bildirimler': false,
    'Mülakatlara hazırlanmama yardımcı olması': false,
    'Sektördeki trendler hakkında bilgi vermesi': false,
    'Benzer durumdaki kişilerle iletişim kurma imkanı': false,
    'Diğer (Açıklayınız)': false,
  };
  final TextEditingController _otherExpectationController =
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
          // Güvenli pop: Eğer bir önceki sayfa varsa döner, yoksa bir şey yapmaz.
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
      });
    }
  }

  // --- Kayıtlı Form Verisini Yükleme Fonksiyonu ---
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
              .doc('identity_status_v3')
              .get(); // v3'ü okuyoruz

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (mounted) {
          _updateStateWithLoadedData(data);
        }
      }
    } catch (e) {
      print("HATA: identity_status_v3 verisi yüklenemedi: $e");
      _loadingError = 'Kaydedilmiş veriler yüklenirken bir sorun oluştu.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPage = false;
        });
      }
    }
  }

  // Gelen veriyi state'e atayan yardımcı fonksiyon
  void _updateStateWithLoadedData(Map<String, dynamic> data) {
    setState(() {
      _selectedCurrentStatus = data['currentStatus'];
      if (!_currentStatusOptions.contains(_selectedCurrentStatus))
        _selectedCurrentStatus = null;
      _selectedAcademicStage = data['academicStage'];
      if (!_academicStageOptions.contains(_selectedAcademicStage))
        _selectedAcademicStage = null;
      List<String> savedFields = List<String>.from(
        data['academicFields'] ?? [],
      );
      _academicFieldsOptions.forEach((key, value) {
        _academicFieldsOptions[key] = savedFields.contains(key);
      });
      _otherAcademicFieldController.text = data['otherAcademicField'] ?? '';
      List<String> savedActs = List<String>.from(
        data['currentActivities'] ?? [],
      );
      _currentActivitiesOptions.forEach((key, value) {
        _currentActivitiesOptions[key] = savedActs.contains(key);
      });
      List<String> savedInvest = List<String>.from(
        data['selfInvestmentMethods'] ?? [],
      );
      _investmentMethodsOptions.forEach((key, value) {
        _investmentMethodsOptions[key] = savedInvest.contains(key);
      });
      List<String> savedExp = List<String>.from(data['appExpectations'] ?? []);
      _appExpectationsOptions.forEach((key, value) {
        _appExpectationsOptions[key] = savedExp.contains(key);
      });
      _otherExpectationController.text = data['otherExpectation'] ?? '';
    });
  }
  // --------------------------------------------------

  @override
  void dispose() {
    _otherAcademicFieldController.dispose();
    _otherExpectationController.dispose();
    super.dispose();
  }

  // --- Firestore'a Kaydetme Fonksiyonu ---
  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showFeedback('Oturum bulunamadı.', isError: true);
      return;
    }

    // Seçilenleri listele
    List<String> selectedFields =
        _academicFieldsOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<String> selectedActivities =
        _currentActivitiesOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<String> selectedInvestmentMethods =
        _investmentMethodsOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<String> selectedExpectations =
        _appExpectationsOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

    // Kaydedilecek veriyi hazırla
    Map<String, dynamic> identityData = {
      'currentStatus': _selectedCurrentStatus,
      'academicStage': _selectedAcademicStage,
      'academicFields': selectedFields,
      'otherAcademicField':
          _academicFieldsOptions['Diğer (Açıklayınız)'] == true
              ? _otherAcademicFieldController.text.trim()
              : null,
      'currentActivities': selectedActivities,
      'selfInvestmentMethods': selectedInvestmentMethods,
      'appExpectations': selectedExpectations,
      'otherExpectation':
          _appExpectationsOptions['Diğer (Açıklayınız)'] == true
              ? _otherExpectationController.text.trim()
              : null,
      'lastUpdated': Timestamp.now(),
    };

    setState(() {
      _isSaving = true;
    });

    try {
      // Firestore'a yaz (v3)
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('identity_status_v3')
          .set(identityData, SetOptions(merge: true));

      if (mounted) {
        _showFeedback('Bilgiler başarıyla kaydedildi!', isError: false);
        // Geri dönmeden önce kısa bir bekleme (opsiyonel, SnackBar'ın görünmesi için)
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (identity_status_v3): $e");
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
    // Manuel validasyonlar
    if (_selectedCurrentStatus == null) {
      _showFeedback('Lütfen 1. soruyu yanıtlayın.', isError: true);
      return;
    }
    if (_selectedAcademicStage == null) {
      _showFeedback('Lütfen 2. soruda eğitim seviyenizi seçin.', isError: true);
      return;
    }
    if (!_academicFieldsOptions.containsValue(true)) {
      _showFeedback('Lütfen 2. soruda en az bir alan seçin.', isError: true);
      return;
    }
    if (!_appExpectationsOptions.containsValue(true)) {
      _showFeedback(
        'Lütfen 5. soruda en az bir beklenti seçin.',
        isError: true,
      );
      return;
    }

    // FormField validasyonları
    if (!_formKey.currentState!.validate()) {
      _showFeedback(
        'Lütfen formdaki işaretli alanları düzeltin.',
        isError: true,
      );
      return;
    }

    // Kaydetme işlemini başlat
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
        duration: const Duration(seconds: 3), // Biraz daha uzun süre görünsün
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
      appBar: AppBar(title: const Text('Profil: Kimlik & Durum'), elevation: 1),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon:
              _isSaving
                  ? Container()
                  : const Icon(Icons.save_rounded), // İkon güncellendi
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
          bottom: 20.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.directions_run_rounded,
                questionText: 'Mevcut Durumun',
                child: Column(
                  children:
                      _currentStatusOptions
                          .map(
                            (status) => RadioListTile<String>(
                              title: Text(
                                status,
                                style: theme.textTheme.bodyLarge,
                              ),
                              value: status,
                              groupValue: _selectedCurrentStatus,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedCurrentStatus = value;
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

              // --- Soru 2 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.school_rounded,
                questionText: 'Akademik Geçmişin',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedAcademicStage,
                      hint: const Text('Eğitim Seviyesi Seçin...'),
                      isExpanded: true,
                      decoration: _inputDecoration(
                        context,
                        'Eğitim Seviyesi',
                        Icons.grade_rounded,
                      ),
                      items:
                          _academicStageOptions
                              .map(
                                (String stage) => DropdownMenuItem<String>(
                                  value: stage,
                                  child: Text(
                                    stage,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAcademicStage = newValue;
                        });
                      },
                      validator:
                          (value) =>
                              value == null
                                  ? 'Lütfen eğitim seviyenizi seçin.'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Okuduğun/Mezun Olduğun Alan(lar):',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._academicFieldsOptions.keys
                        .map(
                          (field) => CheckboxListTile(
                            title: Text(
                              field,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: _academicFieldsOptions[field],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _academicFieldsOptions[field] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    // "Diğer" alanı için if koşulu
                    if (_academicFieldsOptions['Diğer (Açıklayınız)'] == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          controller: _otherAcademicFieldController,
                          decoration: _inputDecoration(
                            context,
                            'Diğer Alanı Açıklayın',
                            Icons.edit_note_rounded,
                          ),
                          validator: (value) {
                            if (_academicFieldsOptions['Diğer (Açıklayınız)'] ==
                                    true &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Lütfen diğer alanı açıklayın.';
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 3 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.work_history_rounded,
                questionText: 'Şu Anki Aktivitelerin',
                child: Column(
                  children:
                      _currentActivitiesOptions.keys
                          .map(
                            (activity) => CheckboxListTile(
                              title: Text(
                                activity,
                                style: theme.textTheme.bodyLarge,
                              ),
                              value: _currentActivitiesOptions[activity],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _currentActivitiesOptions[activity] =
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

              // --- Soru 4 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.lightbulb_rounded,
                questionText: 'Gelişim Yöntemlerin',
                child: Column(
                  children:
                      _investmentMethodsOptions.keys
                          .map(
                            (method) => CheckboxListTile(
                              title: Text(
                                method,
                                style: theme.textTheme.bodyLarge,
                              ),
                              value: _investmentMethodsOptions[method],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _investmentMethodsOptions[method] = newValue!;
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

              // --- Soru 5 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.question_mark_rounded,
                questionText: 'SkillCompass\'tan Beklentin(ler)',
                child: Column(
                  children: [
                    ..._appExpectationsOptions.keys
                        .map(
                          (expectation) => CheckboxListTile(
                            title: Text(
                              expectation,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: _appExpectationsOptions[expectation],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _appExpectationsOptions[expectation] =
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
                    // "Diğer" alanı için if koşulu
                    if (_appExpectationsOptions['Diğer (Açıklayınız)'] == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          controller: _otherExpectationController,
                          decoration: _inputDecoration(
                            context,
                            'Diğer Beklentinizi Açıklayın',
                            Icons.edit_note_rounded,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (_appExpectationsOptions['Diğer (Açıklayınız)'] ==
                                    true &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Lütfen diğer beklentinizi açıklayın.';
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0), // Buton öncesi boşluk
            ],
          ),
        ),
      ),
    );
  }

  // --- Yardımcı Kart Widget'ı ---
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
                      color:
                          theme
                              .colorScheme
                              .onSurfaceVariant, // Biraz daha yumuşak başlık rengi
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

  // --- InputDecoration için Yardımcı Fonksiyon ---
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
              : null, // İkon rengi
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
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant,
      ), // Label rengi
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
      ), // Hint rengi
    );
  }

  // ------------------------------------------
}
