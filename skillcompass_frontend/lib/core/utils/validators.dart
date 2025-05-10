import 'package:skillcompass_frontend/core/constants/app_constants.dart';

class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur';
    }
    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre zorunludur';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Şifre en az ${AppConstants.minPasswordLength} karakter olmalı';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Şifre en fazla ${AppConstants.maxPasswordLength} karakter olmalı';
    }
    if (!RegExp(AppConstants.passwordRegex).hasMatch(value)) {
      return 'Şifre en az bir harf ve bir rakam içermelidir';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı zorunludur';
    }
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  static String? minLength(String? value, int minLength) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }
    if (value.length < minLength) {
      return 'En az $minLength karakter girilmelidir';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }
    if (value.length > maxLength) {
      return 'En fazla $maxLength karakter girilmelidir';
    }
    return null;
  }
}