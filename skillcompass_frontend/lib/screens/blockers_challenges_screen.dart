import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kullanıcının tıkanma noktalarını ve eksiklerini anlamak için ekran
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

  // --- Form Alanları için State Değişkenleri ---

  // Soru 1: Zorlanılan Teknik Konular (Multi-select + Açıklama)
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
  };
  final TextEditingController _topicDetailsController = TextEditingController();

  // Soru 2: İlerleme Zorluğu Nedenleri (Multi-select)
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

  // Soru 3: İlerleyememe Hissi (Radio + Açıklama)
  String? _feelingStuckStatus; // null, 'Evet', 'Hayır', 'Bazen'
  final List<String> _feelingStuckOptions = ['Evet', 'Hayır', 'Bazen'];
  final TextEditingController _feelingStuckDetailsController =
      TextEditingController();

  // Soru 4: Kod Yazarken En Zorlayan Şey (TextField)
  final TextEditingController _codingChallengeController =
      TextEditingController();

  // Soru 5: "Öğrenmeden İlerleyemem" Konusu (TextField - İsteğe bağlı)
  final TextEditingController _mustLearnTopicController =
      TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // TODO: Kayıtlı veriyi yükleme (_loadSavedData)
  }

  @override
  void dispose() {
    _topicDetailsController.dispose();
    _feelingStuckDetailsController.dispose();
    _codingChallengeController.dispose();
    _mustLearnTopicController.dispose();
    super.dispose();
  }

  // --- Firestore'a Kaydetme Fonksiyonu ---
  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      /* Hata mesajı */
      return;
    }

    // Soru 1: Seçilen konuları listele
    List<String> selectedStruggledTopics =
        _struggledTopicsOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Soru 2: Seçilen nedenleri listele
    List<String> selectedProgressionBlockers =
        _progressionBlockersOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Kaydedilecek veriyi hazırla
    Map<String, dynamic> blockersData = {
      'struggledTopics': selectedStruggledTopics,
      'struggledTopicsDetails': _topicDetailsController.text.trim(),
      'progressionBlockers': selectedProgressionBlockers,
      'feelingStuckStatus': _feelingStuckStatus,
      'feelingStuckDetails':
          (_feelingStuckStatus == 'Evet' || _feelingStuckStatus == 'Bazen')
              ? _feelingStuckDetailsController.text.trim()
              : null, // Sadece ilgiliyse detayı kaydet
      'codingChallenge': _codingChallengeController.text.trim(),
      'mustLearnTopic':
          _mustLearnTopicController.text
              .trim(), // İsteğe bağlı olduğu için trim yeterli
      'lastUpdated': Timestamp.now(),
    };

    try {
      // Firestore'a yaz: users/{userId}/profile_data/blockers_challenges
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('blockers_challenges') // Bu bölüm için belirli bir doküman
          .set(blockersData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Engeller ve eksikler bilgisi kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pop(context); // İsteğe bağlı geri dön
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Engeller): $e");
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
    // Manuel validasyon (Soru 3 Radio)
    if (_feelingStuckStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 3. soruda ilerleme hissinizi belirtin.'),
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
      appBar: AppBar(title: const Text('Engeller & Gelişim Alanları')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1: Zorlanılan Teknik Konular ---
              _buildQuestionCard(
                context: context,
                questionNumber: 1,
                questionText:
                    'Öğrenmekte veya uygulamakta zorlandığınız teknik konular neler?',
                child: Column(
                  children: [
                    // Checkbox seçenekleri
                    ..._struggledTopicsOptions.keys.map((topic) {
                      return CheckboxListTile(
                        title: Text(topic),
                        value: _struggledTopicsOptions[topic],
                        onChanged: (bool? newValue) {
                          setState(() {
                            _struggledTopicsOptions[topic] = newValue!;
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
                      controller: _topicDetailsController,
                      decoration: const InputDecoration(
                        labelText:
                            'Bu konulardaki zorluklarınızı kısaca açıklayın (isteğe bağlı)',
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

              // --- Soru 2: İlerleme Zorluğu Nedenleri ---
              _buildQuestionCard(
                context: context,
                questionNumber: 2,
                questionText: 'Sizce neden ilerlemekte zorlanıyorsunuz?',
                child: Column(
                  children:
                      _progressionBlockersOptions.keys.map((blocker) {
                        return CheckboxListTile(
                          title: Text(blocker),
                          value: _progressionBlockersOptions[blocker],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _progressionBlockersOptions[blocker] = newValue!;
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

              // --- Soru 3: İlerleyememe Hissi ---
              _buildQuestionCard(
                context: context,
                questionNumber: 3,
                questionText:
                    'Teknik bilginiz olmasına rağmen ilerleyemiyormuş gibi hissediyor musunuz?',
                child: Column(
                  children: [
                    // Radio seçenekleri
                    ..._feelingStuckOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: _feelingStuckStatus,
                        onChanged: (String? value) {
                          setState(() {
                            _feelingStuckStatus = value;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                    // Evet veya Bazen seçilirse Açıklama Alanı
                    if (_feelingStuckStatus == 'Evet' ||
                        _feelingStuckStatus == 'Bazen')
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _feelingStuckDetailsController,
                          decoration: const InputDecoration(
                            labelText:
                                'Bu hissin nedenini kısaca açıklayın (isteğe bağlı)',
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

              // --- Soru 4: Kod Yazarken En Zorlayan Şey ---
              _buildQuestionCard(
                context: context,
                questionNumber: 4,
                questionText: 'Kod yazarken sizi en çok zorlayan şey ne?',
                child: TextFormField(
                  controller: _codingChallengeController,
                  decoration: const InputDecoration(
                    hintText:
                        'Örn: Hataları bulup çözmek, doğru yapıyı kurmak, nereden başlayacağımı bilememek...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen sizi en çok zorlayan şeyi belirtin.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 5: "Öğrenmeden İlerleyemem" Konusu ---
              _buildQuestionCard(
                context: context,
                questionNumber: 5,
                questionText:
                    'Şu an "şu konuyu öğrenmeden ilerleyemem" dediğiniz bir şey var mı?',
                child: TextFormField(
                  controller: _mustLearnTopicController,
                  decoration: const InputDecoration(
                    hintText: 'Varsa belirtin (isteğe bağlı)...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  // Validator yok, isteğe bağlı alan
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
