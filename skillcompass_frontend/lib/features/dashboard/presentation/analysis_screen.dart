import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _analysisJson;
  DateTime? _lastAnalysisDate;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    _fetchAnalysisHistory();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnalysisHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) {
        setState(() {
          _error = 'Kullanıcı bulunamadı.';
          _isLoading = false;
        });
        return;
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile_data')
          .doc('analysis_report')
          .get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        try {
          final json = jsonDecode(data['report_text'] ?? '{}');
          setState(() {
            _analysisJson = json;
            _lastAnalysisDate = (data['generated_at'] as Timestamp?)?.toDate();
          });
        } catch (e) {
          setState(() {
            _error = 'Analiz raporu okunamadı. Lütfen tekrar analiz yapın.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Analiz geçmişi alınamadı: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _analysisJson = null;
    });
    _buttonController.repeat(reverse: true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) {
        setState(() {
          _error = 'Kullanıcı bulunamadı.';
          _isLoading = false;
        });
        _buttonController.stop();
        return;
      }
      final url = Uri.parse('http://192.168.1.109:8000/users/${user.uid}/analyze');
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        try {
          final json = jsonDecode(data['analysis_report'] ?? '{}');
          setState(() {
            _analysisJson = json;
          });
          await _fetchAnalysisHistory();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Analiz başarıyla tamamlandı!')),
            );
          }
        } catch (e) {
          setState(() {
            _error = 'Analiz sonucu okunamadı. Lütfen tekrar deneyin.';
          });
        }
      } else {
        setState(() {
          _error = 'Analiz başarısız: ${response.body}';
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
      _buttonController.stop();
    }
  }

  Widget _buildSummaryCard(String summary) {
    return Card(
      color: Colors.blue[50],
      elevation: 4,
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.blue, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                summary,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipSection(String title, List<dynamic> items, Color color, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 6, top: 10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: items.map((e) => Chip(
            label: Text(e.toString()),
            backgroundColor: color.withOpacity(0.15),
            labelStyle: const TextStyle(fontSize: 14),
            side: BorderSide(color: color.withOpacity(0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionList(List<dynamic> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      color: Colors.green[50],
      elevation: 2,
      margin: const EdgeInsets.only(top: 18, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.tips_and_updates, color: Colors.green, size: 22),
                SizedBox(width: 8),
                Text('Öneriler', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((e) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(e.toString(), style: const TextStyle(fontSize: 15))),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(List<dynamic> details) {
    if (details.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 6, top: 10),
          child: Text('Detaylı Analiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ...details.map((d) {
          final baslik = d['baslik'] ?? '';
          final icerik = d['icerik'] ?? '';
          return Card(
            color: Colors.white,
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ExpansionTile(
              title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(icerik, style: const TextStyle(fontSize: 15)),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profilini Analiz Et'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/analysis.json',
                    width: size.width * 0.6,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hadi Profilini Analiz Edelim!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Güçlü ve gelişime açık yönlerini keşfet, kariyer yolculuğunda bir adım öne geç!',
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.blueGrey[800]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  if (_lastAnalysisDate != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 20, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Text('Son analiz: ${_lastAnalysisDate!.toLocal().toString().substring(0, 16)}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey)),
                      ],
                    ),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: _buttonController,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: _isLoading ? null : _startAnalysis,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isLoading
                                  ? [Colors.blueGrey, Colors.blueGrey[200]!]
                                  : [Colors.blue, Colors.cyan],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? Lottie.asset(
                                    'assets/lottie/loading.json',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.analytics, color: Colors.white, size: 28),
                                      SizedBox(width: 10),
                                      Text(
                                        'Analiz Et',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Card(
                        color: Colors.red[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(_error!, style: const TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                  if (_analysisJson != null) ...[
                    _buildSummaryCard(_analysisJson!["ozet"] ?? ""),
                    _buildChipSection("Güçlü Yönler", _analysisJson!["guclu_yonler"] ?? [], Colors.blue, Icons.thumb_up_alt),
                    _buildChipSection("Gelişim Alanları", _analysisJson!["gelisim_alanlari"] ?? [], Colors.orange, Icons.trending_up),
                    _buildSuggestionList(_analysisJson!["oneriler"] ?? []),
                    _buildDetailsSection(_analysisJson!["detaylar"] ?? []),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 