// Gerekli paketleri import ediyoruz
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart';
import 'package:skillcompass_frontend/features/profile/logic/user_provider.dart';

// firebase_options dosyasını import ediyoruz
import 'firebase_options.dart';

// Oluşturduğumuz ekranları import ediyoruz
import 'package:skillcompass_frontend/features/auth/presentation/registration_screen.dart';
import 'package:skillcompass_frontend/features/auth/presentation/login_screen.dart';

// Yeni tema yapısını import ediyoruz
import 'package:skillcompass_frontend/core/theme/app_theme.dart';
import 'package:skillcompass_frontend/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'SkillCompass Frontend',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}