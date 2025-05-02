import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kullanıcının destek, topluluk ve mentorluk yaklaşımını anlamak için ekran
class SupportCommunityScreen extends StatefulWidget {
  const SupportCommunityScreen({super.key});

  @override
  State<SupportCommunityScreen> createState() => _SupportCommunityScreenState();
}

class _SupportCommunityScreenState extends State<SupportCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Form Alanları için State Değişkenleri ---

  // Soru 1: Sorun Çözme Yöntemleri (Multi-select)
  final Map<String, bool> _problemSolvingMethods = {
    'Stack Overflow / Forumlar': false,
    'ChatGPT / Yapay Zeka Araçları': false,
    'Resmi Dokümantasyonlar': false,
    'Mentora / Deneyimli Birine Sormak': false,
    'Deneme Yanılma / Kendi Başıma Çözmeye Çalışmak': false,
    'Konuyu Geçici Olarak Bırakıp Sonra Dönmek': false,
    'Vazgeçmek / Başka Konuya Geçmek': false,
  };

  // Soru 2: Geri Bildirim İsteği (Radio + Açıklama)
  String? _feedbackPreference; // null, 'Evet', 'Hayır', 'Bazen'
  final List<String> _feedbackOptions = ['Evet', 'Hayır', 'Bazen'];
  final TextEditingController _feedbackDetailsController =
      TextEditingController();

  // Soru 3: Mentorluk İsteği (Dropdown + Açıklama)
  String? _mentorshipPreference; // null, 'Evet', 'Belki', 'Hayır'
  final List<String> _mentorshipOptions = ['Evet', 'Belki', 'Hayır'];
  final TextEditingController _mentorshipDetailsController =
      TextEditingController();

  // Soru 4: Teknik Topluluk Aktifliği (Multi-select)
  final Map<String, bool> _communityActivityOptions = {
    'Discord Sunucuları': false,
    'Telegram Grupları': false,
    'LinkedIn Grupları': false,
    'Üniversite Kulüpleri / Öğrenci Toplulukları': false,
    'Yerel Meetup Grupları': false,
    'Online Forumlar (Stack Overflow dışında)': false,
    'Aktif Değilim': false, // Ayrı bir seçenek
  };

  // Soru 5: Destek Çevresi (Radio + Açıklama)
  bool? _hasSupportCircle; // null, true: Evet, false: Hayır
  final TextEditingController _supportCircleDetailsController =
      TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // TODO: Kayıtlı veriyi yükleme (_loadSavedData)
  }

  @override
  void dispose() {
    _feedbackDetailsController.dispose();
    _mentorshipDetailsController.dispose();
    _supportCircleDetailsController.dispose();
    super.dispose();
  }

  // --- Firestore'a Kaydetme Fonksiyonu ---
  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hata: Oturum açmış kullanıcı bulunamadı.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Soru 1: Seçilen yöntemleri listele
    List<String> selectedProblemSolvingMethods =
        _problemSolvingMethods.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Soru 4: Seçilen toplulukları listele
    List<String> selectedCommunityActivities =
        _communityActivityOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Kaydedilecek veriyi hazırla
    Map<String, dynamic> supportData = {
      'problemSolvingMethods': selectedProblemSolvingMethods,
      'feedbackPreference': _feedbackPreference,
      'feedbackDetails':
          (_feedbackPreference == 'Evet' || _feedbackPreference == 'Bazen')
              ? _feedbackDetailsController.text.trim()
              : null,
      'mentorshipPreference': _mentorshipPreference,
      'mentorshipDetails':
          (_mentorshipPreference == 'Evet' || _mentorshipPreference == 'Belki')
              ? _mentorshipDetailsController.text.trim()
              : null,
      'communityActivities': selectedCommunityActivities,
      'hasSupportCircle': _hasSupportCircle,
      'supportCircleDetails':
          _supportCircleDetailsController.text
              .trim(), // Her durumda kaydedilebilir
      'lastUpdated': Timestamp.now(),
    };

    try {
      // Firestore'a yaz: users/{userId}/profile_data/support_community
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('support_community') // Bu bölüm için belirli bir doküman
          .set(supportData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Destek ve topluluk bilgileri kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pop(context); // İsteğe bağlı geri dön
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Destek): $e");
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

  // Formu Kaydetme Ana Fonksiyonu
  Future<void> _submitForm() async {
    // Manuel validasyonlar (Radio/Dropdown)
    if (_feedbackPreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 2. soruda geri bildirim tercihinizi belirtin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_mentorshipPreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 3. soruda mentorluk isteğinizi belirtin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_hasSupportCircle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen 5. soruda destek çevreniz olup olmadığını belirtin.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // FormField validasyonları (varsa)
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
    return Scaffold(
      appBar: AppBar(title: const Text('Destek & Topluluk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1: Sorun Çözme Yöntemleri ---
              _buildQuestionCard(
                context: context,
                questionNumber: 1,
                questionText:
                    'Kodla ilgili bir sorun yaşadığınızda genellikle ne yaparsınız?',
                child: Column(
                  children:
                      _problemSolvingMethods.keys.map((method) {
                        return CheckboxListTile(
                          title: Text(method),
                          value: _problemSolvingMethods[method],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _problemSolvingMethods[method] = newValue!;
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

              // --- Soru 2: Geri Bildirim İsteği ---
              _buildQuestionCard(
                context: context,
                questionNumber: 2,
                questionText:
                    'Kod yazarken geri bildirim (code review, yorum vb.) almayı ister misiniz?',
                child: Column(
                  children: [
                    // Radio seçenekleri
                    ..._feedbackOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: _feedbackPreference,
                        onChanged: (String? value) {
                          setState(() {
                            _feedbackPreference = value;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                    // Evet veya Bazen seçilirse Açıklama Alanı
                    if (_feedbackPreference == 'Evet' ||
                        _feedbackPreference == 'Bazen')
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _feedbackDetailsController,
                          decoration: const InputDecoration(
                            labelText:
                                'Ne tür geri bildirimler veya hangi konularda istersiniz? (isteğe bağlı)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 14.0,
                            ),
                          ),
                          maxLines: 2,
                        ),
                      ),
                  ],
                ),
                // Validasyon _submitForm içinde yapılıyor
              ),
              const SizedBox(height: 20.0),

              // --- Soru 3: Mentorluk İsteği ---
              _buildQuestionCard(
                context: context,
                questionNumber: 3,
                questionText: 'Şu an mentorluk almak ister misiniz?',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _mentorshipPreference,
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
                          _mentorshipOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _mentorshipPreference = newValue;
                        });
                      },
                      // Validasyon _submitForm içinde yapılıyor
                    ),
                    // Evet veya Belki seçilirse Detay Alanı
                    if (_mentorshipPreference == 'Evet' ||
                        _mentorshipPreference == 'Belki')
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _mentorshipDetailsController,
                          decoration: const InputDecoration(
                            labelText:
                                'Ne tür bir mentorluk veya hangi konularda destek istersiniz? (isteğe bağlı)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 14.0,
                            ),
                          ),
                          maxLines: 2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 4: Teknik Topluluk Aktifliği ---
              _buildQuestionCard(
                context: context,
                questionNumber: 4,
                questionText:
                    'Teknik topluluklarda (Discord, Telegram, LinkedIn grupları, kulüpler vb.) aktif misiniz?',
                child: Column(
                  // Wrap yerine Column daha iyi olabilir
                  children:
                      _communityActivityOptions.keys.map((activity) {
                        return CheckboxListTile(
                          title: Text(activity),
                          value: _communityActivityOptions[activity],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _communityActivityOptions[activity] = newValue!;
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

              // --- Soru 5: Destek Çevresi ---
              _buildQuestionCard(
                context: context,
                questionNumber: 5,
                questionText:
                    'Etrafınızda gelişiminize katkı sunan biri (arkadaş, eğitmen, abi/abla vb.) var mı?',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Evet'),
                            value: true,
                            groupValue: _hasSupportCircle,
                            onChanged: (bool? value) {
                              setState(() {
                                _hasSupportCircle = value;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Hayır'),
                            value: false,
                            groupValue: _hasSupportCircle,
                            onChanged: (bool? value) {
                              setState(() {
                                _hasSupportCircle = value;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    // Açıklama Alanı (Her zaman gösterilebilir, isteğe bağlı)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: _supportCircleDetailsController,
                        decoration: const InputDecoration(
                          labelText:
                              'Bu konudaki düşünceleriniz veya durumunuz (isteğe bağlı)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 14.0,
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                // Validasyon _submitForm içinde yapılıyor
              ),
              const SizedBox(height: 32.0),

              // --- Kaydet Butonu ---
              Center(
                child: ElevatedButton(
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
                          ? const SizedBox(
                            height: 24.0,
                            width: 24.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.white,
                            ),
                          )
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
