import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/features/dashboard/presentation/services/analysis_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Artık doğrudan Firestore işlemi yapmıyoruz
// import 'package:intl/intl.dart'; // Tarih formatlama için şimdilik gerek yok

// Analiz metnini gösteren ekran
class AnalysisReportScreen extends StatefulWidget {
  const AnalysisReportScreen({super.key});

  @override
  State<AnalysisReportScreen> createState() => _AnalysisReportScreenState();
}

class _AnalysisReportScreenState extends State<AnalysisReportScreen> {
  bool _isLoading = true;
  String _error = '';
  List<ProgressStep> _progress = [];
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final analysisService = AnalysisService(authProvider);

    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final response = await analysisService.startAnalysis();
      print('DEBUG ANALYSIS RESPONSE: ' + response.toString());

      setState(() {
        _progress = response.progress;
        if (response.status == 'success') {
          _analysisData = response.data;
          _error = '';
        } else {
          _error = response.message ?? 'Bilinmeyen bir hata oluştu';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildProgressIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        if (_progress.isNotEmpty)
          Column(
            children: _progress.map((step) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(step.message),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Hata Oluştu',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _startAnalysis,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    print('DEBUG _analysisData: [33m[1m[4m' + _analysisData.toString() + '\u001b[0m');
    if (_analysisData == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet
          _buildSectionTitle(context, Icons.summarize, "Özet"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primaryContainer.withOpacity(0.3),
              ),
            ),
            child: Text(
              _analysisData!['ozet'] ?? '',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ),
          const SizedBox(height: 24),

          // Güçlü Yönler
          _buildSectionTitle(context, Icons.star, "Güçlü Yönler"),
          _buildChipList(
            context,
            List<String>.from(_analysisData!['guclu_yonler'] ?? []),
            Colors.green,
          ),

          // Gelişim Alanları
          _buildSectionTitle(context, Icons.trending_up, "Gelişim Alanları"),
          _buildChipList(
            context,
            List<String>.from(_analysisData!['gelisim_alanlari'] ?? []),
            Colors.orange,
          ),

          // Öneriler
          _buildSectionTitle(context, Icons.lightbulb, "Öneriler"),
          Column(
            children: List<String>.from(_analysisData!['oneriler'] ?? [])
                .map((oneri) => ListTile(
                      leading: const Icon(Icons.arrow_right),
                      title: Text(oneri),
                      contentPadding: EdgeInsets.zero,
                    ))
                .toList(),
          ),

          // Detaylı Analizler
          _buildSectionTitle(context, Icons.analytics, "Detaylı Analizler"),
          Column(
            children: List<Map<String, dynamic>>.from(
                    _analysisData!['detaylar'] ?? [])
                .map((detay) => Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detay['baslik'] ?? '',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              detay['icerik'] ?? '',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 30),

          // Son Not
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "Bu rapor, sağladığınız bilgilere dayanarak yapay zeka tarafından oluşturulmuştur.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey[700],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Yardımcı Widget: Bölüm Başlığı ---
  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12.0,
        top: 16.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Yardımcı Widget: Chip Listesi ---
  Widget _buildChipList(
    BuildContext context,
    List<String> items,
    Color chipColor,
  ) {
    final theme = Theme.of(context);
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 6.0,
        children: items
            .map(
              (item) => Chip(
                label: Text(item),
                backgroundColor: chipColor.withOpacity(0.15),
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                side: BorderSide(color: chipColor.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Raporu ve Yol Haritası'),
        elevation: 1,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: _buildProgressIndicator())
          : _error.isNotEmpty
              ? _buildErrorWidget()
              : _buildAnalysisResult(),
    );
  }
}
