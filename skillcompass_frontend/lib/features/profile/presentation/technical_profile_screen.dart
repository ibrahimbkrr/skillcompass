import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // flutter pub add uuid
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/core/widgets/custom_button.dart';
import 'package:skillcompass_frontend/core/widgets/custom_snackbar.dart';

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

class _TechnicalProfileScreenState extends State<TechnicalProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // --- State Değişkenleri ---
  User? _currentUser;
  bool _isLoadingPage = true;
  bool _isEditing = false;
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

  late TabController _tabController;

  // Seçim değişkenleri
  List<String> _selectedProgrammingLanguages = [];
  List<String> _selectedFrameworks = [];
  List<String> _selectedDatabases = [];
  List<String> _selectedTools = [];
  List<String> _selectedCloudServices = [];
  List<String> _selectedDevOpsTools = [];
  List<String> _selectedSoftSkills = [];
  String? _selectedExperienceLevel;
  String? _selectedPreferredRole;

  // Seçenek listeleri
  final List<String> _programmingLanguages = [
    'Python',
    'JavaScript',
    'Java',
    'C#',
    'C++',
    'TypeScript',
    'Go',
    'Ruby',
    'PHP',
    'Swift',
    'Kotlin',
    'Rust',
    'Scala',
    'Dart',
    'Diğer',
  ];

  final List<String> _frameworks = [
    'React',
    'Angular',
    'Vue.js',
    'Django',
    'Flask',
    'Spring Boot',
    'Laravel',
    'Express.js',
    'Flutter',
    'React Native',
    '.NET',
    'Ruby on Rails',
    'FastAPI',
    'NestJS',
    'Diğer',
  ];

  final List<String> _databases = [
    'MySQL',
    'PostgreSQL',
    'MongoDB',
    'Redis',
    'SQLite',
    'Oracle',
    'SQL Server',
    'Cassandra',
    'Elasticsearch',
    'Neo4j',
    'Firebase',
    'DynamoDB',
    'Diğer',
  ];

  final List<String> _tools = [
    'Git',
    'Docker',
    'VS Code',
    'IntelliJ IDEA',
    'Postman',
    'Jira',
    'Confluence',
    'Figma',
    'Adobe XD',
    'Sketch',
    'Selenium',
    'Jenkins',
    'Diğer',
  ];

  final List<String> _cloudServices = [
    'AWS',
    'Azure',
    'Google Cloud',
    'Digital Ocean',
    'Heroku',
    'Firebase',
    'Vercel',
    'Netlify',
    'Cloudflare',
    'Diğer',
  ];

  final List<String> _devOpsTools = [
    'Docker',
    'Kubernetes',
    'Terraform',
    'Ansible',
    'Prometheus',
    'Grafana',
    'ELK Stack',
    'GitLab CI',
    'GitHub Actions',
    'Jenkins',
    'ArgoCD',
    'Diğer',
  ];

  final List<String> _softSkills = [
    'Takım Çalışması',
    'Problem Çözme',
    'İletişim',
    'Zaman Yönetimi',
    'Liderlik',
    'Adaptasyon',
    'Analitik Düşünme',
    'Yaratıcılık',
    'Stres Yönetimi',
    'Mentorluk',
    'Sunum Becerileri',
    'Müzakere',
    'Diğer',
  ];

  final List<String> _experienceLevels = [
    'Yeni Başlayan (0-1 yıl)',
    'Junior (1-3 yıl)',
    'Mid-Level (3-5 yıl)',
    'Senior (5-8 yıl)',
    'Lead (8+ yıl)',
  ];

  final List<String> _preferredRoles = [
    'Frontend Geliştirici',
    'Backend Geliştirici',
    'Full Stack Geliştirici',
    'DevOps Mühendisi',
    'Mobil Geliştirici',
    'UI/UX Tasarımcı',
    'Veri Bilimci',
    'Siber Güvenlik Uzmanı',
    'Sistem Yöneticisi',
    'Proje Yöneticisi',
    'Diğer',
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _otherSkillsNotesController.dispose();
    _struggleDetailsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    if (_currentUser == null) return;
    setState(() {
      _isLoadingPage = true;
      _loadingError = '';
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('profile_data')
          .doc('technical_profile_v4')
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          _selectedProgrammingLanguages = List<String>.from(data['programming_languages'] ?? []);
          _selectedFrameworks = List<String>.from(data['frameworks'] ?? []);
          _selectedDatabases = List<String>.from(data['databases'] ?? []);
          _selectedTools = List<String>.from(data['tools'] ?? []);
          _selectedCloudServices = List<String>.from(data['cloud_services'] ?? []);
          _selectedDevOpsTools = List<String>.from(data['devops_tools'] ?? []);
          _selectedSoftSkills = List<String>.from(data['soft_skills'] ?? []);
          _selectedExperienceLevel = data['experience_level'];
          _selectedPreferredRole = data['preferred_role'];
        });
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

    setState(() {
      _isSaving = true;
    });

    try {
      Map<String, dynamic> technicalData = {
        'programming_languages': _selectedProgrammingLanguages,
        'frameworks': _selectedFrameworks,
        'databases': _selectedDatabases,
        'tools': _selectedTools,
        'cloud_services': _selectedCloudServices,
        'devops_tools': _selectedDevOpsTools,
        'soft_skills': _selectedSoftSkills,
        'experience_level': _selectedExperienceLevel,
        'preferred_role': _selectedPreferredRole,
        'lastUpdated': Timestamp.now(),
      };

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile_data')
          .doc('technical_profile_v4')
          .set(technicalData);

      if (mounted) {
        _showFeedback(
          'Teknik profil bilgileri başarıyla kaydedildi!',
          isError: false,
        );
        setState(() {
          _isEditing = false;
        });
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
        title: const Text('Profil: Teknik Yetenekler'),
        elevation: 1,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Düzenle',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Teknik Beceriler'),
            Tab(text: 'Araçlar & Platformlar'),
            Tab(text: 'Deneyim & Yetkinlikler'),
          ],
        ),
      ),
      bottomNavigationBar: _isEditing
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _isSaving ? Container() : const Icon(Icons.save_rounded),
                      label: _isSaving
                          ? const SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Kaydet'),
                      onPressed: _isSaving ? null : _saveToFirestore,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel_rounded),
                      label: const Text('İptal'),
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _loadSavedData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
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
                ],
              ),
            )
          : null,
      body: _isLoadingPage
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTechnicalSkillsTab(theme),
                _buildToolsTab(theme),
                _buildExperienceTab(theme),
              ],
            ),
    );
  }

  Widget _buildTechnicalSkillsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(theme),
            const SizedBox(height: 24),
            _buildCategorySection(
              theme,
              'Programlama Dilleri',
              _buildMultiSelector(
                theme,
                _programmingLanguages,
                _selectedProgrammingLanguages,
                (value) {
                  setState(() {
                    if (_selectedProgrammingLanguages.contains(value)) {
                      _selectedProgrammingLanguages.remove(value);
                    } else {
                      _selectedProgrammingLanguages.add(value);
                    }
                  });
                },
                'Programlama Dili',
              ),
            ),
            const SizedBox(height: 24),
            _buildCategorySection(
              theme,
              'Framework\'ler',
              _buildMultiSelector(
                theme,
                _frameworks,
                _selectedFrameworks,
                (value) {
                  setState(() {
                    if (_selectedFrameworks.contains(value)) {
                      _selectedFrameworks.remove(value);
                    } else {
                      _selectedFrameworks.add(value);
                    }
                  });
                },
                'Framework',
              ),
            ),
            const SizedBox(height: 24),
            _buildCategorySection(
              theme,
              'Veritabanları',
              _buildMultiSelector(
                theme,
                _databases,
                _selectedDatabases,
                (value) {
                  setState(() {
                    if (_selectedDatabases.contains(value)) {
                      _selectedDatabases.remove(value);
                    } else {
                      _selectedDatabases.add(value);
                    }
                  });
                },
                'Veritabanı',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _getSectionIcon(title),
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: content,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection(
            theme,
            'Geliştirme Araçları',
            _buildMultiSelector(
              theme,
              _tools,
              _selectedTools,
              (value) {
                setState(() {
                  if (_selectedTools.contains(value)) {
                    _selectedTools.remove(value);
                  } else {
                    _selectedTools.add(value);
                  }
                });
              },
              'Araç',
            ),
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            theme,
            'Bulut Servisleri',
            _buildMultiSelector(
              theme,
              _cloudServices,
              _selectedCloudServices,
              (value) {
                setState(() {
                  if (_selectedCloudServices.contains(value)) {
                    _selectedCloudServices.remove(value);
                  } else {
                    _selectedCloudServices.add(value);
                  }
                });
              },
              'Bulut Servisi',
            ),
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            theme,
            'DevOps Araçları',
            _buildMultiSelector(
              theme,
              _devOpsTools,
              _selectedDevOpsTools,
              (value) {
                setState(() {
                  if (_selectedDevOpsTools.contains(value)) {
                    _selectedDevOpsTools.remove(value);
                  } else {
                    _selectedDevOpsTools.add(value);
                  }
                });
              },
              'DevOps Aracı',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection(
            theme,
            'Deneyim Seviyesi',
            _buildStatusSelector(
              theme,
              _experienceLevels,
              _selectedExperienceLevel,
              (value) => setState(() => _selectedExperienceLevel = value),
            ),
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            theme,
            'Tercih Ettiğiniz Rol',
            _buildStatusSelector(
              theme,
              _preferredRoles,
              _selectedPreferredRole,
              (value) => setState(() => _selectedPreferredRole = value),
            ),
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            theme,
            'Yumuşak Beceriler',
            _buildMultiSelector(
              theme,
              _softSkills,
              _selectedSoftSkills,
              (value) {
                setState(() {
                  if (_selectedSoftSkills.contains(value)) {
                    _selectedSoftSkills.remove(value);
                  } else {
                    _selectedSoftSkills.add(value);
                  }
                });
              },
              'Yumuşak Beceri',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.code,
                    color: theme.colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teknik Becerileriniz',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Teknik yetkinliklerinizi belirterek size özel öneriler alın',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Programlama Dilleri':
        return Icons.code;
      case 'Framework\'ler':
        return Icons.architecture;
      case 'Veritabanları':
        return Icons.storage;
      case 'Geliştirme Araçları':
        return Icons.build;
      case 'Bulut Servisleri':
        return Icons.cloud;
      case 'DevOps Araçları':
        return Icons.settings;
      case 'Deneyim Seviyesi':
        return Icons.trending_up;
      case 'Tercih Ettiğiniz Rol':
        return Icons.work;
      case 'Yumuşak Beceriler':
        return Icons.people;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildStatusSelector(
    ThemeData theme,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Column(
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: RadioListTile<String>(
            title: Text(
              option,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            value: option,
            groupValue: selectedValue,
            onChanged: _isEditing ? onChanged : null,
            activeColor: theme.colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelector(
    ThemeData theme,
    List<String> options,
    List<String> selectedValues,
    Function(String) onChanged,
    String category,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return FilterChip(
          label: Text(
            option,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          selected: isSelected,
          onSelected: _isEditing
              ? (selected) {
                  if (option == 'Diğer') {
                    _showAddCustomOptionDialog(category);
                  } else {
                    onChanged(option);
                  }
                }
              : null,
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withOpacity(0.15),
          checkmarkColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          elevation: isSelected ? 2 : 0,
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              onPressed: _saveToFirestore,
              text: 'Kaydet',
              isLoading: _isSaving,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              onPressed: () {
                setState(() => _isSaving = false);
                _loadSavedData();
              },
              text: 'İptal',
              isLoading: false,
              backgroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCustomOptionDialog(String category) async {
    final TextEditingController customOptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$category Ekle'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: customOptionController,
            decoration: _inputDecoration(
              context,
              'Yeni $category',
              Icons.add_circle_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Lütfen bir değer girin';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newOption = customOptionController.text.trim();
                setState(() {
                  switch (category) {
                    case 'Programlama Dili':
                      _selectedProgrammingLanguages.add(newOption);
                      break;
                    case 'Framework':
                      _selectedFrameworks.add(newOption);
                      break;
                    case 'Veritabanı':
                      _selectedDatabases.add(newOption);
                      break;
                    case 'Araç':
                      _selectedTools.add(newOption);
                      break;
                    case 'Bulut Servisi':
                      _selectedCloudServices.add(newOption);
                      break;
                    case 'DevOps Aracı':
                      _selectedDevOpsTools.add(newOption);
                      break;
                    case 'Yumuşak Beceri':
                      _selectedSoftSkills.add(newOption);
                      break;
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  // --- InputDecoration için Yardımcı Fonksiyon ---
  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData? prefixIcon,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: label.contains("Açıklayın") ||
              label.contains("örnekleri") ||
              label.contains("Link") ||
              label.contains("Notlar")
          ? 'Detayları buraya yazın...'
          : null,
      prefixIcon: prefixIcon != null
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
}
