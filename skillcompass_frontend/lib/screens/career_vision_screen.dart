import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kullanıcının kariyer vizyonunu ve hedeflerini anlamak için ekran
class CareerVisionScreen extends StatefulWidget {
  const CareerVisionScreen({super.key});

  @override
  State<CareerVisionScreen> createState() => _CareerVisionScreenState();
}

class _CareerVisionScreenState extends State<CareerVisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Form Alanları için State Değişkenleri ---

  // Soru 1: 1 Yıl Sonraki Rol
  final TextEditingController _oneYearGoalController = TextEditingController();

  // Soru 2: 5 Yıl Sonraki Başarı
  final TextEditingController _fiveYearGoalController = TextEditingController();

  // Soru 3: Hedef Teknik Rol(ler) (Multi-select)
  final Map<String, bool> _targetRolesOptions = {
    'Frontend Developer': false,
    'Backend Developer': false,
    'Full-Stack Developer': false,
    'Mobile Developer (Android/iOS/Cross-Platform)': false,
    'Game Developer': false,
    'AI/Machine Learning Engineer': false,
    'Data Scientist / Analyst': false,
    'Cyber Security Specialist': false,
    'DevOps Engineer': false,
    'Cloud Engineer (AWS/Azure/GCP)': false,
    'Database Administrator (DBA)': false,
    'UI/UX Designer': false,
    'Product Manager': false,
    'Project Manager / Scrum Master': false,
    'Akademisyen / Araştırmacı': false,
  };

  // Soru 4: Hedef Sektör(ler) (Multi-select)
  final Map<String, bool> _targetSectorsOptions = {
    'Finans / Bankacılık (Fintech)': false,
    'Sağlık Teknolojileri': false,
    'Eğitim Teknolojileri (Edtech)': false,
    'Oyun Sektörü': false,
    'Savunma Sanayi': false,
    'E-ticaret': false,
    'Telekomünikasyon': false,
    'Medya / Eğlence': false,
    'Kamu Sektörü': false,
    'Danışmanlık': false,
    'Otomotiv': false,
    'Perakende': false,
    'Startup Ekosistemi (Genel)': false,
  };

  // Soru 5: Hedeflerin Önemi
  final TextEditingController _goalImportanceController =
      TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // TODO: Kayıtlı veriyi yükleme (_loadSavedData)
  }

  @override
  void dispose() {
    _oneYearGoalController.dispose();
    _fiveYearGoalController.dispose();
    _goalImportanceController.dispose();
    super.dispose();
  }

  // --- Firestore'a Kaydetme Fonksiyonu ---
  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      /* Hata mesajı */
      return;
    }

    // Soru 3: Seçilen rolleri listele
    List<String> selectedTargetRoles =
        _targetRolesOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Soru 4: Seçilen sektörleri listele
    List<String> selectedTargetSectors =
        _targetSectorsOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Kaydedilecek veriyi hazırla
    Map<String, dynamic> visionData = {
      'oneYearRoleGoal': _oneYearGoalController.text.trim(),
      'fiveYearAchievementGoal': _fiveYearGoalController.text.trim(),
      'targetTechnicalRoles': selectedTargetRoles,
      'targetSectors': selectedTargetSectors,
      'goalImportance': _goalImportanceController.text.trim(),
      'lastUpdated': Timestamp.now(),
    };

    try {
      // Firestore'a yaz: users/{userId}/profile_data/career_vision
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('career_vision') // Bu bölüm için belirli bir doküman
          .set(visionData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kariyer vizyonu bilgileri kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pop(context); // İsteğe bağlı geri dön
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Vizyon): $e");
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
      appBar: AppBar(title: const Text('Kariyer Vizyonu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1: 1 Yıl Sonraki Rol ---
              _buildQuestionCard(
                context: context,
                questionNumber: 1,
                questionText:
                    'Kendinizi 1 yıl sonra nasıl bir rolde görmek istiyorsunuz?',
                child: TextFormField(
                  controller: _oneYearGoalController,
                  decoration: const InputDecoration(
                    hintText:
                        'Örn: Junior Web Developer, Stajyer Mobil Geliştirici...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen 1 yıllık hedefinizi belirtin.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 2: 5 Yıl Sonraki Başarı ---
              _buildQuestionCard(
                context: context,
                questionNumber: 2,
                questionText: '5 yıl sonra ne başarmış olmayı istiyorsunuz?',
                child: TextFormField(
                  controller: _fiveYearGoalController,
                  decoration: const InputDecoration(
                    hintText:
                        'Örn: Yurt dışında çalışmak, Kendi startup\'ımı kurmak, Teknik lider olmak...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen 5 yıllık vizyonunuzu belirtin.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 3: Hedef Teknik Rol(ler) ---
              _buildQuestionCard(
                context: context,
                questionNumber: 3,
                questionText: 'Hedeflediğiniz teknik rol(ler) neler?',
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 0.0,
                  children:
                      _targetRolesOptions.keys.map((role) {
                        return SizedBox(
                          width:
                              MediaQuery.of(context).size.width *
                              0.42, // Sığdırma
                          child: CheckboxListTile(
                            title: Text(
                              role,
                              style: const TextStyle(fontSize: 13),
                            ),
                            value: _targetRolesOptions[role],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _targetRolesOptions[role] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      }).toList(),
                ),
                // Not: En az bir tane seçilmesi _submitForm'da kontrol edilebilir.
              ),
              const SizedBox(height: 20.0),

              // --- Soru 4: Hedef Sektör(ler) ---
              _buildQuestionCard(
                context: context,
                questionNumber: 4,
                questionText: 'Hedeflediğiniz sektör(ler) var mı?',
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 0.0,
                  children:
                      _targetSectorsOptions.keys.map((sector) {
                        return SizedBox(
                          width:
                              MediaQuery.of(context).size.width *
                              0.42, // Sığdırma
                          child: CheckboxListTile(
                            title: Text(
                              sector,
                              style: const TextStyle(fontSize: 13),
                            ),
                            value: _targetSectorsOptions[sector],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _targetSectorsOptions[sector] = newValue!;
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

              // --- Soru 5: Hedeflerin Önemi ---
              _buildQuestionCard(
                context: context,
                questionNumber: 5,
                questionText: 'Bu hedefler sizin için neden önemli?',
                child: TextFormField(
                  controller: _goalImportanceController,
                  decoration: const InputDecoration(
                    hintText:
                        'Motivasyonunuzu, değerlerinizi kısaca açıklayın...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen hedeflerinizin neden önemli olduğunu belirtin.';
                    }
                    return null;
                  },
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
