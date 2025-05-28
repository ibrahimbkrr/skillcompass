import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';
import 'package:skillcompass_frontend/features/auth/presentation/login_screen.dart';
import 'package:skillcompass_frontend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:skillcompass_frontend/core/theme/app_theme.dart';
import 'package:skillcompass_frontend/core/theme/theme_provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart' as my_auth;
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.setLanguageCode('tr');

  // Oturumu sıfırla
  final authProvider = my_auth.AuthProvider();
  await authProvider.signOut();

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => authProvider),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SkillCompass',
          theme: AppTheme.lightTheme.copyWith(
            textTheme: GoogleFonts.nunitoTextTheme(),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
          ),
          themeMode: themeProvider.themeMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasData) {
                return const DashboardScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}