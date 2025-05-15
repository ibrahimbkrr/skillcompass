import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'project_experience_header.dart';
import 'project_experience_past_projects.dart';
import 'project_experience_technologies.dart';
import 'project_experience_future_goal.dart';
import 'project_experience_challenges.dart';
import 'project_experience_progress_actions.dart';

class ProjectExperienceCard extends StatefulWidget {
  const ProjectExperienceCard({super.key});

  @override
  State<ProjectExperienceCard> createState() => _ProjectExperienceCardState();
}

class _ProjectExperienceCardState extends State<ProjectExperienceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _showGuide = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // State for all questions
  String _pastProjects = '';
  String _futureGoal = '';
  String _challenges = '';
  List<String> _technologies = [];
  String _customTech = '';
  late TextEditingController _customTechController;

  // Inspiration indexes
  int _pastInspireIdx = 0;
  int _futureInspireIdx = 0;
  int _challengesInspireIdx = 0;
  bool _showPastInspire = false;
  bool _showFutureInspire = false;
  bool _showChallengesInspire = false;

  // Inspiration lists
  final List<String> _pastInspireList = [
    'Bir makine öğrenimi modelini Python ile geliştirdim.',
    'Bir mobil uygulama yayınladım.',
    'Bir web platformunda React ile çalıştım.',
    'Açık kaynak bir projeye katkı sağladım.',
  ];
  final List<String> _futureInspireList = [
    'Bir mobil oyun geliştirmek ve yayınlamak.',
    'Bir web projesi başlatmak.',
    'Bir IoT cihazı için yazılım geliştirmek.',
    'Veri analizi projesi tamamlamak.',
  ];
  final List<String> _challengesInspireList = [
    'Zaman yönetimi.',
    'Kaynak eksikliği.',
    'Teknik karmaşıklık.',
    'Ekip çalışması.',
  ];

  // Technology options
  final List<String> _techOptions = [
    'Flutter/Dart',
    'Python',
    'JavaScript/React',
    'Java',
    'SQL/NoSQL',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
    _customTechController = TextEditingController();
    _fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _customTechController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Oturum bulunamadı');
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_profile')
          .doc('project_experience')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _pastProjects = data['past_projects'] ?? '';
          _technologies = List<String>.from(data['technologies'] ?? []);
          _futureGoal = data['future_project'] ?? '';
          _challenges = data['challenges'] ?? '';
        });
      }
    } catch (e) {
      setState(() { _error = 'Veri yüklenemedi: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _saveData() async {
    setState(() { _isSaving = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Oturum bulunamadı');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_profile')
          .doc('project_experience')
          .set({
        'past_projects': _pastProjects,
        'technologies': _technologies,
        'future_project': _futureGoal,
        'challenges': _challenges,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Proje deneyimi kaydedildi!', style: GoogleFonts.inter()), backgroundColor: Colors.green),
        );
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydedilemedi: $e', style: GoogleFonts.inter()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _isSaving = false; });
    }
  }

  // Completion logic
  bool get _pastCompleted => _pastProjects.trim().length >= 10;
  bool get _techCompleted => _technologies.isNotEmpty;
  bool get _futureCompleted => _futureGoal.trim().length >= 10;
  bool get _challengesCompleted => _challenges.trim().length >= 10;
  int get _completedCount => [_pastCompleted, _techCompleted, _futureCompleted, _challengesCompleted].where((b) => b).length;
  bool get _canSave => _pastCompleted && _techCompleted && _futureCompleted && _challengesCompleted;

  // Inspiration popup logic
  void _togglePastInspire() => setState(() {
    _showPastInspire = !_showPastInspire;
    if (_showPastInspire) {
      _pastInspireIdx = (_pastInspireIdx + 1) % _pastInspireList.length;
    }
  });
  void _toggleFutureInspire() => setState(() {
    _showFutureInspire = !_showFutureInspire;
    if (_showFutureInspire) {
      _futureInspireIdx = (_futureInspireIdx + 1) % _futureInspireList.length;
    }
  });
  void _toggleChallengesInspire() => setState(() {
    _showChallengesInspire = !_showChallengesInspire;
    if (_showChallengesInspire) {
      _challengesInspireIdx = (_challengesInspireIdx + 1) % _challengesInspireList.length;
    }
  });

  // Technology chip tap
  void _onTechChipTap(String tech) {
    setState(() {
      if (_technologies.contains(tech)) {
        _technologies.remove(tech);
        if (tech == 'Diğer') {
          _customTech = '';
          _customTechController.clear();
        }
      } else if (_technologies.length < 3) {
        _technologies.add(tech);
        if (tech == 'Diğer') {
          _customTech = '';
          _customTechController.clear();
        }
      }
    });
  }

  // Add custom technology
  void _addCustomTech() {
    if (_customTech.trim().isNotEmpty && !_technologies.contains(_customTech.trim()) && _technologies.length < 3) {
      setState(() {
        _technologies.add(_customTech.trim());
        _customTech = '';
        _customTechController.clear();
      });
    }
  }

  // 1. Rehber için showDialog
  void _showGuideDialog() {
    final theme = Theme.of(context);
    final mainBlue = theme.colorScheme.primary;
    final cloudGrey = theme.colorScheme.outline;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Proje Deneyimi Rehberi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: mainBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu sayfada, geçmişte yer aldığınız projeleri, kullandığınız teknolojileri ve gelecek hedeflerinizi paylaşabilirsiniz.',
              style: GoogleFonts.inter(fontSize: 16, color: cloudGrey),
            ),
            const SizedBox(height: 12),
            Text(
              'Tüm alanları doldurarak teknik profilinizi güçlendirin. İlham butonlarına tıklayarak örneklerden faydalanabilirsiniz.',
              style: GoogleFonts.inter(fontSize: 14, color: mainBlue),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Kapat', style: GoogleFonts.inter(color: mainBlue))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainBlue = theme.colorScheme.primary;
    final gold = theme.colorScheme.secondary;
    final coral = Colors.deepOrangeAccent;
    final cloudGrey = theme.colorScheme.outline;
    final lightBlue = Colors.lightBlue.shade300;
    final successGreen = Colors.green;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFE8ECF3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: GoogleFonts.inter(color: Colors.red)))
                        : Stack(
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: ProjectExperienceHeader(
                                        mainBlue: mainBlue,
                                        gold: gold,
                                        cloudGrey: cloudGrey,
                                        onGuide: _showGuideDialog,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Soru 1
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: ProjectExperiencePastProjects(
                                        value: _pastProjects,
                                        onChanged: (v) => setState(() => _pastProjects = v),
                                        onInspireTap: _togglePastInspire,
                                        showInspirePopup: _showPastInspire,
                                        inspireText: _pastInspireList[_pastInspireIdx],
                                        completed: _pastCompleted,
                                        mainBlue: mainBlue,
                                        gold: gold,
                                        cloudGrey: cloudGrey,
                                        lightBlue: lightBlue,
                                        successGreen: successGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Soru 2
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: ProjectExperienceTechnologies(
                                        options: _techOptions,
                                        selected: _technologies,
                                        customTech: _customTech,
                                        onCustomTechChanged: (v) => setState(() => _customTech = v),
                                        customTechController: _customTechController,
                                        onAddCustomTech: _addCustomTech,
                                        canAddCustomTech: _customTech.trim().isNotEmpty && !_technologies.contains(_customTech.trim()) && _technologies.length < 3,
                                        onChipTap: _onTechChipTap,
                                        mainBlue: mainBlue,
                                        gold: gold,
                                        cloudGrey: cloudGrey,
                                        lightBlue: lightBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Soru 3
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: ProjectExperienceFutureGoal(
                                        value: _futureGoal,
                                        onChanged: (v) => setState(() => _futureGoal = v),
                                        onInspireTap: _toggleFutureInspire,
                                        showInspirePopup: _showFutureInspire,
                                        inspireText: _futureInspireList[_futureInspireIdx],
                                        completed: _futureCompleted,
                                        mainBlue: mainBlue,
                                        gold: gold,
                                        cloudGrey: cloudGrey,
                                        lightBlue: lightBlue,
                                        successGreen: successGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Soru 4
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: ProjectExperienceChallenges(
                                        value: _challenges,
                                        onChanged: (v) => setState(() => _challenges = v),
                                        onInspireTap: _toggleChallengesInspire,
                                        showInspirePopup: _showChallengesInspire,
                                        inspireText: _challengesInspireList[_challengesInspireIdx],
                                        completed: _challengesCompleted,
                                        mainBlue: mainBlue,
                                        gold: gold,
                                        cloudGrey: cloudGrey,
                                        lightBlue: lightBlue,
                                        successGreen: successGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: ProjectExperienceProgressActions(
                                        completedCount: _completedCount,
                                        totalCount: 4,
                                        canSave: _canSave,
                                        isSaving: _isSaving,
                                        onSave: _saveData,
                                        onBack: () => Navigator.of(context).maybePop(),
                                        mainBlue: mainBlue,
                                        gold: gold,
                                        coral: coral,
                                        cloudGrey: cloudGrey,
                                        lightBlue: lightBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_showPastInspire || _showFutureInspire || _showChallengesInspire)
                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => setState(() {
                                      _showPastInspire = false;
                                      _showFutureInspire = false;
                                      _showChallengesInspire = false;
                                    }),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                            ],
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 