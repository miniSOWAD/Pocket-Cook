import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'app_exception.dart';

String userMessage(Object error) {
  if (error is AppException) return error.message;
  if (error is TimeoutException) {
    return 'The save could not be confirmed yet. Check your connection; '
        'changes may still sync. Review the list before retrying.';
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'invalid-credential' || 'user-not-found' || 'wrong-password' =>
        'The email or password is incorrect.',
      'email-already-in-use' => 'An account already uses this email.',
      'invalid-email' => 'Enter a valid email address.',
      'weak-password' => 'Use a stronger password with at least 8 characters.',
      'network-request-failed' || 'unavailable' =>
        'Check your internet connection and try again.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'permission-denied' => 'You do not have access. Check your sign-in and Firebase rules.',
      'operation-not-allowed' => 'Enable Email/Password sign-in in Firebase Authentication.',
      'failed-precondition' => 'The database needs configuration. Check the setup guide.',
      _ => 'The service could not complete that action. Please try again.',
    };
  }
  if (error is FormatException) return 'Some saved data is invalid. Check the data format.';
  return 'Something went wrong. Please try again.';
}
