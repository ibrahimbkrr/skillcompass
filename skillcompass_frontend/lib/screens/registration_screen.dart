import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Firestore paketini import edelim
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillcompass_frontend/screens/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // --- YENİ: Ad ve Soyad için Controller'lar eklendi ---
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  // Mevcut Controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // --- YENİ: Firestore örneği eklendi ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kayıt işlemi için fonksiyonu güncelleyelim
  void _registerUser() async {
    // Form geçerliliğini kontrol et
    if (!_formKey.currentState!.validate()) {
      return; // Form geçerli değilse işlemi durdur
    }

    // Yükleniyor durumu için (opsiyonel, istersen eklersin)
    // setState(() { _isLoading = true; });

    try {
      // Formdan değerleri al
      // --- YENİ: Ad ve Soyad controller'dan alınıyor ---
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // 1. Firebase Authentication ile kullanıcı oluştur
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        print('Firebase Auth kullanıcısı oluşturuldu: ${user.uid}');

        // --- YENİ: Firestore'a ek kullanıcı bilgilerini kaydetme ---
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'createdAt': Timestamp.now(), // Kayıt zamanı
            'uid': user.uid, // Kullanıcı ID'si
          });
          print('Firestore kullanıcı verisi başarıyla kaydedildi.');
        } catch (firestoreError) {
          print(
            'HATA: Firestore kaydı sırasında sorun oluştu: $firestoreError',
          );
          // Kullanıcıya bilgi verilebilir veya sadece loglanabilir.
          // Şimdilik sadece logluyoruz ama Auth işlemi başarılı olduğu için devam ediyoruz.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Profil bilgileri kaydedilemedi, ancak kayıt tamamlandı.',
                ),
                backgroundColor: Colors.orangeAccent,
              ),
            );
          }
        }
        // --- Firestore Kayıt Kodu Sonu ---

        // Başarı mesajı ve yönlendirme (Mevcut kod)
        if (mounted) {
          // Widget hala ağaçta mı kontrolü
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        // Kullanıcı null döndü durumu (Mevcut kod)
        print('Kayıt sırasında bir hata oluştu (user null).');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt sırasında bir hata oluştu (user null).'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Firebase Auth hataları (Mevcut kod, sadece hata mesajını güncelledim)
      print('Auth Hatası: ${e.code} - ${e.message}');
      String errorMessage = 'Bir hata oluştu.';
      if (e.code == 'weak-password') {
        errorMessage = 'Şifre çok zayıf.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
      } else {
        errorMessage = 'Kayıt sırasında bir hata oluştu: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Diğer genel hatalar (Mevcut kod)
      print('Genel Kayıt Hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beklenmeyen bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Yükleniyor durumu kapat (opsiyonel)
      // if (mounted) {
      //   setState(() { _isLoading = false; });
      // }
    }
  }

  @override
  void dispose() {
    // --- YENİ: Yeni controller'ları da dispose edelim ---
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 48.0), // Üst boşluk
                // --- YENİ: Ad Giriş Alanı ---
                TextFormField(
                  controller: _firstNameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Ad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline), // İkon (opsiyonel)
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      // trim() ile boşluk kontrolü
                      return 'Lütfen adınızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // --- YENİ: Soyad Giriş Alanı ---
                TextFormField(
                  controller: _lastNameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Soyad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline), // İkon (opsiyonel)
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      // trim() ile boşluk kontrolü
                      return 'Lütfen soyadınızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // E-posta Giriş Alanı (Mevcut kod)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined), // İkon (opsiyonel)
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen e-postanızı girin';
                    }
                    // Basit e-posta format kontrolü
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Lütfen geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Şifre Giriş Alanı (Mevcut kod)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline), // İkon (opsiyonel)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi girin';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Kayıt Butonu (Mevcut kod)
                ElevatedButton(
                  onPressed: _registerUser, // Direkt fonksiyonu çağır
                  child: const Text('Kayıt Ol'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Giriş Yap Butonu (Mevcut kod)
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Zaten hesabım var? Giriş Yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
