class AppConstants {
  // Uygulama genelinde kullanılacak sabitler
  static const String appName = 'SkillCompass';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String skillsCollection = 'skills';
  static const String progressCollection = 'progress';
  static const String recommendationsCollection = 'recommendations';

  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String userKey = 'user_data';
  static const String lastAnalysisKey = 'last_analysis';

  // API Endpoints
  static const String baseUrl = 'http://192.168.1.110:8000';
  static const String apiVersion = 'v1';
  static const String analysisEndpoint = '/analysis';
  static const String skillsEndpoint = '/skills';
  static const String progressEndpoint = '/progress';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const String emailRegex = r'\S+@\S+\.\S+';
  static const String passwordRegex = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultIconSize = 24.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Error Messages
  static const String genericErrorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String networkErrorMessage = 'İnternet bağlantınızı kontrol edin.';
  
  // Firebase Error Messages
  static const String userNotFound = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
  static const String wrongPassword = 'Yanlış şifre.';
  static const String invalidEmail = 'Geçersiz e-posta adresi.';
}