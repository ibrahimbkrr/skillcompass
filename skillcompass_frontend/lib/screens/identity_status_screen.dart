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
  String _userName = '';
  bool _isLoadingUserData = true;

  // Soru 1
  final Map<String, bool> _selfDefinitionOptions = {
    'Bilişim Dünyasına Yeni Adım Attım': false,
    'Temel Bilgileri Öğreniyorum / Pratik Yapıyorum': false,
    'Belirli Bir Alanda Kendimi Geliştiriyorum': false,
    'Orta Seviye Tecrübeliyim / Uzmanlaşmaya Çalışıyorum': false,
    'Deneyimli Bir Profesyonelim': false,
    'Akademik Kariyerime Odaklıyım': false,
    'Kariyer Değişikliği Sürecindeyim': false,
    'Freelance Çalışıyorum / Kendi İşimi Yapıyorum': false,
  };
  // Soru 2
  final TextEditingController _universityController = TextEditingController();
  // Soru 3
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
  ];
  // Soru 4
  final Map<String, bool> _currentActivitiesOptions = {
    'Üniversite Dersleri': false,
    'Staj Yapıyorum': false,
    'Online Kurs Alıyorum': false,
    'Freelance Proje Yapıyorum': false,
    'Tam Zamanlı Çalışıyorum': false,
    'Yarı Zamanlı Çalışıyorum': false,
    'Kişisel Proje Geliştiriyorum': false,
    'İş Arıyorum': false,
  };
  // Soru 5
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

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserName();
    } else {
      setState(() {
        _isLoadingUserData = false;
      });
    }
    // _loadSavedData();
  }

  Future<void> _fetchUserName() async {
    // ... (Kullanıcı adı çekme kodu - Değişiklik yok) ...
    setState(() {
      _isLoadingUserData = true;
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        if (mounted) {
          setState(() {
            _userName = userDoc.data()!['firstName'] ?? '';
            _isLoadingUserData = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingUserData = false;
          });
        }
      }
    } catch (e) {
      print("Kullanıcı adı çekme hatası: $e");
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _universityController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    // ... (Firestore'a kaydetme kodu - Değişiklik yok) ...
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      /* Hata mesajı */
      return;
    }

    List<String> selectedSelfDefinitions =
        _selfDefinitionOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
    List<String> selectedCurrentActivities =
        _currentActivitiesOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
    List<String> selectedInvestmentMethods =
        _investmentMethodsOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    Map<String, dynamic> identityData = {
      'selfDefinitions': selectedSelfDefinitions,
      'universityAndDepartment': _universityController.text.trim(),
      'academicStage': _selectedAcademicStage,
      'currentActivities': selectedCurrentActivities,
      'selfInvestmentMethods': selectedInvestmentMethods,
      'lastUpdated': Timestamp.now(),
    };

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('identity_status')
          .set(identityData, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bilgiler başarıyla kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Firestore Kayıt Hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: Bilgiler kaydedilemedi. $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    // ... (Form gönderme kodu - Değişiklik yok) ...
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen formdaki eksik veya hatalı alanları düzeltin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });
    await _saveToFirestore();
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return Scaffold(
        /* ... Yükleniyor ekranı ... */
        appBar: AppBar(title: const Text('Yükleniyor...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Merhaba ${_userName.isNotEmpty ? _userName : 'Kullanıcı'}!',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1 --- (Değişiklik yok)
              _buildQuestionCard(
                context: context,
                questionNumber: 1,
                questionText:
                    '${_userName.isNotEmpty ? _userName + ', k' : 'K'}endinizi nasıl tanımlarsınız?',
                child: Column(
                  /* ... CheckboxListTile ... */
                  children:
                      _selfDefinitionOptions.keys.map((option) {
                        return CheckboxListTile(
                          /* ... */
                          title: Text(option),
                          value: _selfDefinitionOptions[option],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _selfDefinitionOptions[option] = newValue!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 2 --- (Değişiklik yok)
              _buildQuestionCard(
                context: context,
                questionNumber: 2,
                questionText: 'Üniversite ve bölümünüz nedir?',
                child: TextFormField(
                  /* ... */
                  controller: _universityController,
                  decoration: const InputDecoration(
                    hintText: 'Örn: Fırat Üniversitesi, Yazılım Müh.',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 3 --- (Değişiklik yok)
              _buildQuestionCard(
                context: context,
                questionNumber: 3,
                questionText: 'Akademik durumunuz nedir?',
                child: DropdownButtonFormField<String>(
                  /* ... */
                  value: _selectedAcademicStage,
                  hint: const Text('Seçiniz...'),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  items:
                      _academicStageOptions.map((String stage) {
                        return DropdownMenuItem<String>(
                          value: stage,
                          child: Text(stage, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAcademicStage = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen akademik durumunuzu seçin';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 4 --- (Değişiklik yok)
              _buildQuestionCard(
                context: context,
                questionNumber: 4,
                questionText: 'Şu an aktif olarak neler yapıyorsunuz?',
                child: Wrap(
                  /* ... CheckboxListTile ... */
                  spacing: 8.0,
                  runSpacing: 0.0,
                  children:
                      _currentActivitiesOptions.keys.map((option) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: CheckboxListTile(
                            /* ... */
                            title: Text(
                              option,
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: _currentActivitiesOptions[option],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _currentActivitiesOptions[option] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 5: Sadece metni güncellendi ---
              _buildQuestionCard(
                context: context,
                questionNumber: 5,
                // Güncellenmiş soru metni
                questionText:
                    'Kendinizi geliştirmek için genellikle hangi yöntemleri kullanırsınız? (İlgili olanları işaretleyin)',
                child: Column(
                  // CheckboxListTile'lar aynı kaldı
                  children:
                      _investmentMethodsOptions.keys.map((option) {
                        return CheckboxListTile(
                          title: Text(option),
                          value: _investmentMethodsOptions[option],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _investmentMethodsOptions[option] = newValue!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                ),
              ),
              // ---------------------------
              const SizedBox(height: 32.0),

              // --- Kaydet Butonu --- (Değişiklik yok)
              Center(
                child: ElevatedButton(
                  /* ... */
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 15.0,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(/* ... */)
                          : const Text('Kaydet ve Devam Et'),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  // Yardımcı Widget (Değişiklik yok)
  Widget _buildQuestionCard({
    required BuildContext context,
    required int questionNumber,
    required String questionText,
    required Widget child,
  }) {
    return Card(
      /* ... Card içeriği ... */
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$questionNumber. $questionText',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12.0),
            child,
          ],
        ),
      ),
    );
  }
}
