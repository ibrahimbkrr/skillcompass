import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LearningThinkingStyleScreen extends StatefulWidget {
  const LearningThinkingStyleScreen({super.key});

  @override
  State<LearningThinkingStyleScreen> createState() =>
      _LearningThinkingStyleScreenState();
}

class _LearningThinkingStyleScreenState
    extends State<LearningThinkingStyleScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Form Alanları için State Değişkenleri ---
  final Map<String, bool> _learningMethodsOptions = {
    'Görsel / Video İzleyerek': false,
    'Okuyarak (Doküman, Kitap, Blog)': false,
    'Proje Yaparak / Uygulayarak': false,
    'Başkasına Anlatırken / Öğretirken': false,
    'Deneme Yanılma Yoluyla': false,
    'Yapılandırılmış Kurslarla': false,
  };
  String? _selectedLearningStyle;
  final List<String> _learningStyleOptions = [
    'Ezberci (Tanımları ve kuralları ezberlerim)',
    'Uygulamacı (Hemen denemek ve yapmak isterim)',
    'Meraklı Araştırmacı (Derinlemesine inmeyi severim)',
    'Yavaş Sindiren (Konunun oturması için zamana ihtiyacım olur)',
    'Sosyal Öğrenici (Başkalarıyla tartışarak öğrenirim)',
    'Hedef Odaklı (Sadece gerekeni öğrenirim)',
  ];
  double _algorithmDifficulty = 5.0;
  final Map<String, bool> _researchResourcesOptions = {
    'Resmi Dokümantasyonlar': false,
    'Stack Overflow / Forumlar': false,
    'YouTube / Video Platformları': false,
    'Medium / Teknik Bloglar': false,
    'ChatGPT / Yapay Zeka Araçları': false,
    'Kitaplar / E-kitaplar': false,
    'Online Kurs İçerikleri': false,
    'Tanıdıklar / Mentorlar': false,
  };
  final TextEditingController _otherResourcesController =
      TextEditingController();
  final TextEditingController _retentionMethodController =
      TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // TODO: Kayıtlı veriyi yükleme (_loadSavedData)
  }

  @override
  void dispose() {
    _otherResourcesController.dispose();
    _retentionMethodController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      /* Hata mesajı */
      return;
    }

    List<String> selectedLearningMethods =
        _learningMethodsOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
    List<String> selectedResearchResources =
        _researchResourcesOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    Map<String, dynamic> learningData = {
      'learningMethods': selectedLearningMethods,
      'learningStyle': _selectedLearningStyle,
      'algorithmDifficulty': _algorithmDifficulty.round(),
      'researchResources': selectedResearchResources,
      'otherResearchResources': _otherResourcesController.text.trim(),
      'retentionMethod': _retentionMethodController.text.trim(),
      'lastUpdated': Timestamp.now(),
    };

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('learning_thinking_style')
          .set(learningData, SetOptions(merge: true));
      if (mounted) {
        /* Başarı mesajı */
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenme ve düşünme stili bilgileri kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Öğrenme Stili): $e");
      if (mounted) {
        /* Hata mesajı */
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
    // Öğrenme tarzı seçilmiş mi diye kontrol edelim (RadioListTile için manuel validasyon)
    if (_selectedLearningStyle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 2. soruda öğrenme tarzınızı seçin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Seçilmemişse formu gönderme
    }

    // Diğer form alanlarının validasyonunu yap
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
      appBar: AppBar(title: const Text('Düşünme & Öğrenme Stili')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Soru 1 ---
              _buildQuestionCard(
                context: context,
                questionNumber: 1,
                questionText:
                    'Yeni bir konuyu öğrenirken en çok hangi yöntemleri kullanırsınız?',
                child: Column(
                  /* ... CheckboxListTile ... */
                  children:
                      _learningMethodsOptions.keys.map((option) {
                        return CheckboxListTile(
                          /* ... */
                          title: Text(option),
                          value: _learningMethodsOptions[option],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _learningMethodsOptions[option] = newValue!;
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

              // --- Soru 2 ---
              _buildQuestionCard(
                context: context,
                questionNumber: 2,
                questionText:
                    'Sizce nasıl bir öğrenme tarzına sahipsiniz? (Lütfen birini seçin)',
                child: Column(
                  /* ... RadioListTile ... */
                  children:
                      _learningStyleOptions.map((style) {
                        return RadioListTile<String>(
                          /* ... */
                          title: Text(style),
                          value: style,
                          groupValue: _selectedLearningStyle,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedLearningStyle = value;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                ),
                // --- HATALI VALIDATOR KALDIRILDI ---
              ),
              const SizedBox(height: 20.0),

              // --- Soru 3 ---
              _buildQuestionCard(
                context: context,
                questionNumber: 3,
                questionText:
                    'Algoritma veya sistem mantığı konuları sizi ne kadar zorluyor?',
                child: Column(
                  /* ... Slider ve Açıklamalar ... */
                  children: [
                    Slider(
                      /* ... */
                      value: _algorithmDifficulty,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _algorithmDifficulty.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _algorithmDifficulty = value;
                        });
                      },
                    ),
                    Row(
                      /* ... Açıklamalar ... */
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1\n(Çok Kolay)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '10\n(Çok Zor)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 4 ---
              _buildQuestionCard(
                context: context,
                questionNumber: 4,
                questionText:
                    'Bilmediğiniz bir şeyi araştırırken ilk başvurduğunuz kaynaklar nelerdir?',
                child: Column(
                  /* ... Wrap ve TextFormField ... */
                  children: [
                    Wrap(
                      /* ... CheckboxListTile ... */
                      spacing: 8.0,
                      runSpacing: 0.0,
                      children:
                          _researchResourcesOptions.keys.map((option) {
                            return SizedBox(
                              /* ... */
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: CheckboxListTile(
                                /* ... */
                                title: Text(
                                  option,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: _researchResourcesOptions[option],
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _researchResourcesOptions[option] =
                                        newValue!;
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
                      /* ... Diğer Kaynaklar ... */
                      controller: _otherResourcesController,
                      decoration: const InputDecoration(
                        labelText: 'Listede olmayan diğer kaynaklar (varsa)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Soru 5 ---
              _buildQuestionCard(
                context: context,
                questionNumber: 5,
                questionText:
                    'Öğrendiklerinizi kalıcı hale getirmek için nasıl tekrar yaparsınız?',
                child: TextFormField(
                  /* ... Tekrar Yöntemi ... */
                  controller: _retentionMethodController,
                  decoration: const InputDecoration(
                    hintText: 'Örn: "Not çıkarırım", "Mini proje yazarım"...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen tekrar yönteminizi kısaca açıklayın.';
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
