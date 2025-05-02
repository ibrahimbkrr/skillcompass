import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kullanıcının teknik profilini ve uygulama deneyimini almak için geliştirilmiş ekran
class TechnicalProfileScreen extends StatefulWidget {
  const TechnicalProfileScreen({super.key});

  @override
  State<TechnicalProfileScreen> createState() => _TechnicalProfileScreenState();
}

class _TechnicalProfileScreenState extends State<TechnicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Form Alanları için State Değişkenleri ---

  // Soru 1: Teknik Beceriler (Dinamik Liste)
  // Kullanıcının eklediği becerileri tutacak liste
  // Her eleman {'skill': 'Beceri Adı', 'level': 'Seviye'} formatında olacak
  final List<Map<String, String>> _userSkills = [];
  final List<String> _levelOptions = ['Beginner', 'Intermediate', 'Advanced'];
  final TextEditingController _otherSkillsNotesController =
      TextEditingController(); // Ek notlar için

  // Soru 2: Çalışılan/Denenen Alanlar
  final Map<String, bool> _experiencedAreasOptions = {
    'Web Geliştirme (Frontend)': false,
    'Web Geliştirme (Backend)': false,
    'Mobil Uygulama Geliştirme': false,
    'Veri Bilimi / Analizi': false,
    'Yapay Zeka / Makine Öğrenmesi': false,
    'Oyun Geliştirme': false,
    'Siber Güvenlik': false,
    'DevOps / Sistem Yönetimi': false,
    'Veritabanı Yönetimi': false,
    'Gömülü Sistemler': false,
  };

  // Soru 3: Proje Örnekleri
  final TextEditingController _projectExamplesController =
      TextEditingController();

  // Soru 4: Zorlanılan Alanlar
  final Map<String, bool> _struggledAreasOptions = {
    'Algoritma / Veri Yapıları': false,
    'Backend Mimarisi / Ölçekleme': false,
    'Frontend Tasarım / UX': false,
    'Veritabanı Optimizasyonu': false,
    'Test Yazma / Otomasyon': false,
    'Deployment / CI/CD': false,
    'Güvenlik Açıkları': false,
    'Performans Optimizasyonu': false,
    'Yeni Teknolojilere Adapte Olma': false,
  };
  final TextEditingController _struggleDetailsController =
      TextEditingController();

  // Soru 5: Üretim Ortamı Deneyimi
  String? _selectedProductionExperience;
  final List<String> _productionExperienceOptions = [
    'Evet, yer aldım.',
    'Hayır, henüz yer almadım.',
    'Denemeyi / Yer almayı düşünüyorum.',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // TODO: Kayıtlı veriyi yükleme (_loadSavedData)
    // Örneğin, Firestore'dan _userSkills listesini çekip doldurabiliriz.
  }

  @override
  void dispose() {
    _otherSkillsNotesController.dispose();
    _projectExamplesController.dispose();
    _struggleDetailsController.dispose();
    super.dispose();
  }

  // --- Beceri Ekleme Dialog'unu Gösterme Fonksiyonu ---
  Future<void> _showAddSkillDialog() async {
    final skillNameController = TextEditingController();
    String? selectedLevel; // Dialog içindeki seçili seviye

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dışarı tıklayınca kapanmasın
      builder: (BuildContext context) {
        // Dialog state'ini yönetmek için StatefulBuilder kullanıyoruz
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Yeni Teknik Beceri Ekle'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: skillNameController,
                      decoration: const InputDecoration(
                        hintText: "Beceri adı (örn: Python, React)",
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedLevel,
                      hint: const Text('Seviye Seçin'),
                      items:
                          _levelOptions.map((String level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          // Dialog'un state'ini güncelle
                          selectedLevel = newValue;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Lütfen seviye seçin' : null,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('İptal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Ekle'),
                  onPressed: () {
                    // Beceri adı ve seviye girilmiş mi kontrol et
                    if (skillNameController.text.trim().isNotEmpty &&
                        selectedLevel != null) {
                      setState(() {
                        // Ana ekranın state'ini güncelle
                        _userSkills.add({
                          'skill': skillNameController.text.trim(),
                          'level': selectedLevel!,
                        });
                      });
                      Navigator.of(context).pop(); // Dialog'u kapat
                    } else {
                      // Kullanıcıya uyarı gösterilebilir
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen beceri adı ve seviye girin.'),
                          backgroundColor: Colors.orangeAccent,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  // -------------------------------------------------

  // --- Firestore'a Kaydetme Fonksiyonu (Güncellendi) ---
  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      /* Hata mesajı */
      return;
    }

    // Soru 1: Dinamik _userSkills listesi zaten hazır
    // Soru 2: Seçilen alanları listele
    List<String> experiencedAreas =
        _experiencedAreasOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
    // Soru 4: Seçilen zorlanılan alanları listele
    List<String> struggledAreas =
        _struggledAreasOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Kaydedilecek veriyi hazırla
    Map<String, dynamic> technicalData = {
      'userSkills': _userSkills, // Güncellenmiş beceri listesi
      'otherSkillsNotes': _otherSkillsNotesController.text.trim(), // Ek notlar
      'experiencedAreas': experiencedAreas,
      'projectExamples': _projectExamplesController.text.trim(),
      'struggledAreas': struggledAreas,
      'struggleDetails': _struggleDetailsController.text.trim(),
      'productionExperience': _selectedProductionExperience,
      'lastUpdated': Timestamp.now(),
    };

    try {
      // Firestore'a yazma işlemi (Aynı kaldı)
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('technical_profile')
          .set(technicalData, SetOptions(merge: true));

      if (mounted) {
        /* Başarı mesajı */
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teknik profil bilgileri başarıyla kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Teknik Profil): $e");
      if (mounted) {
        /* Hata mesajı */
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: Teknik bilgiler kaydedilemedi. $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // -------------------------------------------------

  // Formu Kaydetme Ana Fonksiyonu (Değişiklik yok)
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      /* Hata mesajı */
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
      appBar: AppBar(title: const Text('Teknik Profil & Deneyim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1: Teknik Beceriler (Yeniden Tasarlandı) ---
              _buildQuestionCard(
                context: context,
                questionNumber: 1,
                questionText: 'Hangi teknik becerilere sahipsiniz?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eklenen becerileri gösterme alanı
                    _userSkills.isEmpty
                        ? const Text(
                          'Henüz beceri eklemediniz.',
                          style: TextStyle(color: Colors.grey),
                        )
                        : Wrap(
                          // Chip'leri yan yana sığdır
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children:
                              _userSkills.map((skillData) {
                                return Chip(
                                  label: Text(
                                    '${skillData['skill']} (${skillData['level']})',
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _userSkills.remove(skillData);
                                    });
                                  },
                                  deleteIconColor: Colors.redAccent,
                                  backgroundColor: Colors.blueGrey[50],
                                  labelStyle: const TextStyle(fontSize: 13),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 2.0,
                                  ),
                                );
                              }).toList(),
                        ),
                    const SizedBox(height: 15),
                    // Beceri Ekle Butonu
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Beceri Ekle'),
                      onPressed: _showAddSkillDialog, // Dialog'u aç
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Farklı bir renk
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Ek Notlar Alanı
                    TextFormField(
                      controller: _otherSkillsNotesController,
                      decoration: const InputDecoration(
                        labelText:
                            'Eklemek istediğiniz diğer notlar/beceriler (isteğe bağlı)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 14.0,
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 2: Çalışılan/Denenen Alanlar ---
              _buildQuestionCard(
                context: context,
                questionNumber: 2,
                questionText:
                    'Şimdiye kadar hangi alanlarda çalıştınız veya denediniz?',
                child: Wrap(
                  /* ... CheckboxListTile ... */
                  spacing: 8.0,
                  runSpacing: 0.0,
                  children:
                      _experiencedAreasOptions.keys.map((option) {
                        return SizedBox(
                          child: CheckboxListTile(
                            /* ... */
                            title: Text(
                              option,
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: _experiencedAreasOptions[option],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _experiencedAreasOptions[option] = newValue!;
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

              // --- Soru 3: Proje Örnekleri ---
              _buildQuestionCard(
                context: context,
                questionNumber: 3,
                questionText:
                    'En iyi bildiğiniz teknolojileri hangi projelerde kullandınız? (Kısaca açıklayın)',
                child: TextFormField(
                  /* ... */
                  controller: _projectExamplesController,
                  decoration: const InputDecoration(
                    hintText:
                        'Örn: "Django ile staj projesinde admin paneli yaptım."...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen en az bir proje örneği verin.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 4: Zorlanılan Alanlar ---
              _buildQuestionCard(
                context: context,
                questionNumber: 4,
                questionText:
                    'Proje yaparken teknik olarak en çok hangi alanlarda zorlandınız?',
                child: Column(
                  /* ... Wrap ve TextFormField ... */
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      /* ... CheckboxListTile ... */
                      spacing: 8.0,
                      runSpacing: 0.0,
                      children:
                          _struggledAreasOptions.keys.map((option) {
                            return SizedBox(
                              child: CheckboxListTile(
                                /* ... */
                                title: Text(
                                  option,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: _struggledAreasOptions[option],
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _struggledAreasOptions[option] = newValue!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      /* ... */
                      controller: _struggleDetailsController,
                      decoration: const InputDecoration(
                        labelText:
                            'Zorlandığınız durumları kısaca açıklayınız (isteğe bağlı)',
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
              const SizedBox(height: 20.0),

              // --- Soru 5: Üretim Ortamı Deneyimi ---
              _buildQuestionCard(
                context: context,
                questionNumber: 5,
                questionText:
                    'Açık kaynak ya da freelance gibi üretim ortamlarında yer aldınız mı?',
                child: DropdownButtonFormField<String>(
                  /* ... */
                  value: _selectedProductionExperience,
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
                      _productionExperienceOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedProductionExperience = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen durumunuzu seçin';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32.0),

              // --- Kaydet Butonu ---
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
