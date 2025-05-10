import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillcompass_frontend/features/auth/presentation/login_screen.dart';
import 'package:skillcompass_frontend/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/core/widgets/custom_text_field.dart';
import 'package:skillcompass_frontend/core/widgets/custom_button.dart';
import 'package:skillcompass_frontend/core/widgets/custom_snackbar.dart';
import 'package:skillcompass_frontend/core/constants/app_constants.dart';
import 'package:skillcompass_frontend/core/utils/validators.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userData = await _createUserAccount();
      if (userData != null) {
        await _saveUserDataToFirestore(userData);
        _showSuccessMessage();
        _navigateToLoginScreen();
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

  Future<UserCredential?> _createUserAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> _saveUserDataToFirestore(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user == null) return;

    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'createdAt': Timestamp.now(),
      'uid': user.uid,
    });
  }

  void _showSuccessMessage() {
    if (!mounted) return;
    
    CustomSnackBar.show(
      context: context,
      message: 'Kayıt başarılı! Giriş yapabilirsiniz.',
      type: SnackBarType.success,
    );
  }

  void _navigateToLoginScreen() {
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _handleFirebaseAuthException(FirebaseAuthException e) {
    if (!mounted) return;

    String errorMessage;
    switch (e.code) {
      case 'weak-password':
        errorMessage = 'Şifre çok zayıf.';
        break;
      case 'email-already-in-use':
        errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
        break;
      default:
        errorMessage = 'Kayıt sırasında bir hata oluştu: ${e.message}';
    }

    CustomSnackBar.show(
      context: context,
      message: errorMessage,
      type: SnackBarType.error,
    );
  }

  void _handleGenericError(dynamic error) {
    if (!mounted) return;

    CustomSnackBar.show(
      context: context,
      message: 'Beklenmeyen bir hata oluştu: $error',
      type: SnackBarType.error,
    );
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
      title: const Text('Kayıt Ol'),
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
          Icons.person_add_rounded,
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
          'Hesabınızı oluşturun ve yeteneklerinizi keşfedin',
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
          controller: _firstNameController,
          label: 'Ad',
          icon: Icons.person_outline,
          validator: Validators.required,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _lastNameController,
          label: 'Soyad',
          icon: Icons.person_outline,
          validator: Validators.required,
        ),
        const SizedBox(height: 16),
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
          validator: Validators.password,
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        CustomButton(
          onPressed: _isLoading ? null : _registerUser,
          isLoading: _isLoading,
          text: 'Kayıt Ol',
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
          child: const Text('Zaten hesabım var? Giriş Yap'),
        ),
      ],
    );
  }
}
