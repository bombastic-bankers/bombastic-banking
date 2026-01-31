import 'package:bombastic_banking/repositories/auth_repository.dart';
import 'package:bombastic_banking/services/session_manager.dart';
import 'package:flutter/material.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final SessionManager _sessionManager;

  String? fullName;
  String? phoneNumber;
  String? email;
  String? pin;

  bool loading = false;

  SignupViewModel({
    required AuthRepository authRepository,
    required SessionManager sessionManager,
  }) : _authRepo = authRepository,
       _sessionManager = sessionManager;

  Future<SignupResult> Signup() async {
    try {
      if (fullName == null ||
          phoneNumber == null ||
          email == null ||
          pin == null) {
        return const SignupFailure('Missing signup information');
      }
      final formattedPhone = phoneNumber!.startsWith('+')
          ? phoneNumber
          : '+65$phoneNumber';
      final success = await _authRepo.signUp(
        fullName!,
        formattedPhone!,
        email!,
        pin!,
      );
      if (success) {
        await _sessionManager.startMonitoring();
        return SignupSuccess();
      } else {
        return SignupFailure('Invalid or used email');
      }
    } catch (e) {
      debugPrint('Error signing up: $e');
      return SignupFailure('An error occurred, please try again');
    } finally {}
  }
}

/// Result type for Signup operations.
sealed class SignupResult {
  const SignupResult();
}

/// Successful Signup.
class SignupSuccess extends SignupResult {
  const SignupSuccess();
}

/// Failed Signup with an error message.
class SignupFailure extends SignupResult {
  final String message;
  const SignupFailure(this.message);
}
