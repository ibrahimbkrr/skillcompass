import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';
import 'personal_brand_card_screen.dart';

class SupportCommunityScreen extends StatefulWidget {
  const SupportCommunityScreen({super.key});

  @override
  State<SupportCommunityScreen> createState() => _SupportCommunityScreenState();
}

class _SupportCommunityScreenState extends State<SupportCommunityScreen> {
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
  final Map<String, bool> _problemSolvingMethods = {
    'Stack Overflow / Forumlar': false,
    'ChatGPT / Yapay Zeka Araçları': false,
    'Resmi Dokümantasyonlar': false,
    'Mentora / Deneyimli Birine Sormak': false,
    'Deneme Yanılma / Kendi Başıma Çözmeye Çalışmak': false,
    'Konuyu Geçici Olarak Bırakıp Sonra Dönmek': false,
  };

  // Soru 2
  String? _feedbackPreference;
  final List<String> _feedbackOptions = [
    'Evet, çok isterim',
    'Evet, duruma göre',
    'Hayır, pek tercih etmem',
  ];
  final TextEditingController _feedbackDetailsController =
      TextEditingController();

  // Soru 3
  String? _mentorshipPreference;
  final List<String> _mentorshipOptions = [
    'Evet, aktif olarak arıyorum',
    'Evet, fırsat olursa değerlendiririm',
    'Belki, emin değilim',
    'Hayır, şu an için düşünmüyorum',
  ];
  final TextEditingController _mentorshipDetailsController =
      TextEditingController();

  // Soru 4
  final Map<String, bool> _communityActivityOptions = {
    'Discord Sunucuları': false,
    'Telegram Grupları': false,
    'LinkedIn Grupları': false,
    'Üniversite Kulüpleri / Öğrenci Toplulukları': false,
    'Yerel Meetup Grupları': false,
    'Online Forumlar (Stack Overflow dışında)': false,
    'GitHub Tartışmaları / Issues': false,
    'Aktif Değilim': false,
  };

