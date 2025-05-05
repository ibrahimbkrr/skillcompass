import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Future.wait için eklendi

// Gerekli ekran importları
import 'package:skillcompass_frontend/screens/login_screen.dart';
import 'package:skillcompass_frontend/screens/identity_status_screen.dart';
import 'package:skillcompass_frontend/screens/technical_profile_screen.dart';
import 'package:skillcompass_frontend/screens/learning_thinking_style_screen.dart';
// import 'package:skillcompass_frontend/screens/production_initiative_screen.dart'; // Bu ekran kaldırıldı
import 'package:skillcompass_frontend/screens/career_vision_screen.dart';
import 'package:skillcompass_frontend/screens/blockers_challenges_screen.dart';
import 'package:skillcompass_frontend/screens/support_community_screen.dart';
import 'package:skillcompass_frontend/screens/inner_obstacles_screen.dart';
import 'package:skillcompass_frontend/screens/analysis_report_screen.dart'; // Analiz ekranı

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _userData; // Temel kullanıcı bilgisi (ad/soyad)
  bool _isLoading = true; // Sayfa yükleniyor mu?
  String _errorMessage = ''; // Hata mesajı
  bool _isAnalyzing = false; // Analiz işlemi sürüyor mu?
  bool _hasAnalysisReport = false; // TODO: Analiz raporu var mı?

  // --- Firestore Doküman Adları (7 bölüm için) ---
  final Map<String, String> _profileDocNames = {
    'identity': 'identity_status_v3',
    'technical': 'technical_profile_v4', // Önceki kodda v3'tü, v4 yaptık
    'learning': 'learning_thinking_style_v2',
    'vision': 'career_vision_v5', // Önceki kodda v4'tü, v5 yaptık
    'blockers': 'blockers_challenges_v3', // Önceki kodda v2'ydi, v3 yaptık
    'support': 'support_community_v2',
    'obstacles': 'inner_obstacles_v2', // V2 yapıldı
  };
  // --------------------------------

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserData();
      // TODO: _checkAnalysisStatus(); // Analiz durumunu Firestore'dan kontrol et
    } else {
      // Kullanıcı null ise, build metodu yönlendirmeyi yapacak
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sadece temel kullanıcı bilgisini (ad/soyad) çeker
  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    if (_currentUser == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (snapshot.exists && mounted) {
        setState(() {
          _userData = snapshot.data();
          _isLoading = false; // Temel veri çekildi, yükleme bitti
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Kullanıcı profil bilgileri bulunamadı.';
        });
      }
    } catch (e) {
      print('HATA: Firestore kullanıcı verisi çekme hatası: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Bilgiler yüklenirken bir hata oluştu.';
        });
      }
    }
  }

  // --- Tüm Profil Verilerini Çekme Fonksiyonu (Detaylı Loglama) ---
  Future<Map<String, dynamic>> _fetchAllProfileData() async {
    print("[DEBUG] _fetchAllProfileData fonksiyonu başladı.");
    if (_currentUser == null) {
      print("[DEBUG] Hata: Kullanıcı null, veri çekilemiyor.");
      throw Exception("Kullanıcı oturumu bulunamadı.");
    }

    Map<String, dynamic> allData = {};
    final profileRef = _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('profile_data');
    print("[DEBUG] Profil referansı: ${profileRef.path}");

    for (var entry in _profileDocNames.entries) {
      final key = entry.key;
      final docName = entry.value;
      final docRef = profileRef.doc(docName);
      print("[DEBUG] '$docName' dokümanı çekiliyor: ${docRef.path}");
      try {
        final snapshot = await docRef.get();
        if (snapshot.exists && snapshot.data() != null) {
          print("[DEBUG] '$docName' dokümanı bulundu ve veri alındı.");
          allData[key] = snapshot.data();
        } else {
          print("[DEBUG] Uyarı: '$docName' dokümanı bulunamadı veya boş.");
          allData[key] = null;
        }
      } catch (e) {
        print("[DEBUG] HATA: '$docName' dokümanı çekilirken hata: $e");
        allData[key] = {'error': e.toString()};
      }
    }
    print("[DEBUG] Tüm profil verileri çekme işlemi tamamlandı.");
    return allData;
  }
  // --------------------------------------------------

  // --- Analiz Başlatma Fonksiyonu (Detaylı Loglama ve Düzeltilmiş Yönlendirme) ---
  Future<void> _startAnalysis() async {
    if (_isAnalyzing) return;
    if (!mounted) return;

    print("[DEBUG] _startAnalysis fonksiyonu başladı.");
    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
    });

    try {
      print('[DEBUG] Analiz başlatılıyor...');
      print('[DEBUG]   - Profil verileri çekiliyor...');
      Map<String, dynamic> allProfileData = await _fetchAllProfileData();

      print('[DEBUG] --- ÇEKİLEN TÜM PROFİL VERİLERİ ---');
      allProfileData.forEach((key, value) {
        if (value is Map && value.containsKey('error')) {
          print(
            "[DEBUG] Bölüm [$key]: Veri çekilemedi - Hata: ${value['error']}",
          );
        } else {
          String prettyValue = value?.toString() ?? 'Veri Yok';
          if (prettyValue.length > 150) {
            prettyValue = '${prettyValue.substring(0, 150)}...';
          }
          print("[DEBUG] Bölüm [$key]: $prettyValue");
        }
      });
      print('[DEBUG] ------------------------------------');

      print('[DEBUG]   - Backend analizi bekleniyor (simülasyon)...');
      await Future.delayed(const Duration(seconds: 3));
      Map<String, dynamic> analysisResult = {
        // Simüle edilmiş sonuç
        'summary':
            'Profilinize göre öğrenmeye ve pratik yapmaya odaklanmanız önerilir.',
        'strengths': ['Öğrenme İsteği', 'Belirli Alanlara İlgi'],
        'areasForImprovement': ['Algoritma Bilgisi', 'Proje Portföyü'],
      };
      print('[DEBUG]   - Analiz sonucu alındı (simülasyon).');

      if (mounted) {
        print("[DEBUG] Analiz Raporu ekranına yönlendiriliyor (veri ile).");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AnalysisReportScreen(
                  // Constructor doğru çağrılıyor
                  profileData: allProfileData,
                  analysisResult: analysisResult,
                ),
          ),
        );
        // setState(() { _hasAnalysisReport = true; });
      }
    } catch (e) {
      print('[DEBUG] HATA: Analiz işlemi sırasında genel hata: $e');
      if (mounted) {
        _showFeedback(
          'Analiz sırasında bir hata oluştu: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      print("[DEBUG] _startAnalysis fonksiyonu bitti.");
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }
  // ------------------------------------

  // --- Geri Bildirim Gösterme ---
  void _showFeedback(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  // ------------------------------------

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Kullanıcı null veya yükleniyor kontrolü
    if (_currentUser == null && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
      });
      return const Scaffold(
        body: Center(child: Text("Oturum yönlendiriliyor...")),
      );
    }

    // Kullanıcı adını hesapla
    String userName = 'Kullanıcı';
    if (_userData != null) {
      String firstName = _userData!['firstName'] ?? '';
      userName =
          firstName.trim().isNotEmpty
              ? firstName.trim()
              : (_currentUser!.email?.split('@')[0] ?? 'Kullanıcı');
    } else if (!_isLoading) {
      userName = _currentUser!.email?.split('@')[0] ?? 'Kullanıcı';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillCompass Bilişim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: _signOut,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'Hata: $_errorMessage\nLütfen sayfayı yenileyin.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Yenile"),
                        onPressed: _fetchUserData,
                      ),
                    ],
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchUserData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Karşılama
                      Text(
                        'Hoş Geldin, $userName!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        'Kariyer Profilini Oluştur:',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // --- Profil Kartları (Doğru Başlıklarla ve Sayılarla) ---
                      _buildDashboardCard(
                        context: context,
                        title: '1. Sen Kimsin ve Nerede Duruyorsun?',
                        description: 'Mevcut durumunu ve hedeflerini tanımla.',
                        icon: Icons.person_pin_circle_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const IdentityStatusScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildDashboardCard(
                        context: context,
                        title: '2. Ne Biliyorsun ve Nerede Uyguladın?',
                        description:
                            'Teknik becerilerini ve proje deneyimlerini belirt.',
                        icon: Icons.code_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const TechnicalProfileScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildDashboardCard(
                        context: context,
                        title: '3. Nasıl Düşünüyorsun ve Nasıl Öğreniyorsun?',
                        description:
                            'Öğrenme alışkanlıklarını ve düşünce yapını paylaş.',
                        icon: Icons.lightbulb_outline_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const LearningThinkingStyleScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildDashboardCard(
                        context: context,
                        title: '4. Neyi Hedefliyorsun Gerçekten?',
                        description:
                            'Kariyer hedeflerini ve motivasyonunu açıkla.',
                        icon: Icons.flag_circle_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CareerVisionScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildDashboardCard(
                        context: context,
                        title: '5. Nerede Tıkanıyorsun veya Eksiksin?',
                        description:
                            'Gelişim alanlarını ve karşılaştığın zorlukları belirt.',
                        icon: Icons.warning_amber_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const BlockersChallengesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildDashboardCard(
                        context: context,
                        title: '6. Destek, Topluluk ve Mentorluk İsteğin',
                        description:
                            'Yardım alma ve toplulukla etkileşim yaklaşımını paylaş.',
                        icon: Icons.groups_3_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const SupportCommunityScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildDashboardCard(
                        context: context,
                        title: '7. Gizli Engellerin, Korkuların, Bahanelerin',
                        description: 'Seni durduran içsel faktörleri keşfet.',
                        icon: Icons.shield_moon_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const InnerObstaclesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24.0),

                      // Analiz Kartı
                      _buildAnalysisCard(context, colorScheme),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
    );
  }

  // --- Düzeltilmiş Analiz Kartını Oluşturan Yardımcı Metot ---
  Widget _buildAnalysisCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: colorScheme.primaryContainer,
      child: InkWell(
        onTap:
            _isAnalyzing || _hasAnalysisReport
                ? () {
                  if (_hasAnalysisReport && mounted) {
                    // TODO: Gerçek veriyi veya rapor ID'sini gönder
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const AnalysisReportScreen(
                              profileData: {},
                              analysisResult: {},
                            ),
                      ),
                    );
                  }
                }
                : _startAnalysis,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                _isAnalyzing
                    ? [
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'Analiz Ediliyor...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ]
                    : [
                      Icon(
                        _hasAnalysisReport
                            ? Icons.description_outlined
                            : Icons.insights_rounded,
                        size: 30.0,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _hasAnalysisReport
                            ? 'Raporu Görüntüle'
                            : 'Analiz Başlat ve Yol Haritanı Gör',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
          ),
        ),
      ),
    );
  }
  // ---------------------------------------------------

  // --- Düzeltilmiş Profil kartları için yardımcı widget ---
  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 36.0, color: theme.colorScheme.primary),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
}
