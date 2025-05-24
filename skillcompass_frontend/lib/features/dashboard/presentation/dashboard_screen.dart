import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/features/auth/presentation/login_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/identity_status_card_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/technical_profile_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/technical_profile_card_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/learning_thinking_style_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/career_vision_card_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/blockers_challenges_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/support_community_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/networking_card_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/project_experience_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/personal_brand_card_screen.dart';
import 'package:skillcompass_frontend/core/theme/theme_provider.dart';
import 'package:skillcompass_frontend/core/widgets/custom_button.dart';
import 'package:skillcompass_frontend/core/widgets/custom_snackbar.dart';
import 'widgets/dashboard_profile_card.dart';
import 'package:skillcompass_frontend/features/dashboard/presentation/analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  int? _completedCards;
  bool _progressLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCompletedCards();
  }

  Future<void> _fetchCompletedCards() async {
    setState(() { _progressLoading = true; });
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) {
        setState(() { _completedCards = 0; _progressLoading = false; });
        debugPrint('Kullanıcı yok, completed_cards = 0');
        return;
      }
      final doc = await _firestore.collection('users').doc(user.uid).get();
      debugPrint('Firestore user doc: ' + doc.data().toString());
      debugPrint('Firestore completed_cards: ' + (doc.data()?['completed_cards']?.toString() ?? 'null'));
      setState(() {
        _completedCards = (doc.data()?['completed_cards'] ?? 0) as int;
        _progressLoading = false;
      });
    } catch (e) {
      setState(() { _completedCards = 0; _progressLoading = false; });
      debugPrint('Firestore completed_cards çekilirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil ilerlemesi alınamadı: $e')),
        );
      }
    }
  }

  Future<void> incrementCompletedCards() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final current = (snapshot.data()?['completed_cards'] ?? 0) as int;
      transaction.update(docRef, {'completed_cards': current + 1});
    });
    // Güncel değeri tekrar çek
    await _fetchCompletedCards();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(theme.brightness == Brightness.dark 
                ? Icons.light_mode 
                : Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Tema Değiştir',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: _buildBody(theme, user),
    );
  }

  Widget _buildBody(ThemeData theme, firebase_auth.User? user) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.background,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(theme, user),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: incrementCompletedCards,
              child: const Text('Kart Tamamla (Test)'),
            ),
            const SizedBox(height: 24),
            _buildProfileNavigation(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme, firebase_auth.User? user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.onPrimary,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoş Geldiniz!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Kullanıcı',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Yeteneklerinizi keşfetmeye ve geliştirmeye devam edin!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavigation(ThemeData theme) {
    final profileSections = [
      {
        'title': 'Kimlik Durumu',
        'icon': Icons.person,
        'route': const IdentityStatusCardScreen(),
        'color': Colors.blue,
      },
      {
        'title': 'Teknik Profil',
        'icon': Icons.code,
        'route': const TechnicalProfileCardScreen(),
        'color': Colors.green,
      },
      {
        'title': 'Öğrenme Stili',
        'icon': Icons.school,
        'route': const LearningThinkingStyleScreen(),
        'color': Colors.orange,
      },
      {
        'title': 'Kariyer Vizyonu',
        'icon': Icons.work,
        'route': const CareerVisionCardScreen(),
        'color': Colors.purple,
      },
      {
        'title': 'Engeller',
        'icon': Icons.folder_special,
        'route': const ProjectExperienceScreen(),
        'color': Colors.amber,
      },
      {
        'title': 'İç Engeller',
        'icon': Icons.psychology,
        'route': const NetworkingCardScreen(),
        'color': Colors.teal,
      },
      {
        'title': 'Destek',
        'icon': Icons.people,
        'route': const PersonalBrandCardScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'Analiz Et',
        'icon': Icons.bar_chart,
        'route': const AnalysisScreen(),
        'color': Colors.red,
      },
    ];
    final int totalCards = profileSections.length;
    final int completedCards = _completedCards ?? 0;
    final double progress = completedCards / totalCards;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil Bölümleri',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Profil tamamlama çubuğu
        _progressLoading
            ? const LinearProgressIndicator(minHeight: 10)
            : Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('%${(progress * 100).toInt()}', style: theme.textTheme.bodyMedium),
                ],
              ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          cacheExtent: 500,
          itemCount: profileSections.length,
          itemBuilder: (context, index) {
            final section = profileSections[index];
            return DashboardProfileCard(
              title: section['title'] as String,
              icon: section['icon'] as IconData,
              color: section['color'] as Color,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => section['route'] as Widget),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Başarıyla çıkış yapıldı',
          type: SnackBarType.success,
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Çıkış yapılırken bir hata oluştu',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
