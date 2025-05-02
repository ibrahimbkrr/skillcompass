import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kullanıcının üretim ve girişimcilik profilini anlamak için ekran
class ProductionInitiativeScreen extends StatefulWidget {
  const ProductionInitiativeScreen({super.key});

  @override
  State<ProductionInitiativeScreen> createState() =>
      _ProductionInitiativeScreenState();
}

class _ProductionInitiativeScreenState
    extends State<ProductionInitiativeScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Form Alanları için State Değişkenleri ---

  // Soru 1: En Anlamlı Proje
  final TextEditingController _meaningfulProjectController =
      TextEditingController();

  // Soru 2: Paylaşım Platformları
  bool? _usesSharingPlatforms; // null: seçilmedi, true: Evet, false: Hayır
  final TextEditingController _platformLinkController = TextEditingController();

  // Soru 3: Kişisel Proje Sayısı
  double _personalProjectCount = 1.0; // Başlangıç değeri (0-10+)

  // Soru 4: Açık Kaynak Katkı
  String? _openSourceContributionStatus;
  final List<String> _openSourceOptions = [
    'Evet, katkıda bulundum.',
    'Hayır, bulunmadım.',
    'Bulunmak istiyorum / Düşünüyorum.',
  ];
  final TextEditingController _openSourceDetailsController =
      TextEditingController();

  // Soru 5: Hackathon / Yarışma / Topluluk Görevi
  final Map<String, bool> _activitiesParticipation = {
    'Hackathonlara Katıldım': false,
    'Kodlama Yarışmalarına Katıldım': false,
    'Teknik Topluluklarda Aktif Görev Aldım': false,
    'Teknik Etkinliklerde Sunum Yaptım': false, // Ek örnek
  };
  final TextEditingController _activityDetailsController =
      TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // TODO: Kayıtlı veriyi yükleme (_loadSavedData)
  }

  @override
  void dispose() {
    _meaningfulProjectController.dispose();
    _platformLinkController.dispose();
    _openSourceDetailsController.dispose();
    _activityDetailsController.dispose();
    super.dispose();
  }

  // --- Firestore'a Kaydetme Fonksiyonu ---
  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      /* Hata mesajı */
      return;
    }

    // Soru 5: Seçilen aktiviteleri listele
    List<String> participatedActivities =
        _activitiesParticipation.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Kaydedilecek veriyi hazırla
    Map<String, dynamic> productionData = {
      'meaningfulProjectDesc': _meaningfulProjectController.text.trim(),
      'usesSharingPlatforms': _usesSharingPlatforms,
      'platformLink':
          _usesSharingPlatforms == true
              ? _platformLinkController.text.trim()
              : null, // Sadece evet ise linki kaydet
      'personalProjectCount':
          _personalProjectCount
              .round(), // Slider değerini tam sayı yap (0-11 aralığı 10+ anlamına gelir)
      'openSourceContributionStatus': _openSourceContributionStatus,
      'openSourceDetails':
          (_openSourceContributionStatus == _openSourceOptions[0] ||
                  _openSourceContributionStatus == _openSourceOptions[2])
              ? _openSourceDetailsController.text.trim()
              : null, // Sadece ilgiliyse detayı kaydet
      'participatedActivities': participatedActivities,
      'activityDetails': _activityDetailsController.text.trim(),
      'lastUpdated': Timestamp.now(),
    };

    try {
      // Firestore'a yaz: users/{userId}/profile_data/production_initiative
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('production_initiative') // Bu bölüm için belirli bir doküman
          .set(productionData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Üretim ve girişim bilgileri kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pop(context); // İsteğe bağlı geri dön
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Üretim): $e");
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
    // Manuel validasyonlar (Radio ve Dropdown için)
    if (_usesSharingPlatforms == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen 2. soruda platform kullanım durumunuzu belirtin.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_openSourceContributionStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 4. soruda açık kaynak durumunuzu belirtin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // FormField validasyonları
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
      appBar: AppBar(title: const Text('Üretim & Girişimcilik')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1: En Anlamlı Proje ---
              _buildQuestionCard(
                context: context,
                questionNumber: 1,
                questionText:
                    'Şimdiye kadar üzerinde çalıştığınız en anlamlı proje neydi? Kısaca anlatın.',
                child: TextFormField(
                  controller: _meaningfulProjectController,
                  decoration: const InputDecoration(
                    hintText:
                        'Projenin amacı, kullandığınız teknoloji ve sizin için önemi...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bu alanı doldurun.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 2: Paylaşım Platformları ---
              _buildQuestionCard(
                context: context,
                questionNumber: 2,
                questionText:
                    'Projelerinizi paylaşmak için GitHub, CodePen gibi platformlar kullanıyor musunuz?',
                child: Column(
                  children: [
                    // Evet/Hayır Seçenekleri
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Evet'),
                            value: true,
                            groupValue: _usesSharingPlatforms,
                            onChanged: (bool? value) {
                              setState(() {
                                _usesSharingPlatforms = value;
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
                            groupValue: _usesSharingPlatforms,
                            onChanged: (bool? value) {
                              setState(() {
                                _usesSharingPlatforms = value;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    // Evet seçilirse Link Alanı
                    if (_usesSharingPlatforms == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _platformLinkController,
                          decoration: const InputDecoration(
                            labelText: 'Profil/Proje Linki (isteğe bağlı)',
                            hintText:
                                'GitHub profiliniz veya öne çıkan bir repo...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 14.0,
                            ),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                      ),
                  ],
                ),
                // Validasyon _submitForm içinde yapılıyor
              ),
              const SizedBox(height: 20.0),

              // --- Soru 3: Kişisel Proje Sayısı ---
              _buildQuestionCard(
                context: context,
                questionNumber: 3,
                questionText:
                    'Şu ana kadar kaç tane kişisel proje tamamladınız?',
                child: Column(
                  children: [
                    Slider(
                      value: _personalProjectCount,
                      min: 0, // 0'dan başlasın
                      max: 11, // 11 değeri "10+" anlamına gelecek
                      divisions: 11,
                      label:
                          _personalProjectCount.round() >= 11
                              ? '10+'
                              : _personalProjectCount.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _personalProjectCount = value;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '10+',
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
              const SizedBox(height: 20.0),

              // --- Soru 4: Açık Kaynak Katkı ---
              _buildQuestionCard(
                context: context,
                questionNumber: 4,
                questionText:
                    'Hiç açık kaynak projelere katkıda bulundunuz mu veya bulunmak istiyor musunuz?',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _openSourceContributionStatus,
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
                          _openSourceOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _openSourceContributionStatus = newValue;
                        });
                      },
                      // Validasyon _submitForm içinde yapılıyor
                    ),
                    // Evet veya İstiyorum seçilirse Detay Alanı
                    if (_openSourceContributionStatus ==
                            _openSourceOptions[0] ||
                        _openSourceContributionStatus == _openSourceOptions[2])
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _openSourceDetailsController,
                          decoration: InputDecoration(
                            labelText:
                                _openSourceContributionStatus ==
                                        _openSourceOptions[0]
                                    ? 'Katkıda bulunduğunuz projeler/alanlar (isteğe bağlı)'
                                    : 'Hangi alanlarda katkıda bulunmak istersiniz? (isteğe bağlı)',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
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

              // --- Soru 5: Hackathon / Yarışma / Topluluk Görevi ---
              _buildQuestionCard(
                context: context,
                questionNumber: 5,
                questionText:
                    'Herhangi bir hackathon, yarışma veya teknik toplulukta görev aldınız mı?',
                child: Column(
                  children: [
                    // Checkbox seçenekleri
                    ..._activitiesParticipation.keys.map((activity) {
                      return CheckboxListTile(
                        title: Text(activity),
                        value: _activitiesParticipation[activity],
                        onChanged: (bool? newValue) {
                          setState(() {
                            _activitiesParticipation[activity] = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                    // Açıklama Alanı
                    TextFormField(
                      controller: _activityDetailsController,
                      decoration: const InputDecoration(
                        labelText:
                            'Katıldığınız etkinlikler veya aldığınız görevler hakkında detay (isteğe bağlı)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 14.0,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
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
