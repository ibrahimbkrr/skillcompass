import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication paketi
// Kayıt ekranına yönlendirmek için import ediyoruz
import 'package:skillcompass_frontend/features/auth/presentation/registration_screen.dart';
// Başarılı giriş sonrası yönlendirilecek Dashboard sayfasını import ediyoruz
import 'package:skillcompass_frontend/features/dashboard/presentation/dashboard_screen.dart'; // Bu satırı ekleyin
// import 'package:skillcompass_frontend/features/dashboard/presentation/home_screen.dart';
// Artık başarılı giriş sonrası HomeScreen'a gitmiyoruz, bu importu silebilir veya yorum satırı yapabilirsiniz
// import 'package:skillcompass_frontend/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:skillcompass_frontend/features/auth/logic/auth_provider.dart' as my_auth;
import 'package:skillcompass_frontend/core/theme/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // E-posta ve şifre için TextField'lardan değer almak üzere Controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form validasyonu için GlobalKey
  final _formKey = GlobalKey<FormState>();

  // Firebase Authentication örneği
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Giriş işlemi için fonksiyon
  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      try {
        final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
        await authProvider.signIn(email, password);
        if (authProvider.isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Giriş başarılı! Yönlendiriliyorsunuz...'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Yanlış şifre.';
        } else {
          errorMessage = 'Bir hata oluştu: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş başarısız: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beklenmeyen bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Controller'ları temizle
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Tema Değiştir',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // TODO: Buraya uygulamanızın logosunu veya başlığını ekleyebilirsiniz
                const SizedBox(height: 48.0),

                // E-posta Giriş Alanı
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-postanızı girin';
                    }
                    // TODO: Daha gelişmiş e-posta format kontrolü eklenebilir
                    return null;
                  },
                ),

                const SizedBox(height: 16.0),

                // Şifre Giriş Alanı
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi girin';
                    }
                    // Firebase giriş için minimum şifre uzunluğu kontrolü genellikle gerekmez,
                    // çünkü bu kontrol kayıt sırasında yapılır. Ancak isterseniz ekleyebilirsiniz.
                    return null;
                  },
                ),

                const SizedBox(height: 24.0),

                // Giriş Butonu
                ElevatedButton(
                  onPressed:
                      _loginUser, // Form validasyonu fonksiyon içinde yapılıyor
                  child: const Text('Giriş Yap'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 16.0),

                // "Hesabım yok" ve kayıt sayfasına yönlendirme butonu
                TextButton(
                  onPressed: () {
                    // Kayıt sayfasına yönlendirme yapılacak
                    print('Kayıt ol butonuna basıldı.');
                    // Navigator.pushReplacement kullanarak mevcut ekranı kaldırıp yeni ekranı ekliyoruz
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationScreen(),
                      ), // const ekledik
                    );
                  },
                  child: const Text('Hesabım yok? Kayıt Ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
