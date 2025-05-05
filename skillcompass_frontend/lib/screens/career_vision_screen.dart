import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CareerVisionScreen extends StatefulWidget {
  const CareerVisionScreen({super.key});

  @override
  State<CareerVisionScreen> createState() => _CareerVisionScreenState();
}

class _CareerVisionScreenState extends State<CareerVisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- State Değişkenleri ---
  User? _currentUser;
  bool _isLoadingPage = true;
  bool _isSaving = false;
  String _loadingError = '';

  // Form Alanları
  String? _selectedOneYearTheme;
  final List<String> _oneYearThemeOptions = [
    'İşe/Staja Başlamak',
    'Teknik Uzmanlık Kazanmak',
    'Mevcut Rolde Gelişmek',
    'Proje Tamamlamak/Yayınlamak',
    'Freelance/Ek Gelir',
    'Sertifika/Eğitim Tamamlamak',
  ];
  final TextEditingController _oneYearDetailsController =
      TextEditingController();

  String? _selectedFiveYearTheme;
  final List<String> _fiveYearThemeOptions = [
    'Teknik Liderlik/Mimarlık',
    'Yöneticilik',
    'Girişimcilik/Kendi İşim',
    'Global Kariyer/Yurt Dışı',
    'Alanında Derin Uzmanlık',
    'Akademik Kariyer',
    'Finansal Hedefler',
    'Toplumsal Etki/Katkı',
  ];
  final TextEditingController _fiveYearDetailsController =
      TextEditingController();

  final List<String> _selectedTargetRoles = [];
  final List<String> _allTargetRolesOptions = [
    'Frontend Developer',
    'Backend Developer',
    'Full-Stack Developer',
    'Mobile Developer (Android)',
    'Mobile Developer (iOS)',
    'Mobile Developer (Flutter/RN)',
    'Game Developer',
    'AI/Machine Learning Engineer',
    'Data Scientist / Analyst',
    'Cyber Security Specialist',
    'DevOps Engineer',
    'Cloud Engineer (AWS/Azure/GCP)',
    'Database Administrator (DBA)',
    'UI/UX Designer',
    'Product Manager',
    'Project Manager / Scrum Master',
    'Akademisyen / Araştırmacı',
    'Teknik Lider / Yönetici',
    'Diğer Teknik Rol',
  ];

  final List<String> _selectedTargetSectors = [];
  final List<String> _allTargetSectorsOptions = [
    'Finans / Bankacılık (Fintech)',
    'Sağlık Teknolojileri (Healthtech)',
    'Eğitim Teknolojileri (Edtech)',
    'Oyun Sektörü',
    'Savunma Sanayi',
    'E-ticaret / Perakende',
    'Telekomünikasyon',
    'Medya / Eğlence',
    'Kamu Sektörü',
    'Danışmanlık',
    'Otomotiv',
    'Enerji',
    'Lojistik / Ulaşım',
    'Turizm / Konaklama',
    'Startup Ekosistemi (Genel)',
    'Sektör Bağımsız / Farketmez',
  ];

  final Map<String, bool> _motivationSourcesOptions = {
    'Öğrenme & Gelişim Tutkusu': false,
    'Problem Çözme Yeteneği': false,
    'Maddi Güvenlik & Kazanç': false,
    'Kariyerde Yükselme & Statü': false,
    'Etki Yaratma & Değer Katma': false,
    'Esneklik & Bağımsızlık': false,
    'Yaratıcılık & Üretkenlik': false,
    'Teknolojiye Olan İlgi': false,
    'Diğer (Açıklayınız)': false,
  };
  final TextEditingController _otherMotivationController =
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
              .doc('career_vision_v5') // Versiyon 5
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (mounted) {
          _updateStateWithLoadedData(data);
        }
      }
    } catch (e) {
      print("HATA: career_vision_v5 verisi yüklenemedi: $e");
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
      _selectedOneYearTheme = data['oneYearGoalTheme'];
      if (!_oneYearThemeOptions.contains(_selectedOneYearTheme))
        _selectedOneYearTheme = null;
      _oneYearDetailsController.text = data['oneYearGoalDetails'] ?? '';
      _selectedFiveYearTheme = data['fiveYearVisionTheme'];
      if (!_fiveYearThemeOptions.contains(_selectedFiveYearTheme))
        _selectedFiveYearTheme = null;
      _fiveYearDetailsController.text = data['fiveYearVisionDetails'] ?? '';
      _selectedTargetRoles.clear();
      _selectedTargetRoles.addAll(
        List<String>.from(data['targetTechnicalRoles'] ?? []),
      );
      _selectedTargetSectors.clear();
      _selectedTargetSectors.addAll(
        List<String>.from(data['targetSectors'] ?? []),
      );
      List<String> motivations = List<String>.from(
        data['motivationSources'] ?? [],
      );
      _motivationSourcesOptions.forEach((key, value) {
        _motivationSourcesOptions[key] = motivations.contains(key);
      });
      _otherMotivationController.text = data['otherMotivation'] ?? '';
    });
  }

  @override
  void dispose() {
    _oneYearDetailsController.dispose();
    _fiveYearDetailsController.dispose();
    _otherMotivationController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showFeedback('Oturum bulunamadı.', isError: true);
      return;
    }

    List<String> selectedMotivations =
        _motivationSourcesOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

    Map<String, dynamic> visionData = {
      'oneYearGoalTheme': _selectedOneYearTheme,
      'oneYearGoalDetails': _oneYearDetailsController.text.trim(),
      'fiveYearVisionTheme': _selectedFiveYearTheme,
      'fiveYearVisionDetails': _fiveYearDetailsController.text.trim(),
      'targetTechnicalRoles': _selectedTargetRoles,
      'targetSectors': _selectedTargetSectors,
      'motivationSources': selectedMotivations,
      'otherMotivation':
          _motivationSourcesOptions['Diğer (Açıklayınız)'] == true
              ? _otherMotivationController.text.trim()
              : null,
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
          .doc('career_vision_v5') // Versiyon 5
          .set(visionData, SetOptions(merge: true));
      if (mounted) {
        _showFeedback('Kariyer vizyonu bilgileri kaydedildi!', isError: false);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Vizyon v5): $e");
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
    if (_selectedOneYearTheme == null) {
      _showFeedback('Lütfen 1. soruyu yanıtlayın.', isError: true);
      return;
    }
    if (_selectedFiveYearTheme == null) {
      _showFeedback('Lütfen 2. soruyu yanıtlayın.', isError: true);
      return;
    }
    if (_selectedTargetRoles.isEmpty) {
      _showFeedback(
        'Lütfen 3. soruda en az bir hedef rol seçin.',
        isError: true,
      );
      return;
    }
    if (!_motivationSourcesOptions.containsValue(true)) {
      _showFeedback(
        'Lütfen 5. soruda en az bir motivasyon kaynağı seçin.',
        isError: true,
      );
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

  Future<void> _showMultiSelectDialog({
    required String title,
    required List<String> allOptions,
    required List<String> currentlySelected,
    required Function(List<String>) onConfirm,
  }) async {
    List<String> tempSelected = List.from(currentlySelected);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allOptions.length,
                  itemBuilder: (context, index) {
                    final option = allOptions[index];
                    final bool isSelected = tempSelected.contains(option);
                    return CheckboxListTile(
                      title: Text(option),
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setDialogState(() {
                          if (selected ?? false) {
                            tempSelected.add(option);
                          } else {
                            tempSelected.remove(option);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('İptal'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Tamam'),
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

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
      appBar: AppBar(
        title: const Text('Profil: Kariyer Vizyonu'),
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
                icon: Icons.looks_one_rounded,
                questionText: 'Yaklaşık 1 Yıllık Ana Hedefin',
                child: Column(
                  children: [
                    ..._oneYearThemeOptions
                        .map(
                          (themeOption) => RadioListTile<String>(
                            title: Text(
                              themeOption,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: themeOption,
                            groupValue: _selectedOneYearTheme,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedOneYearTheme = value;
                              });
                            },
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _oneYearDetailsController,
                      decoration: _inputDecoration(
                        context,
                        'Bu hedefle ilgili spesifik detaylar (isteğe bağlı)',
                        Icons.edit_note_rounded,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 2 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.looks_5_rounded,
                questionText: 'Yaklaşık 5 Yıllık Ana Vizyonun',
                child: Column(
                  children: [
                    ..._fiveYearThemeOptions
                        .map(
                          (themeOption) => RadioListTile<String>(
                            title: Text(
                              themeOption,
                              style: theme.textTheme.bodyLarge,
                            ),
                            value: themeOption,
                            groupValue: _selectedFiveYearTheme,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedFiveYearTheme = value;
                              });
                            },
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _fiveYearDetailsController,
                      decoration: _inputDecoration(
                        context,
                        'Bu vizyonla ilgili detaylar (isteğe bağlı)',
                        Icons.edit_note_rounded,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 3 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.terminal_rounded,
                questionText: 'Hedeflediğin Teknik Rol(ler)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _selectedTargetRoles.isEmpty
                        ? Text(
                          'Henüz rol seçilmedi.',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                        : Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children:
                              _selectedTargetRoles
                                  .map(
                                    (role) => Chip(
                                      label: Text(role),
                                      onDeleted:
                                          () => setState(
                                            () => _selectedTargetRoles.remove(
                                              role,
                                            ),
                                          ),
                                      deleteIconColor: colorScheme.error
                                          .withOpacity(0.7),
                                      backgroundColor: colorScheme
                                          .secondaryContainer
                                          .withOpacity(0.5),
                                      labelStyle: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 2.0,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      icon: const Icon(Icons.checklist_rtl_outlined, size: 18),
                      label: const Text('Rolleri Seç/Düzenle'),
                      onPressed:
                          () => _showMultiSelectDialog(
                            title: 'Hedef Rolleri Seçin',
                            allOptions: _allTargetRolesOptions,
                            currentlySelected: _selectedTargetRoles,
                            onConfirm: (selectedList) {
                              setState(() {
                                _selectedTargetRoles.clear();
                                _selectedTargetRoles.addAll(selectedList);
                              });
                            },
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 4 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.business_center_rounded,
                questionText: 'Hedeflediğin Sektör(ler)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _selectedTargetSectors.isEmpty
                        ? Text(
                          'Henüz sektör seçilmedi.',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                        : Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children:
                              _selectedTargetSectors
                                  .map(
                                    (sector) => Chip(
                                      label: Text(sector),
                                      onDeleted:
                                          () => setState(
                                            () => _selectedTargetSectors.remove(
                                              sector,
                                            ),
                                          ),
                                      deleteIconColor: colorScheme.error
                                          .withOpacity(0.7),
                                      backgroundColor: colorScheme
                                          .secondaryContainer
                                          .withOpacity(0.5),
                                      labelStyle: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 2.0,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      icon: const Icon(Icons.checklist_rtl_outlined, size: 18),
                      label: const Text('Sektörleri Seç/Düzenle'),
                      onPressed:
                          () => _showMultiSelectDialog(
                            title: 'Hedef Sektörleri Seçin',
                            allOptions: _allTargetSectorsOptions,
                            currentlySelected: _selectedTargetSectors,
                            onConfirm: (selectedList) {
                              setState(() {
                                _selectedTargetSectors.clear();
                                _selectedTargetSectors.addAll(selectedList);
                              });
                            },
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Soru 5 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.favorite_rounded,
                questionText: 'Ana Motivasyon Kaynakların',
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children:
                          _motivationSourcesOptions.keys
                              .where((k) => k != 'Diğer (Açıklayınız)')
                              .map((motivation) {
                                bool isSelected =
                                    _motivationSourcesOptions[motivation] ??
                                    false;
                                return FilterChip(
                                  label: Text(motivation),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _motivationSourcesOptions[motivation] =
                                          selected;
                                    });
                                  },
                                  selectedColor: colorScheme.primaryContainer
                                      .withOpacity(0.7),
                                  checkmarkColor: colorScheme.primary,
                                  labelStyle: TextStyle(
                                    fontSize: 13,
                                    color:
                                        isSelected ? colorScheme.primary : null,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? colorScheme.primary
                                            : Colors.grey[300]!,
                                    width: 0.8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                );
                              })
                              .toList(),
                    ),
                    CheckboxListTile(
                      title: const Text(
                        'Diğer (Açıklayınız)',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      value: _motivationSourcesOptions['Diğer (Açıklayınız)'],
                      onChanged: (bool? newValue) {
                        setState(() {
                          _motivationSourcesOptions['Diğer (Açıklayınız)'] =
                              newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: false,
                      contentPadding: EdgeInsets.zero,
                      activeColor: colorScheme.primary,
                    ),
                    if (_motivationSourcesOptions['Diğer (Açıklayınız)'] ==
                        true)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          controller: _otherMotivationController,
                          decoration: _inputDecoration(
                            context,
                            'Diğer Motivasyon Kaynağınızı Açıklayın',
                            Icons.edit_note_rounded,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (_motivationSourcesOptions['Diğer (Açıklayınız)'] ==
                                    true &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Lütfen diğer motivasyonunuzu açıklayın.';
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
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
            child,
          ],
        ),
      ),
    );
  }
  // ------------------------------------------

  // --- Düzeltilmiş InputDecoration için Yardımcı Fonksiyon ---
  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData? prefixIcon,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText:
          label.contains("Açıklayın") || label.contains("detaylar")
              ? 'Detayları buraya yazın...'
              : null,
      prefixIcon:
          prefixIcon != null
              ? Icon(
                prefixIcon,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              )
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
