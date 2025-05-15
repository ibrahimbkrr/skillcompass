import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'networking_header.dart';
import 'mentorship_need_question.dart';
import 'current_connections_question.dart';
import 'networking_goal_question.dart';
import 'networking_challenges_question.dart';
import 'networking_progress_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NetworkingCard extends StatefulWidget {
  const NetworkingCard({super.key});

  @override
  State<NetworkingCard> createState() => _NetworkingCardState();
}

class _NetworkingCardState extends State<NetworkingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  // Soru 1: Mentorluk ihtiyacı
  String _mentorshipNeed = '';
  String _customMentorshipNeed = '';
  bool get _mentorshipCompleted => _mentorshipNeed.isNotEmpty;

  // Soru 2: Mevcut Bağlantılar
  List<String> _connections = [];
  String _customConnection = '';
  bool get _connectionsCompleted => _connections.isNotEmpty;

  // Soru 3: Networking Hedefi
  String _networkingGoal = '';
  int _goalInspireIdx = 0;
  bool _showGoalInspire = false;
  final List<String> _goalInspireList = [
    'Bir açık kaynak projesinde 5 geliştiriciyle bağlantı kurmak.',
    'Bir bilişim konferansında 10 yeni bağlantı kurmak.',
    'LinkedIn üzerinden 20 yeni profesyonel bağlantı eklemek.',
    'Bir topluluk etkinliğinde liderlik yapmak.',
  ];
  bool get _goalCompleted => _networkingGoal.trim().length >= 10;

  // Soru 4: Networking Zorlukları
  String _networkingChallenges = '';
  int _challengesInspireIdx = 0;
  bool _showChallengesInspire = false;
  final List<String> _challengesInspireList = [
    'Zaman eksikliği nedeniyle etkinliklere katılamamak.',
    'Çekingenlik ve yeni insanlarla iletişimde zorluk.',
    'Dil bariyeri veya teknik terimlerde yetersizlik.',
    'Profesyonel platformları etkin kullanamamak.',
  ];
  bool get _challengesCompleted => _networkingChallenges.trim().length >= 10;

  // Progress & Save
  bool _isSaving = false;
  String? _error;
  int get _completedCount => [_mentorshipCompleted, _connectionsCompleted, _goalCompleted, _challengesCompleted].where((b) => b).length;
  bool get _canSave => _mentorshipCompleted && _connectionsCompleted && _goalCompleted && _challengesCompleted;

  Future<void> _saveData() async {
    setState(() { _isSaving = true; _error = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Oturum bulunamadı');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_profile')
          .doc('networking')
          .set({
        'mentorship_need': _mentorshipNeed,
        'current_connections': _connections,
        'networking_goal': _networkingGoal,
        'networking_challenges': _networkingChallenges,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Networking bilgileri kaydedildi!', style: GoogleFonts.inter()), backgroundColor: Colors.green),
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

  void _addCustomMentorshipNeed() {
    if (_customMentorshipNeed.trim().isNotEmpty) {
      setState(() {
        _mentorshipNeed = _customMentorshipNeed.trim();
        _customMentorshipNeed = '';
      });
    }
  }

  void _onConnectionChanged(String value) {
    setState(() {
      if (_connections.contains(value)) {
        _connections.remove(value);
        if (value == 'Diğer') _customConnection = '';
      } else if (_connections.length < 3) {
        _connections.add(value);
        if (value == 'Diğer') _customConnection = '';
      }
    });
  }

  void _addCustomConnection() {
    if (_customConnection.trim().isNotEmpty && !_connections.contains(_customConnection.trim()) && _connections.length < 3) {
      setState(() {
        _connections.add(_customConnection.trim());
        _customConnection = '';
      });
    }
  }

  void _toggleGoalInspire() {
    setState(() {
      _showGoalInspire = !_showGoalInspire;
      if (_showGoalInspire) {
        _goalInspireIdx = (_goalInspireIdx + 1) % _goalInspireList.length;
      }
    });
  }

  void _toggleChallengesInspire() {
    setState(() {
      _showChallengesInspire = !_showChallengesInspire;
      if (_showChallengesInspire) {
        _challengesInspireIdx = (_challengesInspireIdx + 1) % _challengesInspireList.length;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainBlue = theme.colorScheme.primary;
    final gold = theme.colorScheme.secondary;
    final cloudGrey = theme.colorScheme.outline;
    final lightBlue = theme.colorScheme.primaryContainer;
    final successGreen = theme.colorScheme.secondaryContainer;

    void _showGuideDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Mentorship & Networking Card', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: mainBlue)),
          content: Text(
            'Bu kart, profesyonel ağınızı geliştirmenize yardımcı olur. Mentorluk ihtiyaçlarınızı ve networking hedeflerinizi tanımlayarak bağlantılarınızı güçlendirin.',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[800]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Kapat', style: GoogleFonts.inter(color: mainBlue))),
          ],
        ),
      );
    }

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: NetworkingHeader(
                          mainBlue: mainBlue,
                          gold: gold,
                          cloudGrey: cloudGrey,
                          onGuide: _showGuideDialog,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Soru 1: Mentorluk İhtiyacı
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: MentorshipNeedQuestion(
                          value: _mentorshipNeed,
                          onChanged: (v) => setState(() {
                            _mentorshipNeed = v;
                            if (v != '' && v != _customMentorshipNeed) _customMentorshipNeed = '';
                          }),
                          customValue: _customMentorshipNeed,
                          onCustomChanged: (v) => setState(() => _customMentorshipNeed = v),
                          onAddCustom: _addCustomMentorshipNeed,
                          canAddCustom: _customMentorshipNeed.trim().isNotEmpty,
                          completed: _mentorshipCompleted,
                          mainBlue: mainBlue,
                          gold: gold,
                          cloudGrey: cloudGrey,
                          lightBlue: lightBlue,
                          successGreen: successGreen,
                        ),
                      ),
                      // Soru 2: Mevcut Bağlantılar
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: CurrentConnectionsQuestion(
                          selected: _connections,
                          onChanged: _onConnectionChanged,
                          customValue: _customConnection,
                          onCustomChanged: (v) => setState(() => _customConnection = v),
                          onAddCustom: _addCustomConnection,
                          canAddCustom: _customConnection.trim().isNotEmpty && !_connections.contains(_customConnection.trim()) && _connections.length < 3,
                          completed: _connectionsCompleted,
                          mainBlue: mainBlue,
                          gold: gold,
                          cloudGrey: cloudGrey,
                          lightBlue: lightBlue,
                          successGreen: successGreen,
                        ),
                      ),
                      // Soru 3: Networking Hedefi
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: NetworkingGoalQuestion(
                          value: _networkingGoal,
                          onChanged: (v) => setState(() => _networkingGoal = v),
                          onInspireTap: _toggleGoalInspire,
                          showInspirePopup: _showGoalInspire,
                          inspireText: _goalInspireList[_goalInspireIdx],
                          completed: _goalCompleted,
                          mainBlue: mainBlue,
                          gold: gold,
                          cloudGrey: cloudGrey,
                          lightBlue: lightBlue,
                          successGreen: successGreen,
                        ),
                      ),
                      // Soru 4: Networking Zorlukları
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: NetworkingChallengesQuestion(
                          value: _networkingChallenges,
                          onChanged: (v) => setState(() => _networkingChallenges = v),
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
                      // TODO: Add other questions, progress, actions
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: NetworkingProgressActions(
                          completedCount: _completedCount,
                          totalCount: 4,
                          canSave: _canSave,
                          isSaving: _isSaving,
                          onSave: _saveData,
                          onBack: () => Navigator.of(context).maybePop(),
                          mainBlue: mainBlue,
                          gold: gold,
                          coral: Colors.deepOrangeAccent,
                          cloudGrey: cloudGrey,
                          lightBlue: lightBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 