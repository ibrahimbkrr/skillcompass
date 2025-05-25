import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skillcompass_frontend/features/profile/services/profile_service.dart';
import 'package:skillcompass_frontend/shared/widgets/loading_indicator.dart';
import 'package:skillcompass_frontend/shared/widgets/error_message.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart' as my_auth;

class SkillRadarChartScreen extends StatefulWidget {
  const SkillRadarChartScreen({super.key});

  @override
  State<SkillRadarChartScreen> createState() => _SkillRadarChartScreenState();
}

class _SkillRadarChartScreenState extends State<SkillRadarChartScreen> {
  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _analysisResult;
  List<dynamic> _progressSteps = [];
  
  // Kullanıcının becerileri
  Map<String, double> _skillLevels = {};
  List<String> _skillCategories = [];
  
  // Kullanıcının teknoloji deneyimleri
  List<Map<String, dynamic>> _technologies = [];
  
  // İlerleme hedefleri
  Map<String, double> _targetLevels = {};
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _startAnalysis);
  }
  
  Future<void> _startAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _analysisResult = null;
      _progressSteps = [];
    });
    try {
      final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
      final user = authProvider.user;
      final token = authProvider.backendJwt;
      if (user == null || token == null) {
        setState(() {
          _error = 'Kullanıcı oturumu yok veya JWT alınamadı.';
        });
        return;
      }
      final profileService = ProfileService();
      final result = await profileService.analyzeUserProfileWithToken(user.uid, token);
      if (result['status'] == 'success') {
        setState(() {
          _analysisResult = result['data'];
          _progressSteps = result['progress'] ?? [];
        });
        } else {
        setState(() {
          _error = result['message'] ?? 'Analiz başarısız.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Analiz sırasında hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kariyer Analizi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startAnalysis,
            tooltip: 'Analizi Yenile',
          ),
        ],
      ),
      body: _isLoading 
          ? _buildProgressView(theme)
        : _error.isNotEmpty
            ? Center(child: ErrorMessage(message: _error))
              : _analysisResult != null
                  ? _buildAnalysisResult(theme)
                  : const Center(child: Text('Analiz sonucu bulunamadı.')),
    );
  }
  
  Widget _buildProgressView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          ..._progressSteps.map((step) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  step['message'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              )),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisResult(ThemeData theme) {
    final ozet = _analysisResult?['ozet'] ?? '';
    final gucluYonler = List<String>.from(_analysisResult?['guclu_yonler'] ?? []);
    final gelisimAlanlari = List<String>.from(_analysisResult?['gelisim_alanlari'] ?? []);
    final oneriler = List<String>.from(_analysisResult?['oneriler'] ?? []);
    final detaylar = List<Map<String, dynamic>>.from(_analysisResult?['detaylar'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Text('Genel Özet', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(ozet, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  theme,
                  title: 'Güçlü Yönler',
                  items: gucluYonler,
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  theme,
                  title: 'Gelişim Alanları',
                  items: gelisimAlanlari,
                  icon: Icons.trending_up,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            theme,
            title: 'Öneriler',
            items: oneriler,
            icon: Icons.lightbulb,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          if (detaylar.isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Detaylar', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...detaylar.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['baslik'] ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
                              Text(d['icerik'] ?? '', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(ThemeData theme, {required String title, required List<String> items, required IconData icon, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
            Row(
              children: [
                Icon(icon, color: color),
                          const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
                  ),
                  const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                      Icon(Icons.circle, size: 8, color: color.withOpacity(0.7)),
                          const SizedBox(width: 8),
                      Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                )),
              ],
            ),
          ),
    );
  }
} 