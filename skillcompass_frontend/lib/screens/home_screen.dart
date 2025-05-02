import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Kullanıcının UID'sini almak için
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore'dan veri çekmek ve kaydetmek için
import 'package:skillcompass_frontend/screens/login_screen.dart'; // Çıkış yaptıktan sonra yönlendirmek için
import 'package:intl/intl.dart'; // Tarih formatlamak için (pubspec.yaml'a intl paketi eklenmeli)

// intl paketini eklemek için terminalde: flutter pub add intl

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Kullanıcı verilerini tutacak değişken
  Map<String, dynamic>? _userData;
  // Veri yükleniyor mu durumu
  bool _isLoading = true;
  // Hata durumu
  String? _error;

  // Form alanları için TextEditingController'lar
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _workExperienceController =
      TextEditingController();
  final TextEditingController _skillsController =
      TextEditingController(); // Şimdilik basit metin
  final TextEditingController _goalsController = TextEditingController();
  // YENİ EKLENEN CONTROLLER/STATE'LER
  final TextEditingController _birthDateController =
      TextEditingController(); // Doğum tarihi için (göstermek ve seçiciyi tetiklemek için)
  String? _selectedGender; // Cinsiyet için seçilen değer

  // Cinsiyet seçenekleri
  final List<String> _genderOptions = [
    'Erkek',
    'Kadın',
    'Belirtmek İstemiyorum',
  ];

  // Oturum açmış kullanıcıyı alıyoruz
  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Ekran ilk yüklendiğinde kullanıcı verisini çek
    _fetchUserData();
  }

  @override
  void dispose() {
    // Controller'ları temizlemeyi unutmayın
    _nameController.dispose();
    _educationController.dispose();
    _workExperienceController.dispose();
    _skillsController.dispose();
    _goalsController.dispose();
    // YENİ EKLENEN CONTROLLER'LARI DISPOSE EDİN
    _birthDateController.dispose();
    super.dispose();
  }

  // Tarih seçiciyi gösterme fonksiyonu
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Başlangıç tarihi
      firstDate: DateTime(1900), // Seçilebilecek en eski tarih
      lastDate: DateTime.now(), // Seçilebilecek en yeni tarih (bugün)
    );
    if (picked != null) {
      // Seçilen tarihi formatlayıp controller'a ata
      final String formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(picked); // 'intl' paketi gerekli
      _birthDateController.text = formattedDate;
    }
  }

  // Firestore'dan kullanıcı verisini çekme fonksiyonu
  Future<void> _fetchUserData() async {
    // Eğer oturum açmış kullanıcı yoksa işlemi durdur
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _error = "Kullanıcı oturumu açık değil.";
      });
      // Kullanıcı giriş yapmamışsa giriş ekranına yönlendirme yapabilirsiniz
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return;
    }

    try {
      // Firestore örneğini al
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 'users' koleksiyonundaki mevcut kullanıcının UID'si ile eşleşen belgeyi çek
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(currentUser!.uid).get();

      // Belge varsa veriyi al ve state'i güncelle
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
          _isLoading = false;
          _error = null; // Başarılı olursa hatayı temizle

          // Eğer veri varsa, form controller'larını/state'leri mevcut veri ile doldur
          if (_userData != null) {
            _nameController.text = _userData!['name'] ?? '';
            _educationController.text = _userData!['education'] ?? '';
            _workExperienceController.text = _userData!['workExperience'] ?? '';
            _skillsController.text = _userData!['skills'] ?? '';
            _goalsController.text = _userData!['goals'] ?? '';
            // YENİ EKLENEN ALANLARI DOLDURUN
            _birthDateController.text =
                _userData!['birthDate'] ??
                ''; // Tarih string olarak saklanıyorsa
            _selectedGender =
                _userData!['gender']; // String olarak saklanıyorsa
            // TODO: Diğer alanları da mevcut veri ile doldurun (sertifikalar, diller vb.)
          }
        });
        print('Firestore\'dan kullanıcı verisi başarıyla çekildi.');
        print('Veri: $_userData');
      } else {
        // Belge yoksa
        setState(() {
          _isLoading = false;
          _userData = null; // Veri yok
          _error = null; // Hata yok, sadece veri eksik
        });
        print('Firestore\'da kullanıcı profili bulunamadı. Form gösterilecek.');
      }
    } catch (e) {
      // Veri çekme sırasında bir hata oluşursa
      setState(() {
        _isLoading = false;
        _userData = null;
        _error = "Veri çekme hatası: ${e.toString()}"; // Hata mesajını kaydet
      });
      print('Firestore\'dan veri çekerken hata oluştu: $e');
    }
  }

  // Kullanıcı verisini Firestore'a kaydetme fonksiyonu
  Future<void> _saveUserData() async {
    if (currentUser == null) {
      // Kullanıcı oturumu açık değilse kaydetme
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı oturumu açık değil, kaydedilemedi.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Form validasyonu (isteğe bağlı, form widget'ı kullanılıyorsa)
    // if (!_formKey.currentState!.validate()) { return; }

    setState(() {
      _isLoading = true; // Kaydetme sırasında yükleniyor göster
      _error = null;
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Kaydedilecek veri haritasını oluştur
      Map<String, dynamic> dataToSave = {
        'name': _nameController.text.trim(),
        'education': _educationController.text.trim(),
        'workExperience': _workExperienceController.text.trim(),
        'skills': _skillsController.text.trim(),
        'goals': _goalsController.text.trim(),
        // YENİ EKLENEN ALANLARDAN ALINAN VERİLERİ BURAYA EKLEYİN
        'birthDate':
            _birthDateController.text
                .trim(), // Doğum tarihi string olarak kaydediliyor
        'gender': _selectedGender, // Cinsiyet string olarak kaydediliyor
        // TODO: Diğer form alanlarından alınan verileri buraya ekleyin (sertifikalar, diller vb.)
        // Eğer beceriler veya sertifikalar gibi alanlar liste ise, controller'dan alıp listeye dönüştürmeniz gerekebilir.
        // Örneğin: 'certificates': _certificatesList,
      };

      // Mevcut kullanıcının UID'si ile 'users' koleksiyonuna veriyi kaydet
      // set metodu belge yoksa oluşturur, varsa üzerine yazar
      await firestore.collection('users').doc(currentUser!.uid).set(dataToSave);

      setState(() {
        _isLoading = false; // Yükleniyor durumunu kapat
        _userData = dataToSave; // Kaydedilen veriyi state'e yansıt
      });

      print('Kullanıcı verisi başarıyla kaydedildi.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil bilgileri kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false; // Yükleniyor durumunu kapat
        _error =
            "Veri kaydetme hatası: ${e.toString()}"; // Hata mesajını kaydet
      });
      print('Firestore\'a veri kaydederken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil bilgileri kaydedilemedi: $_error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Eğer oturum açmış kullanıcı yoksa (bu kontrol initState'te de var ama build'de de olabilir)
    if (currentUser == null) {
      // Kullanıcı giriş yapmamışsa giriş ekranına yönlendirme yapabilirsiniz
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ); // Yönlendirme olana kadar yükleniyor göster
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Firebase oturumunu kapat
              // Çıkış yaptıktan sonra giriş ekranına yönlendirme
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading // Veri yükleniyor mu veya kaydediliyor mu?
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Yükleniyorsa spinner göster
              : _error !=
                  null // Hata oluştu mu?
              ? Center(
                // Hata varsa hata mesajını göster
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Hata: $_error',
                    style: const TextStyle(fontSize: 18.0, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : SingleChildScrollView(
                // İçerik taşarsa kaydırmak için
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Üstten başla
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // Yatayda genişle
                  children: <Widget>[
                    const Text(
                      'Hoş Geldiniz!',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Kullanıcının e-postasını gösterelim (Firebase Auth'tan alıyoruz)
                    Text(
                      'E-posta: ${currentUser!.email ?? "Bilgi Yok"}',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 24.0),

                    // Eğer _userData null ise (Firestore'da belge yoksa) formu göster
                    _userData == null
                        ? Column(
                          // Form alanlarını içeren Column
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Profilinizi Tamamlayın:',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            // Ad Soyad Giriş Alanı
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Ad Soyad',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            // Doğum Tarihi Giriş Alanı (Tarih Seçici ile)
                            TextFormField(
                              controller: _birthDateController,
                              readOnly: true, // Klavyeyle girişi engelle
                              decoration: InputDecoration(
                                labelText: 'Doğum Tarihi',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  // Sağ tarafa takvim ikonu ekle
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed:
                                      () => _selectDate(
                                        context,
                                      ), // İkona basınca tarih seçiciyi aç
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            // Cinsiyet Seçim Alanı (Dropdown ile)
                            DropdownButtonFormField<String>(
                              value: _selectedGender, // Seçili değeri tutar
                              decoration: const InputDecoration(
                                labelText: 'Cinsiyet',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text(
                                'Cinsiyet Seçin',
                              ), // Seçim yapılmadan önce görünen yazı
                              items:
                                  _genderOptions.map((String gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender =
                                      newValue; // Seçilen değeri state'e ata
                                });
                              },
                            ),
                            const SizedBox(height: 16.0),
                            // Eğitim Giriş Alanı
                            TextFormField(
                              controller: _educationController,
                              decoration: const InputDecoration(
                                labelText:
                                    'Eğitim Bilgisi (Lisans, Yüksek Lisans vb.)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              // İş Deneyimi
                              controller: _workExperienceController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText:
                                    'İş Deneyimi (Pozisyonlar, Şirketler, Süreler)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              // Beceriler
                              controller: _skillsController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Beceriler (Virgülle Ayırarak)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              // Kariyer Hedefleri
                              controller: _goalsController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Kariyer Hedefleriniz',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            // TODO: Proje raporundaki diğer alanlar için form widget'ları ekleyin (sertifikalar, diller vb.)
                            // Sertifikalar ve diller için liste yönetimi gerektiren daha gelişmiş widget'lar düşünülebilir.
                            const SizedBox(height: 24.0),
                            // Kaydet Butonu
                            ElevatedButton(
                              onPressed:
                                  _saveUserData, // Kaydetme fonksiyonunu çağır
                              child: const Text('Profil Bilgilerini Kaydet'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        )
                        // Eğer _userData doluysa (Firestore'da belge varsa) verileri göster
                        : Column(
                          // Verileri gösteren Column
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kariyer ve Yetenek Bilgileriniz:',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            // Firestore'dan çekilen veriyi burada gösteriyoruz
                            if (_userData != null) ...[
                              // _userData null değilse bu widget'ları göster
                              Text(
                                'Ad Soyad: ${_userData!['name'] ?? "Belirtilmemiş"}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                // Doğum Tarihi verisini göster
                                'Doğum Tarihi: ${_userData!['birthDate'] ?? "Belirtilmemiş"}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                // Cinsiyet verisini göster
                                'Cinsiyet: ${_userData!['gender'] ?? "Belirtilmemiş"}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Eğitim: ${_userData!['education'] ?? "Belirtilmemiş"}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                // İş Deneyimi verisini göster
                                'İş Deneyimi: ${_userData!['workExperience'] ?? "Belirtilmemiş"}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                // Beceriler verisini göster
                                'Beceriler: ${_userData!['skills'] ?? "Belirtilmemiş"}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                // Kariyer Hedefleri verisini göster
                                'Kariyer Hedefleri: ${_userData!['goals'] ?? "Belirtilmemiş"}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              // TODO: Firestore'dan çekilen diğer verileri burada gösterin
                              // Eğer beceriler veya sertifikalar liste olarak saklanıyorsa, bunları listelemek için ListView.builder gibi bir widget kullanmanız gerekebilir.
                            ],
                            // Eğer _userData boşsa (Firestore belgesi var ama içi boşsa)
                            if (_userData != null && _userData!.isEmpty)
                              const Text(
                                'Profil verisi boş. Lütfen profilinizi tamamlayın.',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.orange,
                                ),
                              ),
                            const SizedBox(height: 24.0),
                            // TODO: Buraya "Profili Düzenle" butonu eklenebilir
                            // Bu butona basıldığında form alanları tekrar görünür hale getirilebilir ve mevcut verilerle doldurulabilir.
                            // Bu, _userData != null iken formun görünmesini sağlayacak bir state değişkeni (örneğin bool _isEditing) ile yapılabilir.
                          ],
                        ),
                  ],
                ),
              ),
    );
  }
}

// Not: LoginScreen'ı kullanmak için import etmeniz gerekebilir.
// import 'package:skillcompass_frontend/screens/login_screen.dart';
// Tarih formatlamak için intl paketi pubspec.yaml'a eklenmeli ve import edilmeli.
// import 'package:intl/intl.dart';
