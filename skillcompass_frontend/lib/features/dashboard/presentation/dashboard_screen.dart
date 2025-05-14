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
import 'package:skillcompass_frontend/features/profile/presentation/inner_obstacles_screen.dart';
import 'package:skillcompass_frontend/core/theme/theme_provider.dart';
import 'package:skillcompass_frontend/core/widgets/custom_button.dart';
import 'package:skillcompass_frontend/core/widgets/custom_snackbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

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
        'icon': Icons.block,
        'route': const BlockersChallengesScreen(),
        'color': Colors.red,
      },
      {
        'title': 'İç Engeller',
        'icon': Icons.psychology,
        'route': const InnerObstaclesScreen(),
        'color': Colors.teal,
      },
      {
        'title': 'Destek',
        'icon': Icons.people,
        'route': const SupportCommunityScreen(),
        'color': Colors.indigo,
      },
    ];

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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: profileSections.length,
          itemBuilder: (context, index) {
            final section = profileSections[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => section['route'] as Widget),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        section['icon'] as IconData,
                        size: 32,
                        color: section['color'] as Color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
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
