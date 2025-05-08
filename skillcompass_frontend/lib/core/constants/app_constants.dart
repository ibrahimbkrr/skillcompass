class AppConstants {
  // Uygulama genelinde kullanılacak sabitler
  static const String appName = 'SkillCompass';
  
  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  
  // Error Messages
  static const String genericErrorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String networkErrorMessage = 'İnternet bağlantınızı kontrol edin.';
  
  // Firebase Error Messages
  static const String userNotFound = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
  static const String wrongPassword = 'Yanlış şifre.';
  static const String invalidEmail = 'Geçersiz e-posta adresi.';
}