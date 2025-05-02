// Gerekli paketleri import ediyoruz
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// firebase_options dosyasını import ediyoruz (flutterfire configure komutunun oluşturduğu dosya)
import 'firebase_options.dart';

// Oluşturduğumuz ekranları import ediyoruz
import 'package:skillcompass_frontend/screens/registration_screen.dart'; // Kayıt ekranını import ettik
import 'package:skillcompass_frontend/screens/login_screen.dart'; // Giriş ekranını import ettik

// Uygulamanın başlangıç noktası olan main fonksiyonu
// async anahtar kelimesini ekliyoruz çünkü Firebase başlatma işlemi asenkrondur (await kullanacağız)
void main() async {
  // Flutter motorunun widget binding'lerinin başlatıldığından emin oluyoruz.
  // Firebase gibi native kodlarla etkileşime geçen eklentiler için bu gereklidir.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i projemiz için başlatıyoruz.
  // flutter_options.dart dosyasındaki platforma özel seçenekleri kullanıyoruz.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Uygulamayı başlatıyoruz.
  runApp(const MyApp());
}

// Uygulamamızın temel widget'ı
// Genellikle StatelessWidget veya StatefulWidget olur
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillCompass Frontend', // Uygulamanın başlığı
      theme: ThemeData(
        primarySwatch: Colors.blue, // Uygulamanın ana renk teması
        // Diğer tema ayarları buraya eklenebilir
      ),
      // Uygulamanın ilk açılacak sayfası Giriş Ekranı olarak ayarlandı
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false, // Debug bandını kaldırmak için
    );
  }
}

// Not: MyHomePage widget'ı hala dosyanın altında durabilir ama şu an kullanılmayacak.
// İsterseniz silebilirsiniz veya ileride tekrar kullanmak üzere bırakabilirsiniz.
// class MyHomePage extends StatefulWidget { ... }
// class _MyHomePageState extends State<MyHomePage> { ... }
