import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/core/constants/app_constants.dart';

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
  bool _analysisStarted = false;
  String? _rawBackendMessage;

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

  Future<String?> _getBackendJwt() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.backendJwt;
  }

  Future<void> _fetchAnalysisHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      final token = await _getBackendJwt();
      if (user == null || token == null) {
        setState(() {
          _error = 'Kullanıcı bulunamadı veya oturum geçersiz.';
          _isLoading = false;
        });
        return;
      }
      final url = Uri.parse('${AppConstants.baseUrl}/users/${user.uid}/history');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _analysisJson = data['analysis_report'] != null ? jsonDecode(data['analysis_report']) : null;
          _lastAnalysisDate = data['generated_at'] != null ? DateTime.tryParse(data['generated_at']) : null;
        });
      } else {
        setState(() {
          _error = 'Analiz geçmişi alınamadı: ${response.body}';
        });
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
      _analysisStarted = true;
      _rawBackendMessage = null;
    });
    _buttonController.repeat(reverse: true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      final token = await _getBackendJwt();
      if (user == null || token == null) {
        setState(() {
          _error = 'Kullanıcı bulunamadı veya oturum geçersiz.';
        });
        return;
      }
      final url = Uri.parse('${AppConstants.baseUrl}/analysis/${user.uid}/analyze');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      setState(() {
        _rawBackendMessage = response.body;
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        try {
          if (data['status'] != 'success') {
            throw Exception(data['message'] ?? 'Bilinmeyen bir hata oluştu');
          }

          final analysisReport = data['analysis_report'];
          if (analysisReport == null) {
            throw Exception('Backend yanıtında analysis_report alanı bulunamadı');
          }

          Map<String, dynamic> json;
          try {
            json = jsonDecode(analysisReport);
          } catch (e) {
            setState(() {
              _error = 'Analiz sonucu JSON formatında değil. Backend yanıtı:\n$analysisReport';
              _rawBackendMessage = analysisReport;
            });
            return;
          }

          // JSON formatı doğru mu kontrol et
          if (!json.containsKey('ozet') || 
              !json.containsKey('guclu_yonler') || 
              !json.containsKey('gelisim_alanlari') || 
              !json.containsKey('oneriler') || 
              !json.containsKey('detaylar')) {
            setState(() {
              _error = 'Analiz sonucu beklenen formatta değil. Eksik alanlar var.';
              _rawBackendMessage = analysisReport;
            });
            return;
          }

          setState(() {
            _analysisJson = json;
            _error = null;
            _rawBackendMessage = null;
          });

          await _fetchAnalysisHistory();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Analiz başarıyla tamamlandı!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          setState(() {
            _error = 'Analiz sonucu işlenirken hata oluştu: ${e.toString()}';
            _rawBackendMessage = data['analysis_report'];
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _error = 'Analiz başarısız: ${errorData['detail'] ?? response.body}';
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

  Widget _buildSummaryCard(String summary, ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer.withOpacity(0.18),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.emoji_events, color: theme.colorScheme.primary, size: 38),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                summary,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipsSection(String title, List<String> items, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: items.map((item) => Chip(
            label: Text(item),
            backgroundColor: color.withOpacity(0.13),
            labelStyle: const TextStyle(fontSize: 13),
            avatar: Icon(icon, color: color, size: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestions(List<String> suggestions, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: theme.colorScheme.secondary, size: 22),
            const SizedBox(width: 8),
            Text('Öneriler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.secondary)),
          ],
        ),
        const SizedBox(height: 8),
        ...suggestions.map((oneri) => Card(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.13),
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(Icons.arrow_right, color: theme.colorScheme.secondary),
            title: Text(oneri, style: theme.textTheme.bodyMedium),
          ),
        )),
      ],
    );
  }

  Widget _buildDetails(List<Map<String, dynamic>> details, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: Colors.deepPurple, size: 22),
            const SizedBox(width: 8),
            Text('Detaylı Analizler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
          ],
        ),
        const SizedBox(height: 8),
        ...details.map((detay) => Card(
          color: Colors.deepPurple.withOpacity(0.07),
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detay['baslik'] ?? '', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(detay['icerik'] ?? '', style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildAnalysisResult() {
    final theme = Theme.of(context);
    if (_error != null && _error!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.red[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hata', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_error!, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      );
    }
    if (_rawBackendMessage != null && _rawBackendMessage!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.yellow[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Backend Yanıtı', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(_rawBackendMessage!, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_analysisJson == null ||
        (_analysisJson!["ozet"] == "" &&
         (_analysisJson!["guclu_yonler"] == null || (_analysisJson!["guclu_yonler"] as List).isEmpty) &&
         (_analysisJson!["gelisim_alanlari"] == null || (_analysisJson!["gelisim_alanlari"] as List).isEmpty) &&
         (_analysisJson!["oneriler"] == null || (_analysisJson!["oneriler"] as List).isEmpty) &&
         (_analysisJson!["detaylar"] == null || (_analysisJson!["detaylar"] as List).isEmpty))) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.info, size: 60, color: Colors.blueGrey[200]),
            const SizedBox(height: 16),
            Text(
              'Analiz için profil kartlarınızı eksiksiz doldurun.\nTüm kartlar doluysa ve yine de analiz çıkmıyorsa, lütfen tekrar deneyin.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blueGrey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_analysisJson != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(_analysisJson!["ozet"] ?? '', theme),
          const SizedBox(height: 18),
          _buildChipsSection("Güçlü Yönler", List<String>.from(_analysisJson!["guclu_yonler"] ?? []), Colors.green, Icons.star),
          const SizedBox(height: 18),
          _buildChipsSection("Gelişim Alanları", List<String>.from(_analysisJson!["gelisim_alanlari"] ?? []), Colors.orange, Icons.trending_up),
          const SizedBox(height: 18),
          _buildSuggestions(List<String>.from(_analysisJson!["oneriler"] ?? []), theme),
          const SizedBox(height: 18),
          _buildDetails(List<Map<String, dynamic>>.from(_analysisJson!["detaylar"] ?? []), theme),
          const SizedBox(height: 28),
          Center(
            child: Text(
              "Bu rapor, sağladığınız bilgilere dayanarak yapay zeka tarafından oluşturulmuştur.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.blueGrey[700]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildStartAnalysisButton() {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.analytics, color: Colors.white),
        label: Text(
          _isLoading ? "Analiz Yapılıyor..." : "Analizi Başlat",
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        onPressed: _isLoading ? null : _startAnalysis,
      ),
    );
  }

  Widget _buildError(String error) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        color: theme.colorScheme.errorContainer.withOpacity(0.15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
              const SizedBox(height: 16),
              Text(
                "Bir hata oluştu",
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Tekrar Dene"),
                onPressed: _startAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
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
        title: const Text('Kariyer Analizi'),
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
                    'Kariyer Analizi',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Güçlü ve gelişime açık yönlerini keşfetmek için analizi başlat!',
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.blueGrey[800]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildStartAnalysisButton(),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    Lottie.asset('assets/lottie/loading.json', width: 80, height: 80),
                  if (!_isLoading && _error != null && _error!.isNotEmpty)
                    _buildError(_error!),
                  if (!_isLoading && _analysisJson != null && (_error == null || _error!.isEmpty))
                    _buildAnalysisResult(),
                  if (!_isLoading && _analysisJson == null && (_error == null || _error!.isEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 80, color: Colors.blueGrey[200]),
                          const SizedBox(height: 16),
                          Text(
                            'Analiz başlatılmadı. Analiz için yukarıdaki butona tıkla!',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blueGrey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
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