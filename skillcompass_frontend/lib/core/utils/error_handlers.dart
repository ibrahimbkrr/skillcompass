import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';

class ErrorHandler {
  static String handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AppConstants.userNotFound;
      case 'wrong-password':
        return AppConstants.wrongPassword;
      case 'invalid-email':
        return AppConstants.invalidEmail;
      default:
        return AppConstants.genericErrorMessage;
    }
  }

  static String handleGenericError(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleFirebaseAuthError(error);
    }
    return AppConstants.genericErrorMessage;
  }
}