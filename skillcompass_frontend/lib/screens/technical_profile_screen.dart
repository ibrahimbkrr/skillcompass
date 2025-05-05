import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // flutter pub add uuid

// --- Veri Modelleri ---
class SkillEntry {
  String name;
  String level; // Beginner, Intermediate, Advanced

  SkillEntry({required this.name, required this.level});

  Map<String, dynamic> toMap() => {'skill': name, 'level': level};

  factory SkillEntry.fromMap(Map<String, dynamic> map) {
    return SkillEntry(
      name: map['skill'] ?? '',
      level: map['level'] ?? 'Beginner',
    );
  }
}

class ProjectEntry {
  String id;
  String name;
  String description;
  List<String> technologies;
  String? link;

  ProjectEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.technologies,
    this.link,
  });

  factory ProjectEntry.fromMap(Map<String, dynamic> map) {
    return ProjectEntry(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      technologies: List<String>.from(map['technologies'] ?? []),
      link: map['link'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'technologies': technologies,
      'link': link,
    };
  }
}
// -------------------------

class TechnicalProfileScreen extends StatefulWidget {
  const TechnicalProfileScreen({super.key});

  @override
  State<TechnicalProfileScreen> createState() => _TechnicalProfileScreenState();
}

class _TechnicalProfileScreenState extends State<TechnicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // --- State Değişkenleri ---
  User? _currentUser;
  bool _isLoadingPage = true;
  bool _isSaving = false;
  String _loadingError = '';

  // Form Alanları
  final List<SkillEntry> _userSkills = [];
  final List<String> _levelOptions = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _commonTechSkills = [
    'Python',
    'Java',
    'JavaScript',
    'TypeScript',
    'C#',
    'C++',
    'PHP',
    'Go',
    'Ruby',
    'Swift',
    'Kotlin',
    'HTML',
    'CSS',
    'Sass/Less',
    'React',
    'Angular',
    'Vue.js',
    'Svelte',
    'jQuery',
    'Node.js',
    'Express.js',
    'Django',
    'Flask',
    'Ruby on Rails',
    'Spring Boot',
    'ASP.NET Core',
    'Laravel',
    'Flutter',
    'React Native',
    'Xamarin',
    'Android (Native)',
    'iOS (Native)',
    'SQL',
    'PostgreSQL',
    'MySQL',
    'SQLite',
    'Microsoft SQL Server',
    'Oracle DB',
    'MongoDB',
    'Redis',
    'Cassandra',
    'Firebase Firestore',
    'AWS',
    'Azure',
    'Google Cloud Platform (GCP)',
    'Heroku',
    'DigitalOcean',
    'Docker',
    'Kubernetes',
    'Terraform',
    'Ansible',
    'Git',
    'Jenkins',
    'GitHub Actions',
    'GitLab CI',
    'Linux',
    'Windows Server',
    'Bash/Shell Scripting',
    'Unit Testing',
    'Integration Testing',
    'E2E Testing',
    'Jest',
    'Pytest',
    'JUnit',
    'REST API',
    'GraphQL',
    'gRPC',
    'TensorFlow',
    'PyTorch',
    'Scikit-learn',
    'Pandas',
    'NumPy',
    'Unity',
    'Unreal Engine',
    'Wireshark',
    'Nmap',
    'Metasploit',
    'Figma',
    'Adobe XD',
    'Sketch',
  ];
  final TextEditingController _otherSkillsNotesController =
      TextEditingController();
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
  final List<ProjectEntry> _userProjects = [];
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
  String? _selectedProductionExperience;
  final List<String> _productionExperienceOptions = [
    'Evet, yer aldım.',
    'Hayır, henüz yer almadım.',
    'Denemeyi / Yer almayı düşünüyorum.',
  ];

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
              .doc('technical_profile_v4') // Versiyon 4
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (mounted) {
          _updateStateWithLoadedData(data);
        }
      }
    } catch (e) {
      print("HATA: technical_profile_v4 verisi yüklenemedi: $e");
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
      List<dynamic> skillsRaw = data['userSkills'] ?? [];
      _userSkills.clear();
      for (var item in skillsRaw) {
        if (item is Map<String, dynamic>) {
          try {
            _userSkills.add(SkillEntry.fromMap(item));
          } catch (e) {
            print("Beceri verisi okuma hatası: $e");
          }
        }
      }
      _otherSkillsNotesController.text = data['otherSkillsNotes'] ?? '';
      List<String> savedAreas = List<String>.from(
        data['experiencedAreas'] ?? [],
      );
      _experiencedAreasOptions.forEach((key, value) {
        _experiencedAreasOptions[key] = savedAreas.contains(key);
      });
      List<dynamic> projectsRaw = data['userProjects'] ?? [];
      _userProjects.clear();
      for (var item in projectsRaw) {
        if (item is Map<String, dynamic>) {
          try {
            _userProjects.add(ProjectEntry.fromMap(item));
          } catch (e) {
            print("Proje verisi okuma hatası: $e");
          }
        }
      }
      List<String> savedStruggles = List<String>.from(
        data['struggledAreas'] ?? [],
      );
      _struggledAreasOptions.forEach((key, value) {
        _struggledAreasOptions[key] = savedStruggles.contains(key);
      });
      _struggleDetailsController.text = data['struggleDetails'] ?? '';
      _selectedProductionExperience = data['productionExperience'];
      if (!_productionExperienceOptions.contains(_selectedProductionExperience))
        _selectedProductionExperience = null;
    });
  }

  @override
  void dispose() {
    _otherSkillsNotesController.dispose();
    _struggleDetailsController.dispose();
    super.dispose();
  }

  Future<void> _showSelectAddSkillDialog() async {
    List<SkillEntry> tempSelectedSkills = List.from(_userSkills);
    String newSkillName = '';
    String newSkillLevel = _levelOptions[0];

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Teknik Becerilerinizi Seçin/Ekleyin'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Yaygın Teknolojiler:",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            _commonTechSkills.map((skill) {
                              bool isSelected = tempSelectedSkills.any(
                                (s) => s.name == skill,
                              );
                              return FilterChip(
                                label: Text(skill),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setDialogState(() {
                                    if (selected) {
                                      if (!isSelected) {
                                        tempSelectedSkills.add(
                                          SkillEntry(
                                            name: skill,
                                            level: _levelOptions[0],
                                          ),
                                        );
                                      }
                                    } else {
                                      tempSelectedSkills.removeWhere(
                                        (s) => s.name == skill,
                                      );
                                    }
                                  });
                                },
                                selectedColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.7),
                                checkmarkColor:
                                    Theme.of(context).colorScheme.primary,
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : null,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.grey[300]!,
                                  width: 0.8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              );
                            }).toList(),
                      ),
                      const Divider(height: 30),
                      Text(
                        "Listede Olmayan Beceri Ekle:",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: _inputDecoration(
                                context,
                                'Beceri Adı',
                                null,
                              ),
                              onChanged: (value) => newSkillName = value.trim(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: newSkillLevel,
                            items:
                                _levelOptions
                                    .map(
                                      (l) => DropdownMenuItem(
                                        value: l,
                                        child: Text(l),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) => setDialogState(
                                  () =>
                                      newSkillLevel = value ?? _levelOptions[0],
                                ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.green,
                            ),
                            tooltip: 'Ekle',
                            onPressed: () {
                              if (newSkillName.isNotEmpty) {
                                bool exists = tempSelectedSkills.any(
                                  (s) =>
                                      s.name.toLowerCase() ==
                                      newSkillName.toLowerCase(),
                                );
                                if (!exists) {
                                  setDialogState(() {
                                    tempSelectedSkills.add(
                                      SkillEntry(
                                        name: newSkillName,
                                        level: newSkillLevel,
                                      ),
                                    );
                                    newSkillName = '';
                                  });
                                } else {
                                  _showFeedback(
                                    'Bu beceri zaten listede var.',
                                    isError: true,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            tempSelectedSkills
                                .where(
                                  (s) => !_commonTechSkills.contains(s.name),
                                )
                                .map((skill) {
                                  return Chip(
                                    label: Text(skill.name),
                                    onDeleted:
                                        () => setDialogState(
                                          () =>
                                              tempSelectedSkills.remove(skill),
                                        ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('İptal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Tamam'),
                  onPressed: () {
                    setState(() {
                      _userSkills.clear();
                      _userSkills.addAll(tempSelectedSkills);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateSkillLevel(SkillEntry skill, String newLevel) {
    setState(() {
      skill.level = newLevel;
    });
  }

  Future<void> _showAddEditProjectDialog({
    ProjectEntry? existingProject,
  }) async {
    final _projectFormKey = GlobalKey<FormState>();
    final _projectNameController = TextEditingController(
      text: existingProject?.name,
    );
    final _projectDescController = TextEditingController(
      text: existingProject?.description,
    );
    final _projectLinkController = TextEditingController(
      text: existingProject?.link,
    );
    List<String> _selectedTechsDialog = List<String>.from(
      existingProject?.technologies ?? [],
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingProject == null ? 'Yeni Proje Ekle' : 'Projeyi Düzenle',
              ),
              content: Form(
                key: _projectFormKey,
                child: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      TextFormField(
                        controller: _projectNameController,
                        decoration: _inputDecoration(
                          context,
                          'Proje Adı',
                          Icons.title_rounded,
                        ),
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Proje adı boş olamaz'
                                    : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _projectDescController,
                        decoration: _inputDecoration(
                          context,
                          'Kısa Açıklama',
                          Icons.description_outlined,
                        ),
                        maxLines: 3,
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Açıklama boş olamaz'
                                    : null,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Kullanılan Teknolojiler (Eklediğiniz Becerilerden Seçin):",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      _userSkills.isEmpty
                          ? const Text(
                            "Önce beceri eklemelisiniz.",
                            style: TextStyle(color: Colors.grey),
                          )
                          : Wrap(
                            spacing: 6.0,
                            runSpacing: 0.0,
                            children:
                                _userSkills.map((skill) {
                                  final skillName = skill.name;
                                  final isSelected = _selectedTechsDialog
                                      .contains(skillName);
                                  return FilterChip(
                                    label: Text(skillName),
                                    selected: isSelected,
                                    onSelected: (bool selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          _selectedTechsDialog.add(skillName);
                                        } else {
                                          _selectedTechsDialog.remove(
                                            skillName,
                                          );
                                        }
                                      });
                                    },
                                    selectedColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withOpacity(0.7),
                                    checkmarkColor:
                                        Theme.of(context).colorScheme.primary,
                                    labelStyle: TextStyle(
                                      fontSize: 13,
                                      color:
                                          isSelected
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                              : null,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                              : Colors.grey[300]!,
                                      width: 0.8,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  );
                                }).toList(),
                          ),
                      FormField<List<String>>(
                        initialValue: _selectedTechsDialog,
                        validator:
                            (value) =>
                                (_userSkills.isNotEmpty &&
                                        _selectedTechsDialog.isEmpty)
                                    ? 'En az bir teknoloji seçin'
                                    : null,
                        builder:
                            (state) =>
                                state.hasError
                                    ? Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        state.errorText!,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                    : Container(),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _projectLinkController,
                        decoration: _inputDecoration(
                          context,
                          'Proje Linki (GitHub, Demo vb. - İsteğe bağlı)',
                          Icons.link_rounded,
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('İptal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(existingProject == null ? 'Ekle' : 'Güncelle'),
                  onPressed: () {
                    if (_projectFormKey.currentState!.validate()) {
                      final newProject = ProjectEntry(
                        id: existingProject?.id ?? _uuid.v4(),
                        name: _projectNameController.text.trim(),
                        description: _projectDescController.text.trim(),
                        technologies: _selectedTechsDialog,
                        link:
                            _projectLinkController.text.trim().isNotEmpty
                                ? _projectLinkController.text.trim()
                                : null,
                      );
                      setState(() {
                        if (existingProject != null) {
                          int index = _userProjects.indexWhere(
                            (p) => p.id == existingProject.id,
                          );
                          if (index != -1) _userProjects[index] = newProject;
                        } else {
                          _userProjects.add(newProject);
                        }
                      });
                      Navigator.of(context).pop();
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

  Future<void> _saveToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showFeedback('Oturum bulunamadı.', isError: true);
      return;
    }
    List<String> experiencedAreas =
        _experiencedAreasOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<String> struggledAreas =
        _struggledAreasOptions.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    List<Map<String, dynamic>> skillsToSave =
        _userSkills.map((s) => s.toMap()).toList();
    List<Map<String, dynamic>> projectsToSave =
        _userProjects.map((p) => p.toMap()).toList();
    Map<String, dynamic> technicalData = {
      'userSkills': skillsToSave,
      'otherSkillsNotes': _otherSkillsNotesController.text.trim(),
      'experiencedAreas': experiencedAreas,
      'userProjects': projectsToSave,
      'struggledAreas': struggledAreas,
      'struggleDetails':
          _struggledAreasOptions.containsValue(true)
              ? _struggleDetailsController.text.trim()
              : null,
      'productionExperience': _selectedProductionExperience,
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
          .doc('technical_profile_v4')
          .set(technicalData, SetOptions(merge: true));
      if (mounted) {
        _showFeedback(
          'Teknik profil bilgileri başarıyla kaydedildi!',
          isError: false,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      print("Firestore Kayıt Hatası (Teknik Profil v4): $e");
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
    if (_selectedProductionExperience == null) {
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
        title: const Text('Profil: Teknik Yetenekler'),
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
                icon: Icons.code_rounded,
                questionText: 'Teknik Becerilerin',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Bildiğiniz teknolojileri seçin veya ekleyin.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                          ),
                          label: const Text('Seç/Ekle'),
                          onPressed: _showSelectAddSkillDialog,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _userSkills.isEmpty
                        ? Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Center(
                            child: Text(
                              'Henüz beceri eklemediniz.\n"Seç/Ekle" butonunu kullanın.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                        : Column(
                          children:
                              _userSkills.map((skill) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          skill.name,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      SegmentedButton<String>(
                                        segments:
                                            _levelOptions.map((level) {
                                              return ButtonSegment<String>(
                                                value: level,
                                                label: Text(
                                                  level.substring(0, 3),
                                                ),
                                              );
                                            }).toList(),
                                        selected: {skill.level},
                                        onSelectionChanged: (
                                          Set<String> newSelection,
                                        ) {
                                          _updateSkillLevel(
                                            skill,
                                            newSelection.first,
                                          );
                                        },
                                        style: SegmentedButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          selectedBackgroundColor:
                                              _getLevelColor(
                                                skill.level,
                                                colorScheme,
                                              ).withOpacity(0.8),
                                          selectedForegroundColor: Colors.white,
                                        ),
                                        showSelectedIcon: false,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: colorScheme.error,
                                          size: 20,
                                        ),
                                        onPressed:
                                            () => setState(
                                              () => _userSkills.remove(skill),
                                            ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Sil',
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _otherSkillsNotesController,
                      decoration: _inputDecoration(
                        context,
                        'Ek Notlar / Diğer Beceriler (isteğe bağlı)',
                        Icons.notes_rounded,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              // --- Soru 2 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.explore_rounded,
                questionText: 'Deneyimlediğin Alanlar',
                child: Column(
                  children:
                      _experiencedAreasOptions.keys
                          .map(
                            (area) => CheckboxListTile(
                              title: Text(
                                area,
                                style: theme.textTheme.bodyLarge,
                              ),
                              value: _experiencedAreasOptions[area],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _experiencedAreasOptions[area] = newValue!;
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
              // --- Soru 3 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.integration_instructions_rounded,
                questionText: 'Projelerin',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tamamladığınız veya üzerinde çalıştığınız projeleri ekleyin.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 15),
                    _userProjects.isEmpty
                        ? Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Center(
                            child: Text(
                              'Henüz proje eklemediniz.\n"Yeni Proje Ekle" butonunu kullanın.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _userProjects.length,
                          itemBuilder:
                              (context, index) => _buildProjectItem(
                                context,
                                index,
                                colorScheme,
                              ),
                        ),
                    const SizedBox(height: 15),
                    Center(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 20,
                        ),
                        label: const Text('Yeni Proje Ekle'),
                        onPressed: () => _showAddEditProjectDialog(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              // --- Soru 4 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.warning_amber_rounded,
                questionText: 'Teknik Zorluk Alanların',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proje yaparken en çok hangi konularda zorlandınız?',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._struggledAreasOptions.keys
                        .map(
                          (area) => CheckboxListTile(
                            title: Text(area, style: theme.textTheme.bodyLarge),
                            value: _struggledAreasOptions[area],
                            onChanged: (bool? newValue) {
                              setState(() {
                                _struggledAreasOptions[area] = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            activeColor: colorScheme.primary,
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _struggleDetailsController,
                      decoration: _inputDecoration(
                        context,
                        'Zorlandığınız durumları açıklayın (isteğe bağlı)',
                        Icons.edit_note_rounded,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              // --- Soru 5 ---
              _buildQuestionCard(
                context: context,
                icon: Icons.rocket_launch_rounded,
                questionText: 'Üretim Ortamı Deneyimi',
                child: DropdownButtonFormField<String>(
                  value: _selectedProductionExperience,
                  hint: const Text('Açık kaynak, freelance vb. deneyiminiz?'),
                  isExpanded: true,
                  decoration: _inputDecoration(
                    context,
                    'Deneyim Durumu',
                    Icons.group_work_rounded,
                  ),
                  items:
                      _productionExperienceOptions
                          .map(
                            (String option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedProductionExperience = newValue;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Lütfen durumunuzu seçin.' : null,
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  // --- Yardımcı Kart Widget'ı ---
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

  // --- InputDecoration için Yardımcı Fonksiyon ---
  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData? prefixIcon,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText:
          label.contains("Açıklayın") ||
                  label.contains("örnekleri") ||
                  label.contains("Link") ||
                  label.contains("Notlar")
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

  // --- Beceri Seviyesine Göre Renk ---
  Color _getLevelColor(String level, ColorScheme colorScheme) {
    switch (level) {
      case 'Beginner':
        return Colors.orange.shade300;
      case 'Intermediate':
        return Colors.blue.shade300;
      case 'Advanced':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
  // -------------------------------------------------

  // --- Proje Öğesini Oluşturan Yardımcı Widget ---
  Widget _buildProjectItem(
    BuildContext context,
    int index,
    ColorScheme colorScheme,
  ) {
    final project = _userProjects[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      tooltip: 'Düzenle',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed:
                          () => _showAddEditProjectDialog(
                            existingProject: project,
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: colorScheme.error,
                      ),
                      tooltip: 'Sil',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () {
                        setState(() => _userProjects.removeAt(index));
                        _showFeedback('Proje silindi.', isError: false);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (project.technologies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children:
                    project.technologies
                        .map(
                          (tech) => Chip(
                            label: Text(tech),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSecondaryContainer,
                            ),
                            backgroundColor: colorScheme.secondaryContainer
                                .withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
              ),
            ],
            if (project.link != null && project.link!.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  /* TODO: Linki aç */
                  print("Linke tıklandı: ${project.link}");
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        project.link!,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
}
