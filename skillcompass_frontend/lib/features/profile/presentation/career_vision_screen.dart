import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/input_decoration_helper.dart';
import 'package:skillcompass_frontend/core/utils/feedback_helper.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/features/profile/services/profile_service.dart';
import 'widgets/career_vision_header.dart';
import 'widgets/career_vision_short_term_card.dart';
import 'widgets/career_vision_long_term_card.dart';
import 'widgets/career_vision_motivation_card.dart';
import 'widgets/career_vision_tagline_card.dart';

class CareerVisionScreen extends StatefulWidget {
  const CareerVisionScreen({super.key});

  @override
  State<CareerVisionScreen> createState() => _CareerVisionScreenState();
}

class _CareerVisionScreenState extends State<CareerVisionScreen> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';
  bool _isEditMode = false;
  late TabController _tabController;

  // --- State Değişkenleri ---
  String? _selectedOneYearGoal;
  String? _oneYearGoalDetail;
  String? _selectedFiveYearVision;
  String? _fiveYearVisionDetail;
  List<String> _selectedMotivationSources = [];
  String? _profileTagline;

  // --- Options ---
  final List<String> _oneYearGoalOptions = [
    'Yeni bir teknoloji öğrenmek',
    'İlk işimi/stajımı bulmak',
    'Bir projede liderlik yapmak',
    'Açık kaynak katkısı yapmak',
    'Kariyerimde terfi almak',
    'Kendi girişimimi başlatmak',
    'Diğer',
  ];
  final List<String> _fiveYearVisionOptions = [
    'Alanında uzmanlaşmak',
    'Uluslararası bir şirkette çalışmak',
    'Kendi şirketini kurmak',
    'Teknik lider olmak',
    'Global projelerde yer almak',
    'Akademik kariyer yapmak',
    'Diğer',
  ];
  final List<String> _motivationSourcesOptions = [
    'Öğrenme & Gelişim',
    'Problem Çözme',
    'Maddi Güvence',
    'Kariyerde Yükselme',
    'Etki Yaratma',
    'Esneklik',
    'Yaratıcılık',
    'Teknolojiye İlgi',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await _profileService.loadCareerVision();
      
      if (data != null) {
        setState(() {
          _selectedOneYearGoal = data['one_year_goal'];
          _oneYearGoalDetail = data['one_year_goal_detail'];
          _selectedFiveYearVision = data['five_year_vision'];
          _fiveYearVisionDetail = data['five_year_vision_detail'];
          _selectedMotivationSources = List<String>.from(data['motivation_sources'] ?? []);
          _profileTagline = data['profile_tagline'];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Profil verileri yüklenirken bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToFirestore() async {
    setState(() => _isSaving = true);
    try {
      final data = {
        'one_year_goal': _selectedOneYearGoal,
        'one_year_goal_detail': _oneYearGoalDetail,
        'five_year_vision': _selectedFiveYearVision,
        'five_year_vision_detail': _fiveYearVisionDetail,
        'motivation_sources': _selectedMotivationSources,
        'profile_tagline': _profileTagline,
      };
      
      await _profileService.saveCareerVision(data);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kariyer vizyonu başarıyla kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() => _isEditMode = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bilgiler kaydedilirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainBlue = theme.colorScheme.primary;
    final accentCoral = theme.colorScheme.secondary;
    final cloudGrey = theme.colorScheme.outline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kariyer Vizyonu'),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Düzenle',
              onPressed: () => setState(() => _isEditMode = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Kaydet',
              onPressed: _isSaving ? null : _saveToFirestore,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _error.isNotEmpty
              ? Center(child: ErrorMessage(message: _error))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: CareerVisionHeader(
                        mainBlue: mainBlue,
                        accentCoral: accentCoral,
                        onGuide: null, // İstenirse rehber fonksiyonu eklenebilir
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      elevation: 2,
                      color: theme.colorScheme.surface,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Kısa Vade'),
                          Tab(text: 'Uzun Vade'),
                          Tab(text: 'Motivasyon'),
                        ],
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.colorScheme.onSurface,
                        indicatorColor: theme.colorScheme.primary,
                        indicatorWeight: 3,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Kısa Vade Tab
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CareerVisionShortTermCard(
                                  goalOptions: _oneYearGoalOptions,
                                  selectedGoal: _selectedOneYearGoal,
                                  goalDetail: _oneYearGoalDetail,
                                  isEditMode: _isEditMode,
                                  onGoalChanged: (val) => setState(() => _selectedOneYearGoal = val),
                                  onDetailChanged: (val) => setState(() => _oneYearGoalDetail = val),
                                  mainBlue: mainBlue,
                                  accentCoral: accentCoral,
                                  cloudGrey: cloudGrey,
                                ),
                                const SizedBox(height: 16),
                                CareerVisionTaglineCard(
                                  tagline: _profileTagline,
                                  isEditMode: _isEditMode,
                                  onTaglineChanged: (val) => setState(() => _profileTagline = val),
                                  mainBlue: mainBlue,
                                  accentCoral: accentCoral,
                                  cloudGrey: cloudGrey,
                                ),
                              ],
                            ),
                          ),
                          // Uzun Vade Tab
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: CareerVisionLongTermCard(
                              visionOptions: _fiveYearVisionOptions,
                              selectedVision: _selectedFiveYearVision,
                              visionDetail: _fiveYearVisionDetail,
                              isEditMode: _isEditMode,
                              onVisionChanged: (val) => setState(() => _selectedFiveYearVision = val),
                              onDetailChanged: (val) => setState(() => _fiveYearVisionDetail = val),
                              mainBlue: mainBlue,
                              accentCoral: accentCoral,
                              cloudGrey: cloudGrey,
                            ),
                          ),
                          // Motivasyon Tab
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: CareerVisionMotivationCard(
                              motivationOptions: _motivationSourcesOptions,
                              selectedMotivations: _selectedMotivationSources,
                              isEditMode: _isEditMode,
                              onMotivationToggle: (val) {
                                setState(() {
                                  if (_selectedMotivationSources.contains(val)) {
                                    _selectedMotivationSources.remove(val);
                                  } else {
                                    _selectedMotivationSources.add(val);
                                  }
                                });
                              },
                              mainBlue: mainBlue,
                              accentCoral: accentCoral,
                              cloudGrey: cloudGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
