import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kullanıcının içsel engellerini, korkularını ve bahanelerini anlamak için ekran
class InnerObstaclesScreen extends StatefulWidget {
  const InnerObstaclesScreen({super.key});

  @override
  State<InnerObstaclesScreen> createState() => _InnerObstaclesScreenState();
}

class _InnerObstaclesScreenState extends State<InnerObstaclesScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Form Alanları için State Değişkenleri ---

  // Soru 1: İçsel Engeller (Multi-select)
  final Map<String, bool> _internalBlockersOptions = {
    'Kendime İnanmıyorum / Yetersizlik Hissi': false,
    'Mükemmeliyetçilik (Başlayamama/Bitirememe)': false,
    'Başkalarıyla Kıyaslama': false,
    'Erteleme Alışkanlığı': false,
    'Kararsızlık / Odaklanamama': false,
    'Başlamaktan Korkmak': false,
    'Motivasyon Eksikliği': false, // Eklendi
    'Eleştirilme Korkusu': false, // Eklendi
  };

  // Soru 2: Başarısızlık Korkusu (Radio + Açıklama)
  String? _fearOfFailureStatus; // null, 'Evet', 'Hayır', 'Bazen'
  final List<String> _fearOfFailureOptions = ['Evet', 'Hayır', 'Bazen'];
  final TextEditingController _fearOfFailureDetailsController =
      TextEditingController();

  // Soru 3: Vazgeçme Durumu (TextField - İsteğe bağlı)
  final TextEditingController _gaveUpSituationController =
      TextEditingController();

  // Soru 4: Ön Koşul İnancı (TextField - İsteğe bağlı)
  final TextEditingController _prerequisiteBeliefController =
      TextEditingController();

  // Soru 5: Uygulamadan Beklenti (TextField)
  final TextEditingController _appExpectationController =
      TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // TODO: Kayıtlı veriyi yükleme (_loadSavedData)
  }

  @override
  void dispose() {
    _fearOfFailureDetailsController.dispose();
    _gaveUpSituationController.dispose();
    _prerequisiteBeliefController.dispose();
    _appExpectationController.dispose();
    super.dispose();
  }

  // --- Firestore'a Kaydetme Fonksiyonu ---
  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      /* Hata mesajı */
      return;
    }

    // Soru 1: Seçilen engelleri listele
    List<String> selectedInternalBlockers =
        _internalBlockersOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Kaydedilecek veriyi hazırla
    Map<String, dynamic> obstaclesData = {
      'internalBlockers': selectedInternalBlockers,
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

    try {
      // Firestore'a yaz: users/{userId}/profile_data/inner_obstacles
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('inner_obstacles') // Bu bölüm için belirli bir doküman
          .set(obstaclesData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İçsel engeller ve beklentiler kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pop(context); // İsteğe bağlı geri dön
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (İçsel Engeller): $e");
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
    // Manuel validasyon (Soru 2 Radio)
    if (_fearOfFailureStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen 2. soruda başarısızlık korkusu durumunuzu belirtin.',
          ),
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
      appBar: AppBar(title: const Text('İçsel Engeller & Motivasyon')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1: İçsel Engeller ---
              _buildQuestionCard(
                context: context,
                questionNumber: 1,
                questionText:
                    'Kendinizi geliştirmenize en çok engel olan içsel şey(ler) ne?',
                child: Column(
                  children:
                      _internalBlockersOptions.keys.map((blocker) {
                        return CheckboxListTile(
                          title: Text(blocker),
                          value: _internalBlockersOptions[blocker],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _internalBlockersOptions[blocker] = newValue!;
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

              // --- Soru 2: Başarısızlık Korkusu ---
              _buildQuestionCard(
                context: context,
                questionNumber: 2,
                questionText:
                    'Bir konuda başarısız olma korkunuz sizi hiç geri çekti mi?',
                child: Column(
                  children: [
                    // Radio seçenekleri
                    ..._fearOfFailureOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: _fearOfFailureStatus,
                        onChanged: (String? value) {
                          setState(() {
                            _fearOfFailureStatus = value;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                    // Evet veya Bazen seçilirse Açıklama Alanı
                    if (_fearOfFailureStatus == 'Evet' ||
                        _fearOfFailureStatus == 'Bazen')
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _fearOfFailureDetailsController,
                          decoration: const InputDecoration(
                            labelText:
                                'Nerede, ne zaman veya nasıl geri çektiğini kısaca anlatın (isteğe bağlı)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 14.0,
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ),
                  ],
                ),
                // Validasyon _submitForm içinde yapılıyor
              ),
              const SizedBox(height: 20.0),

              // --- Soru 3: Vazgeçme Durumu ---
              _buildQuestionCard(
                context: context,
                questionNumber: 3,
                questionText:
                    'En son bir hedef koyup vazgeçtiğiniz bir durumu hatırlıyor musunuz? (İsteğe bağlı)',
                child: TextFormField(
                  controller: _gaveUpSituationController,
                  decoration: const InputDecoration(
                    hintText: 'Kısaca anlatabilirsiniz...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 4: Ön Koşul İnancı ---
              _buildQuestionCard(
                context: context,
                questionNumber: 4,
                questionText:
                    '"Bunları yapabilmem için önce ___ olmam/yapmam lazım" dediğiniz bir şey var mı? (İsteğe bağlı)',
                child: TextFormField(
                  controller: _prerequisiteBeliefController,
                  decoration: const InputDecoration(
                    hintText:
                        'Örn: "İngilizce öğrenmeliyim", "Daha iyi bir bilgisayarım olmalı"...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 5: Uygulamadan Beklenti ---
              _buildQuestionCard(
                context: context,
                questionNumber: 5,
                questionText:
                    'Bu uygulamadan beklentiniz ne? Sizi gerçekten ne motive eder?',
                child: TextFormField(
                  controller: _appExpectationController,
                  decoration: const InputDecoration(
                    hintText:
                        'Örn: "Bana özel bir yol haritası çizilsin", "Takip edildiğimi hissetmek", "Yanlış yapmaktan korkuyorum, biri kontrol etsin"...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen uygulamadan beklentinizi kısaca belirtin.';
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
                          : const Text(
                            'Kaydet ve Profili Tamamla',
                          ), // Son kart olduğu için metni değiştirebiliriz
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
