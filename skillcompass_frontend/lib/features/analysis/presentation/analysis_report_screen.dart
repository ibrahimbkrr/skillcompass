import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/features/dashboard/presentation/services/analysis_service.dart';
import 'package:skillcompass_frontend/features/analysis/model/analysis_model.dart';
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
  AnalizModel? _analiz;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await AnalysisService(authProvider).startAnalysis(context);
      if (response.status == 'success') {
        _analiz = AnalizModel.fromJson(response.data!);
        _error = '';
      } else {
        _error = response.message ?? 'Bilinmeyen bir hata oluştu';
      }
    } catch (e) {
      _error = e.toString();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Color _getCategoryColor(String ad) {
    switch (ad) {
      case "Kimlik": return Colors.blue;
      case "Teknik Profil": return Colors.green;
      case "Öğrenme Stili": return Colors.orange;
      case "Kariyer Vizyonu": return Colors.purple;
      case "Proje Deneyimleri": return Colors.amber;
      case "Networking": return Colors.indigo;
      case "Kişisel Marka": return Colors.deepPurple;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String ad) {
    switch (ad) {
      case "Kimlik": return Icons.person;
      case "Teknik Profil": return Icons.code;
      case "Öğrenme Stili": return Icons.school;
      case "Kariyer Vizyonu": return Icons.work;
      case "Proje Deneyimleri": return Icons.rocket_launch;
      case "Networking": return Icons.wifi;
      case "Kişisel Marka": return Icons.verified_user;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context, listen: false).user?.displayName ?? 'Kullanıcı';
    return Scaffold(
      backgroundColor: const Color(0xFFB2FEFA),
      appBar: AppBar(
        title: const Text('Kapsamlı Profil Analizi'),
        elevation: 1,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _startAnalysis,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _analiz == null
                  ? const Center(child: Text('Analiz verisi bulunamadı.'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Özet Kartı
                            _AnalysisSummaryCard(userName: userName, ozet: _analiz!.ozet),
                            const SizedBox(height: 24),
                            // Kategori Kartları Grid
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: _analiz!.kategoriler.map((cat) {
                                final meta = getCategoryMeta(cat.ad);
                                return SizedBox(
                                  width: (MediaQuery.of(context).size.width - 48) / 2, // 2 sütunlu responsive
                                  child: _AnalysisCategoryCard(cat: cat, meta: meta),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

class _AnalysisSummaryCard extends StatelessWidget {
  final String userName;
  final String ozet;
  const _AnalysisSummaryCard({required this.userName, required this.ozet});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.blue,
              child: Text(userName[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 4),
                  const Text("Kapsamlı Analiz Raporu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Chip(label: Text("Kariyer Yolculuğu Başladı!", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green),
                  const SizedBox(height: 8),
                  Text(ozet, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCategoryCard extends StatefulWidget {
  final KategoriModel cat;
  final CategoryMeta meta;
  const _AnalysisCategoryCard({required this.cat, required this.meta});

  @override
  State<_AnalysisCategoryCard> createState() => _AnalysisCategoryCardState();
}

class _AnalysisCategoryCardState extends State<_AnalysisCategoryCard> {
  bool showFull = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    final meta = widget.meta;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: meta.color, child: Icon(meta.icon, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.ad,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: meta.color),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(meta.badge, style: const TextStyle(color: Colors.white)),
                        backgroundColor: meta.color,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildExpandableText(cat.aciklama, 3),
            const SizedBox(height: 10),
            _buildExpandableSection("Güçlü Yönler", cat.gucluYonler, meta.color),
            _buildExpandableSection("Gelişim Alanları", cat.gelisimAlanlari, meta.color),
            _buildExpandableSection("Öneriler", cat.oneriler, meta.color),
            _buildExpandableTextSection("Motivasyon", cat.motivasyon, meta.color),
            _buildExpandableTextSection("Örnek", cat.ornek, meta.color),
            _buildExpandableSection("Kaynaklar", cat.kaynaklar, meta.color),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableText(String text, int maxLines) {
    if (text.isEmpty) return const SizedBox.shrink();
    final shouldShorten = text.split(' ').length > 20 && !showFull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: shouldShorten ? maxLines : null,
          overflow: shouldShorten ? TextOverflow.ellipsis : null,
        ),
        if (shouldShorten)
          GestureDetector(
            onTap: () => setState(() => showFull = true),
            child: Text('Devamı...', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildExpandableSection(String title, List<String> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    final shouldShorten = items.length > 3 && !showFull;
    final shownItems = shouldShorten ? items.take(3).toList() : items;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ...shownItems.map((e) => Row(
                children: [
                  Icon(Icons.check_circle, color: color, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(e)),
                ],
              )),
          if (shouldShorten)
            GestureDetector(
              onTap: () => setState(() => showFull = true),
              child: Text('Devamı...', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableTextSection(String title, String value, Color color) {
    if (value.isEmpty) return const SizedBox.shrink();
    final shouldShorten = value.split(' ').length > 20 && !showFull;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(
            value,
            maxLines: shouldShorten ? 3 : null,
            overflow: shouldShorten ? TextOverflow.ellipsis : null,
          ),
          if (shouldShorten)
            GestureDetector(
              onTap: () => setState(() => showFull = true),
              child: Text('Devamı...', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
