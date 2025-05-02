import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Gerekli ekran importları
import 'package:skillcompass_frontend/screens/login_screen.dart';
import 'package:skillcompass_frontend/screens/identity_status_screen.dart';
import 'package:skillcompass_frontend/screens/technical_profile_screen.dart';
import 'package:skillcompass_frontend/screens/learning_thinking_style_screen.dart';
import 'package:skillcompass_frontend/screens/production_initiative_screen.dart';
import 'package:skillcompass_frontend/screens/career_vision_screen.dart';
import 'package:skillcompass_frontend/screens/blockers_challenges_screen.dart';
import 'package:skillcompass_frontend/screens/support_community_screen.dart';
// Yeni içsel engeller ekranını import edelim
import 'package:skillcompass_frontend/screens/inner_obstacles_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kullanıcı verisini çekme fonksiyonu (Değişiklik yok)
  Future<void> _fetchUserData() async {
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
          _isLoading = false;
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

  // Çıkış yapma fonksiyonu (Değişiklik yok)
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
    // Kullanıcı null veya yükleniyor kontrolü (Değişiklik yok)
    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
      });
      return const Scaffold(body: Center(child: Text("Oturum bulunamadı...")));
    }

    // Kullanıcı adını hesapla (Değişiklik yok)
    String userName = 'Kullanıcı';
    if (_userData != null) {
      String firstName = _userData!['firstName'] ?? '';
      userName = firstName.trim();
      if (userName.isEmpty) {
        userName = _currentUser!.email?.split('@')[0] ?? 'Kullanıcı';
      }
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
                /* Hata mesajı */
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Hata: $_errorMessage\nLütfen uygulamayı yeniden başlatın...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
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
                      // Karşılama Mesajı
                      Text(
                        'Hoş Geldin, $userName!',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        'Kariyer Profilini Oluşturmaya Başla:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // --- Kart 1 ---
                      _buildDashboardCard(
                        context: context,
                        title: '1. Sen Kimsin, Nerede Duruyorsun?',
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

                      // --- Kart 2 ---
                      _buildDashboardCard(
                        context: context,
                        title: '2. Ne Biliyorsun, Nerede Uyguladın?',
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

                      // --- Kart 3 ---
                      _buildDashboardCard(
                        context: context,
                        title: '3. Nasıl Düşünüyorsun, Nasıl Öğreniyorsun?',
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

                      // --- Kart 4 ---
                      _buildDashboardCard(
                        context: context,
                        title: '4. Ne Ürettin, Ne Giriştiğin Oldu?',
                        description:
                            'Projelerini, katkılarını ve inisiyatiflerini anlat.',
                        icon: Icons.rocket_launch_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const ProductionInitiativeScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // --- Kart 5 ---
                      _buildDashboardCard(
                        context: context,
                        title: '5. Neyi Hedefliyorsun Gerçekten?',
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

                      // --- Kart 6 ---
                      _buildDashboardCard(
                        context: context,
                        title: '6. Nerede Tıkanıyorsun veya Eksiksin?',
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

                      // --- Kart 7 ---
                      _buildDashboardCard(
                        context: context,
                        title: '7. Destek, Topluluk ve Mentorluk İsteğin',
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

                      // --- YENİ KART: İçsel Engeller ---
                      _buildDashboardCard(
                        context: context,
                        title: '8. Gizli Engellerin, Korkuların, Bahanelerin',
                        description: 'Seni durduran içsel faktörleri keşfet.',
                        icon:
                            Icons.shield_moon_outlined, // Veya Icons.psychology
                        onTap: () {
                          // Yeni içsel engeller ekranına yönlendirme
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const InnerObstaclesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // TODO: Buraya ileride diğer ana kategori kartları eklenebilir
                    ],
                  ),
                ),
              ),
    );
  }

  // Dashboard kartları için yardımcı widget (Değişiklik yok)
  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
              Icon(
                icon,
                size: 36.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
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
}
