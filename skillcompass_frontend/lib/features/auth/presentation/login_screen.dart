import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication paketi
// Kayıt ekranına yönlendirmek için import ediyoruz
import 'package:skillcompass_frontend/features/auth/presentation/registration_screen.dart';
// Başarılı giriş sonrası yönlendirilecek dashboard ekranını import ediyoruz
import 'package:skillcompass_frontend/features/dashboard/presentation/dashboard_screen.dart';
// import 'package:skillcompass_frontend/features/dashboard/presentation/modern_home_screen.dart'; // Bu ekranı artık kullanmıyoruz
// import 'package:skillcompass_frontend/features/dashboard/presentation/home_screen.dart';
// Artık başarılı giriş sonrası HomeScreen'a gitmiyoruz, bu importu silebilir veya yorum satırı yapabilirsiniz
// import 'package:skillcompass_frontend/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart' as my_auth;
import 'package:skillcompass_frontend/core/theme/theme_provider.dart';
import 'package:skillcompass_frontend/core/widgets/custom_text_field.dart';
import 'package:skillcompass_frontend/core/widgets/custom_button.dart';
import 'package:skillcompass_frontend/core/widgets/custom_snackbar.dart';
import 'package:skillcompass_frontend/core/utils/validators.dart';
import 'package:skillcompass_frontend/core/constants/app_constants.dart';
import 'dart:async'; // TimeoutException için gerekli import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Firebase Authentication örneği
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.setLanguageCode('tr');
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (authProvider.isLoggedIn) {
        _showSuccessMessage();
        _navigateToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessMessage() {
    if (!mounted) return;

    CustomSnackBar.show(
      context: context,
      message: 'Giriş başarılı! Yönlendiriliyorsunuz...',
      type: SnackBarType.success,
    );
  }

  void _navigateToDashboard() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _handleFirebaseAuthException(FirebaseAuthException e) {
    if (!mounted) return;

    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'Bu e-posta adresiyle kayıtlı bir kullanıcı bulunamadı.';
        break;
      case 'wrong-password':
        errorMessage = 'Girdiğiniz şifre yanlış.';
        break;
      case 'invalid-email':
        errorMessage = 'Lütfen geçerli bir e-posta adresi girin.';
        break;
      case 'user-disabled':
        errorMessage = 'Bu hesap devre dışı bırakılmış.';
        break;
      case 'too-many-requests':
        errorMessage = 'Çok fazla başarısız giriş denemesi. Lütfen bir süre bekleyin.';
        break;
      case 'network-request-failed':
        errorMessage = 'İnternet bağlantınızı kontrol edin.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'E-posta/şifre girişi devre dışı bırakılmış.';
        break;
      default:
        errorMessage = 'Hata kodu: ${e.code}\nHata mesajı: ${e.message}';
    }

    CustomSnackBar.show(
      context: context,
      message: errorMessage,
      type: SnackBarType.error,
    );

    // Hata detaylarını konsola yazdır
    print('Firebase Auth Hatası:');
    print('Hata Kodu: ${e.code}');
    print('Hata Mesajı: ${e.message}');
    print('Hata Detayları: ${e.toString()}');
  }

  void _handleGenericError(dynamic error) {
    if (!mounted) return;

    String errorMessage;
    if (error is FirebaseException) {
      errorMessage = 'Firebase Hatası:\nKod: ${error.code}\nMesaj: ${error.message}';
    } else if (error is TimeoutException) {
      errorMessage = 'Bağlantı zaman aşımına uğradı.';
    } else {
      errorMessage = 'Beklenmeyen Hata:\n${error.toString()}';
    }

    CustomSnackBar.show(
      context: context,
      message: errorMessage,
      type: SnackBarType.error,
    );

    // Hata detaylarını konsola yazdır
    print('Genel Hata:');
    print('Hata Tipi: ${error.runtimeType}');
    print('Hata Detayları: ${error.toString()}');
    if (error is Error) {
      print('Hata Stack Trace:');
      print(error.stackTrace);
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('Giriş Yap'),
      actions: [
        IconButton(
          icon: Icon(theme.brightness == Brightness.dark 
              ? Icons.light_mode 
              : Icons.dark_mode),
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
          tooltip: 'Tema Değiştir',
        ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.background,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 32),
                    _buildFormFields(theme),
                    const SizedBox(height: 32),
                    _buildButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.login_rounded,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'SkillCompass\'a Hoş Geldiniz',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Hesabınıza giriş yapın ve yeteneklerinizi keşfedin',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields(ThemeData theme) {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          label: 'E-posta',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          label: 'Şifre',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: theme.colorScheme.primary,
            ),
            onPressed: _togglePasswordVisibility,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen şifrenizi girin';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: CustomButton(
            onPressed: _isLoading ? null : _loginUser,
            isLoading: _isLoading,
            text: 'Giriş Yap',
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationScreen(),
                      ),
                    ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Hesabım yok? Kayıt Ol'),
          ),
        ),
      ],
    );
  }
}
