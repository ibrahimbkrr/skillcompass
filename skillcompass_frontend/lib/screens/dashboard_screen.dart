import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // For Future.wait
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON handling

// Import necessary screen files
import 'package:skillcompass_frontend/screens/login_screen.dart';
import 'package:skillcompass_frontend/screens/identity_status_screen.dart';
import 'package:skillcompass_frontend/screens/technical_profile_screen.dart';
import 'package:skillcompass_frontend/screens/learning_thinking_style_screen.dart';
import 'package:skillcompass_frontend/screens/career_vision_screen.dart';
import 'package:skillcompass_frontend/screens/blockers_challenges_screen.dart';
import 'package:skillcompass_frontend/screens/support_community_screen.dart';
import 'package:skillcompass_frontend/screens/inner_obstacles_screen.dart';
import 'package:skillcompass_frontend/screens/analysis_report_screen.dart'; // Analysis report screen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  User? _currentUser;
  Map<String, dynamic>? _userData; // Basic user info (name, etc.)
  bool _isLoading = true; // Is the page loading?
  String _errorMessage = ''; // Error message
  bool _isAnalyzing = false; // Is analysis in progress?
  bool _hasAnalysisReport = false; // TODO: Check if analysis report exists

  // Backend API URL (Replace with your actual backend URL)
  final String _backendBaseUrl = 'http://192.168.1.111:8000';
  // For Android emulator accessing localhost

  // Firestore Document Names (for profile sections)
  // Keep these synchronized with the document names used in each profile screen
  final Map<String, String> _profileDocNames = {
    'identity': 'identity_status_v3',
    'technical': 'technical_profile_v4',
    'learning': 'learning_thinking_style_v2',
    'vision': 'career_vision_v5',
    'blockers': 'blockers_challenges_v3',
    'support': 'support_community_v2',
    'obstacles': 'inner_obstacles_v2',
  };

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserData(); // Fetch basic user data on init
      // TODO: Implement _checkAnalysisStatus() to see if a report already exists
    } else {
      // If user is null in initState, build method will handle redirection
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetches basic user data (like name) from the 'users' collection
  Future<void> _fetchUserData() async {
    if (!mounted) return; // Don't do anything if the widget is disposed
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
          _isLoading = false; // Basic data fetched, stop loading indicator
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Kullanıcı profil bilgileri bulunamadı.'; // User profile info not found
        });
      }
    } catch (e) {
      print(
        'HATA: Firestore kullanıcı verisi çekme hatası: $e',
      ); // Error fetching user data
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Bilgiler yüklenirken bir hata oluştu.'; // Error occurred while loading info
        });
      }
    }
  }

  // --- Fetches all profile data from the subcollection ---
  // This function is now handled by the backend in the /analyze endpoint
  // Future<Map<String, dynamic>> _fetchAllProfileData() async { ... }
  // ---------------------------------------------------------

  // --- Starts the analysis process by calling the backend ---
  Future<void> _startAnalysis() async {
    if (_isAnalyzing || _currentUser == null)
      return; // Prevent multiple analyses or if user is null
    if (!mounted) return;

    print(
      "[DEBUG] _startAnalysis fonksiyonu başladı (Backend isteği).",
    ); // Starting analysis (backend request)
    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
    }); // Start analysis state

    // Construct the backend endpoint URL
    final Uri analyzeUrl = Uri.parse(
      '$_backendBaseUrl/users/${_currentUser!.uid}/analyze',
    );
    print("[DEBUG] İstek gönderilecek URL: $analyzeUrl"); // URL to send request

    try {
      print(
        '[DEBUG] Backend\'e POST isteği gönderiliyor...',
      ); // Sending POST request to backend

      // Send POST request to the backend
      // The backend will fetch data from Firestore itself
      final response = await http
          .post(
            analyzeUrl,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            // No body needed as backend fetches data based on user_id in URL
          )
          .timeout(
            const Duration(seconds: 90),
          ); // Increase timeout for potentially long analysis

      print(
        '[DEBUG] Backend yanıtı alındı. Status Code: ${response.statusCode}',
      ); // Received backend response

      if (mounted) {
        // Check if widget is still mounted
        if (response.statusCode == 200) {
          // Successful response
          final responseBody = jsonDecode(
            utf8.decode(response.bodyBytes),
          ); // Decode response body for Turkish characters
          // --- Extract only the analysis report text ---
          final String analysisReportText =
              responseBody['analysis_report'] ??
              'Analiz raporu alınamadı veya boş.'; // Analysis report couldn't be retrieved or is empty
          print(
            "[DEBUG] Analiz sonucu başarıyla alındı.",
          ); // Analysis result received successfully

          // --- CORRECTED NAVIGATOR CALL ---
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AnalysisReportScreen(
                    // Pass only the analysisReportText parameter
                    analysisReportText: analysisReportText,
                  ),
            ),
          );
          // ------------------------------------
          // TODO: Update report status in Firestore and state
          // setState(() { _hasAnalysisReport = true; });
        } else {
          // Error response from backend
          print(
            '[DEBUG] Backend Hata Yanıtı: ${response.body}',
          ); // Backend Error Response
          String errorDetail =
              'Bilinmeyen bir backend hatası oluştu.'; // Unknown backend error occurred
          try {
            final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
            errorDetail = responseBody['detail'] ?? errorDetail;
          } catch (e) {
            errorDetail = response.body;
          } // Show raw body if JSON parsing fails
          _showFeedback(
            'Analiz başarısız: $errorDetail (Kod: ${response.statusCode})',
            isError: true,
          ); // Analysis failed
        }
      }
    } catch (e) {
      // Network or other errors during the request
      print(
        '[DEBUG] HATA: Backend isteği sırasında hata: $e',
      ); // Error during backend request
      if (mounted) {
        _showFeedback(
          'Analiz sırasında bir bağlantı hatası veya başka bir sorun oluştu: ${e.toString()}',
          isError: true,
        ); // Connection error or other issue during analysis
      }
    } finally {
      print(
        "[DEBUG] _startAnalysis fonksiyonu bitti.",
      ); // _startAnalysis function finished
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      } // End analysis state
    }
  }
  // ------------------------------------

  // --- Shows feedback using SnackBar ---
  void _showFeedback(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).removeCurrentSnackBar(); // Remove previous snackbar if any
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating, // Modern look
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 4), // Show longer
      ),
    );
  }
  // ------------------------------------

  // --- Sign out function ---
  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      // Navigate to LoginScreen and remove all previous routes
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

    // Handle user null state after loading attempt
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
      ); // Redirecting session...
    }

    // Calculate user name for display
    String userName = 'Kullanıcı'; // Default user name
    if (_userData != null) {
      String firstName = _userData!['firstName'] ?? '';
      userName =
          firstName.trim().isNotEmpty
              ? firstName.trim()
              : (_currentUser!.email?.split('@')[0] ?? 'Kullanıcı');
    } else if (!_isLoading && _currentUser != null) {
      // If loading finished and user exists but no user data
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
        ], // Sign out button
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : _errorMessage.isNotEmpty
              ? Center(
                // Show error message and refresh button
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hata: $_errorMessage\nLütfen sayfayı yenileyin.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ), // Please refresh the page
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Yenile"),
                        onPressed: _fetchUserData,
                      ), // Refresh button
                    ],
                  ),
                ),
              )
              : RefreshIndicator(
                // Allow pull-to-refresh
                onRefresh: _fetchUserData,
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Ensure scrolling even if content fits
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Welcome Message
                      Text(
                        'Hoş Geldin, $userName!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ), // Welcome, [userName]!
                      const SizedBox(height: 24.0),
                      Text(
                        'Kariyer Profilini Oluştur:',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ), // Start Building Your Career Profile:
                      const SizedBox(height: 16.0),

                      // --- Profile Cards (1-7 with correct titles and navigation) ---
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
                        title: '7. İçsel Faktörler',
                        description: 'Seni durduran korkular ve bahaneler.',
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

                      // Analysis Card
                      _buildAnalysisCard(context, colorScheme),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
    );
  }

  // --- Helper Widget for Analysis Card ---
  Widget _buildAnalysisCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color:
          colorScheme
              .primaryContainer, // Use primary container color for emphasis
      child: InkWell(
        onTap:
            _isAnalyzing || _hasAnalysisReport
                ? () {
                  // If analyzing or report exists
                  if (_hasAnalysisReport && mounted) {
                    // TODO: Fetch the actual report text from Firestore or state
                    // For now, navigates to report screen (might show old/no data)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const AnalysisReportScreen(
                              analysisReportText: "Önceki Rapor...",
                            ),
                      ),
                    ); // Placeholder text
                    print(
                      "TODO: Gösterilecek rapor verisi alınmalı.",
                    ); // Report data to be shown should be fetched
                  }
                  // If analyzing, tap does nothing
                }
                : _startAnalysis, // If no analysis ongoing and no report, start analysis
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                _isAnalyzing
                    ? [
                      // While analyzing
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
                      ), // Analyzing...
                    ]
                    : [
                      // Before/After analysis
                      Icon(
                        _hasAnalysisReport
                            ? Icons.description_outlined
                            : Icons.insights_rounded,
                        size: 30.0,
                        color: colorScheme.onPrimaryContainer,
                      ), // Icon based on report status
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
                      ), // View Report / Start Analysis & See Roadmap
                    ],
          ),
        ),
      ),
    );
  }
  // ---------------------------------------------------

  // --- Helper Widget for Profile Dashboard Cards ---
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
      clipBehavior: Clip.antiAlias, // Prevents InkWell splash overflow
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: 36.0,
                color: theme.colorScheme.primary,
              ), // Card icon
              const SizedBox(width: 16.0),
              Expanded(
                // Ensure text takes available space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Card title
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ), // Card description
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16.0,
              ), // Navigation arrow
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
}
