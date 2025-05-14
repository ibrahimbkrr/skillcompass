import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/features/profile/presentation/identity_status_card_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/technical_profile_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/technical_profile_card_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/learning_thinking_style_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/career_vision_card_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/blockers_challenges_screen_modernized.dart';
import 'package:skillcompass_frontend/features/profile/presentation/inner_obstacles_screen.dart';
import 'package:skillcompass_frontend/features/profile/presentation/support_community_screen.dart';
import 'package:skillcompass_frontend/features/skill_analysis/skill_radar_chart_screen.dart';
import 'package:skillcompass_frontend/features/career_suggestions/ai_career_path_suggestions_screen.dart';
import 'package:skillcompass_frontend/features/profile/services/profile_analytics_service.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:skillcompass_frontend/shared/widgets/page_transition.dart';

class ProfileDashboardScreen extends StatefulWidget {
  const ProfileDashboardScreen({super.key});

  @override
  State<ProfileDashboardScreen> createState() => _ProfileDashboardScreenState();
}

class _ProfileDashboardScreenState extends State<ProfileDashboardScreen> {
  final ProfileAnalyticsService _analyticsService = ProfileAnalyticsService();
  bool _isLoading = true;
  Map<String, dynamic>? _profileAnalytics;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfileAnalytics();
  }

  Future<void> _loadProfileAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final analytics = await _analyticsService.calculateProfileCompleteness();
      setState(() {
        _profileAnalytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Profil analizi yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(
          child: Text('Oturum açmanız gerekiyor'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadProfileAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _error != null
              ? Center(child: ErrorMessage(message: _error!))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(theme, user),
                        const SizedBox(height: 24),
                        _buildCompletionCard(theme),
                        const SizedBox(height: 24),
                        Text(
                          'Profil Bölümleri',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildProfileCard(
                              context,
                              title: 'Kimlik ve Durum',
                              icon: Icons.person,
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const IdentityStatusCardScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildProfileCard(
                              context,
                              title: 'Teknik Profil',
                              icon: Icons.code,
                              color: Colors.deepPurple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TechnicalProfileCardScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildProfileCard(
                              context,
                              title: 'Öğrenme Stili',
                              icon: Icons.school,
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LearningThinkingStyleScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildProfileCard(
                              context,
                              title: 'Kariyer Vizyonu',
                              icon: Icons.trending_up,
                              color: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CareerVisionCardScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildProfileCard(
                              context,
                              title: 'Engeller ve Zorluklar',
                              icon: Icons.block,
                              color: Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BlockersChallengesScreenModernized(),
                                  ),
                                );
                              },
                            ),
                            _buildProfileCard(
                              context,
                              title: 'İç Engeller',
                              icon: Icons.psychology,
                              color: Colors.deepOrange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const InnerObstaclesScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildProfileCard(
                              context,
                              title: 'Destek ve Topluluk',
                              icon: Icons.people,
                              color: Colors.teal,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SupportCommunityScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Analizler ve Öneriler',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildProfileCard(
                              context,
                              title: 'Beceri Radar Haritası',
                              icon: Icons.radar_chart,
                              color: Colors.indigo,
                              isNew: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SkillRadarChartScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildProfileCard(
                              context,
                              title: 'Kariyer Yolu Önerileri',
                              icon: Icons.insights,
                              color: Colors.purple,
                              isNew: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AICareerPathSuggestionsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, User user) {
    final displayName = user.displayName ?? user.email?.split('@').first ?? 'Kullanıcı';
    
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard(ThemeData theme) {
    final completionPercentage = _profileAnalytics!['overall_percentage'] as double;
    final sections = _profileAnalytics!['sections'] as Map<String, dynamic>;
    
    Color getProgressColor(double value) {
      if (value < 30) return Colors.red;
      if (value < 70) return Colors.orange;
      return Colors.green;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profil Tamamlanma',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getProgressColor(completionPercentage).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '%${completionPercentage.toInt()}',
                    style: TextStyle(
                      color: getProgressColor(completionPercentage),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: completionPercentage / 100,
              minHeight: 8,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                getProgressColor(completionPercentage),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),
            Text(
              'Bölüm Detayları',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSectionProgress(
              theme, 
              'Kimlik Durumu', 
              sections['identity_status']['percentage'] as double,
            ),
            const SizedBox(height: 8),
            _buildSectionProgress(
              theme, 
              'Teknik Profil', 
              sections['technical_profile']['percentage'] as double,
            ),
            const SizedBox(height: 8),
            _buildSectionProgress(
              theme, 
              'Öğrenme Stili', 
              sections['learning_style']['percentage'] as double,
            ),
            const SizedBox(height: 8),
            _buildSectionProgress(
              theme, 
              'Kariyer Vizyonu', 
              sections['career_vision']['percentage'] as double,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionProgress(ThemeData theme, String title, double percentage) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(title),
        ),
        Expanded(
          flex: 6,
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage < 30 
                  ? Colors.red 
                  : percentage < 70 
                      ? Colors.orange 
                      : Colors.green,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '%${percentage.toInt()}',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isNew)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Yeni',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 