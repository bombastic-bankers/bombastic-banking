import 'package:bombastic_banking/repositories/auth_repository.dart';
import 'package:bombastic_banking/services/biometric_service.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  bool loading = false;

  /// Whether the user can log in with biometrics.
  bool canUseBiometrics = false;

  LoginViewModel({required AuthRepository authRepository})
    : _authRepo = authRepository;

  /// Updates [canUseBiometrics].
  Future<void> checkBiometricAvailability() async {
    canUseBiometrics = await _authRepo.canUseBiometrics();
    notifyListeners();
  }

  Future<LoginResult> login(String email, String pin) async {
    loading = true;
    notifyListeners();

    try {
      return await _authRepo.login(email, pin)
          ? const LoginSuccess()
          : const LoginFailure('Incorrect email or PIN');
    } catch (e) {
      return const LoginFailure('An error occurred. Please try again.');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Attempt to login using biometrics. [checkBiometricAvailability] should be called before this.
  Future<LoginResult> loginWithBiometrics() async {
    final refreshToken = await _authRepo.getRefreshToken();
    if (refreshToken == null) {
      return const LoginFailure('No saved credentials found');
    }

    final biometricResult = await _authRepo.verifyBiometrics();

    switch (biometricResult) {
      case BiometricSuccess():
        // Continue with login
        break;
      case BiometricCancelled():
        return const LoginCancelled();
      case BiometricFailure():
        return const LoginFailure('Biometric verification failed');
    }

    loading = true;
    notifyListeners();

    try {
      return await _authRepo.loginWithRefreshToken(refreshToken)
          ? const LoginSuccess()
          : const LoginFailure('Session expired. Please login again.');
    } catch (e) {
      return const LoginFailure('An error occurred. Please try again.');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

/// Result type for login operations.
sealed class LoginResult {
  const LoginResult();
}

/// Successful login.
class LoginSuccess extends LoginResult {
  const LoginSuccess();
}

/// Failed login with an error message.
class LoginFailure extends LoginResult {
  final String message;
  const LoginFailure(this.message);
}

/// Cancelled login attempt.
class LoginCancelled extends LoginResult {
  const LoginCancelled();
}