  // Soru 5
  bool? _hasSupportCircle;
  final TextEditingController _supportCircleDetailsController =
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
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        }
      });
    }
  }

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
              .doc('support_community_v2') // Versiyon 2
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (mounted) {
          _updateStateWithLoadedData(data);
        }
      }
    } catch (e) {
      print("HATA: support_community_v2 verisi yüklenemedi: $e");
      _loadingError = 'Kaydedilmiş veriler yüklenirken bir sorun oluştu.';
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
      List<String> savedMethods = List<String>.from(
        data['problemSolvingMethods'] ?? [],
      );
      _problemSolvingMethods.forEach((key, value) {
        _problemSolvingMethods[key] = savedMethods.contains(key);
      });
      _feedbackPreference = data['feedbackPreference'];
      if (!_feedbackOptions.contains(_feedbackPreference))
        _feedbackPreference = null;
      _feedbackDetailsController.text = data['feedbackDetails'] ?? '';
      _mentorshipPreference = data['mentorshipPreference'];
      if (!_mentorshipOptions.contains(_mentorshipPreference))
        _mentorshipPreference = null;
      _mentorshipDetailsController.text = data['mentorshipDetails'] ?? '';
      List<String> savedCommunities = List<String>.from(
        data['communityActivities'] ?? [],
      );
      _communityActivityOptions.forEach((key, value) {
        _communityActivityOptions[key] = savedCommunities.contains(key);
      });
      _hasSupportCircle = data['hasSupportCircle'];
      _supportCircleDetailsController.text = data['supportCircleDetails'] ?? '';
    });
  }

  @override
  void dispose() {
    _feedbackDetailsController.dispose();
    _mentorshipDetailsController.dispose();
    _supportCircleDetailsController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showFeedback('Oturum bulunamadı.', isError: true);
      return;
    }

    List<String> selectedProblemSolvingMethods =
        _problemSolvingMethods.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<String> selectedCommunityActivities =
        _communityActivityOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

    Map<String, dynamic> supportData = {
      'problemSolvingMethods': selectedProblemSolvingMethods,
      'feedbackPreference': _feedbackPreference,
      'feedbackDetails':
          (_feedbackPreference == _feedbackOptions[0] ||
                  _feedbackPreference == _feedbackOptions[1])
              ? _feedbackDetailsController.text.trim()
              : null,
      'mentorshipPreference': _mentorshipPreference,
      'mentorshipDetails':
          (_mentorshipPreference == _mentorshipOptions[0] ||
                  _mentorshipPreference == _mentorshipOptions[1] ||
                  _mentorshipPreference == _mentorshipOptions[2])
              ? _mentorshipDetailsController.text.trim()
              : null,
      'communityActivities': selectedCommunityActivities,
      'hasSupportCircle': _hasSupportCircle,
      'supportCircleDetails': _supportCircleDetailsController.text.trim(),
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
          .doc('support_community_v2') // Versiyon 2
          .set(supportData, SetOptions(merge: true));
      if (mounted) {
        _showFeedback(
          'Destek ve topluluk bilgileri kaydedildi!',
          isError: false,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Destek v2): $e");
      _showFeedback('Bilgiler kaydedilirken bir hata oluştu.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_feedbackPreference == null) {
      _showFeedback('Lütfen 2. soruyu yanıtlayın.', isError: true);
      return;
    }
    if (_mentorshipPreference == null) {
      _showFeedback('Lütfen 3. soruyu yanıtlayın.', isError: true);
      return;
    }
    if (_hasSupportCircle == null) {
      _showFeedback('Lütfen 5. soruyu yanıtlayın.', isError: true);
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;
    final isLoading = userProvider.isLoading;
    final error = userProvider.error;
    if (isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }
    if (error != null) {
      return Scaffold(
        body: ErrorMessage(message: 'Hata: $error'),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil: Destek & Topluluk'),
        elevation: 1,
      ),
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
                icon: Icons.help_center_rounded,
                questionText: 'Teknik Sorun Çözme Yaklaşımın',
                child: Column(
                  children:
                      _problemSolvingMethods.keys
                          .map(
                            (method) => CheckboxListTile(
                              title: Text(
                                method,
                                style: theme.textTheme.bodyLarge,
                              ),
                              value: _problemSolvingMethods[method],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _problemSolvingMethods[method] = newValue!;
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

              // --- Soru 2 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.reviews_rounded,
                questionText: 'Geri Bildirim Alma İsteğin',
                child: Column(
                  children: [
                    Text(
                      'Kod yazarken geri bildirim (code review, yorum vb.) almayı ister misin?',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._feedbackOptions
                        .map(
                          (option) => RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _feedbackPreference,
                            onChanged: (String? value) {
                              setState(() {
                                _feedbackPreference = value;
                              });
                            },
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    if (_feedbackPreference == _feedbackOptions[0] ||
                        _feedbackPreference == _feedbackOptions[1])
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _feedbackDetailsController,
                          decoration: customInputDecoration(
                            context,
                            'Ne tür geri bildirimler istersin? (isteğe bağlı)',
                          ),
                          maxLines: 2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 3 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.supervisor_account_rounded,
                questionText: 'Mentorluk İsteğin',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _mentorshipPreference,
                      hint: const Text('Mentorluk alma durumunuz...'),
                      isExpanded: true,
                      decoration: customInputDecoration(
                        context,
                        'Mentorluk İsteği',
                      ),
                      items:
                          _mentorshipOptions
                              .map(
                                (String option) => DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                ),
                              )
                              .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _mentorshipPreference = newValue;
                        });
                      } /* Validator _submitForm'da */,
                    ),
                    if (_mentorshipPreference == _mentorshipOptions[0] ||
                        _mentorshipPreference == _mentorshipOptions[1] ||
                        _mentorshipPreference == _mentorshipOptions[2])
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: TextFormField(
                          controller: _mentorshipDetailsController,
                          decoration: customInputDecoration(
                            context,
                            'Ne tür bir mentorluk arıyorsun? (isteğe bağlı)',
                          ),
                          maxLines: 2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 4 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.groups_2_rounded,
                questionText: 'Topluluk Aktifliğin',
                child: Column(
                  children: [
                    Text(
                      'Hangi teknik topluluklarda aktifsin?',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._communityActivityOptions.keys
                        .map(
                          (activity) => CheckboxListTile(
                            title: Text(
                              activity,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: _communityActivityOptions[activity],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _communityActivityOptions[activity] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 5 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.support_agent_rounded,
                questionText: 'Destek Çevren',
                child: Column(
                  children: [
                    Text(
                      'Etrafında gelişimine katkı sunan biri (arkadaş, eğitmen, abi/abla vb.) var mı?',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
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
                            activeColor: colorScheme.primary,
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
                            activeColor: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: _supportCircleDetailsController,
                        decoration: customInputDecoration(
                          context,
                          'Bu konudaki düşüncelerin/durumun (isteğe bağlı)',
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PersonalBrandCardScreen()),
                  );
                },
                child: const Text('Kişisel Marka Kartı'),
              ),
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
  InputDecoration customInputDecoration(
    BuildContext context,
    String label,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText:
          label.contains("açıklayın") ||
                  label.contains("detay") ||
                  label.contains("düşünceleriniz")
              ? 'Detayları buraya yazın...'
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
