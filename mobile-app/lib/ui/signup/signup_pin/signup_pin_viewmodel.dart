import 'package:bombastic_banking/repositories/auth_repository.dart';
import 'package:bombastic_banking/services/session_manager.dart';
import 'package:bombastic_banking/storage/signup_storage.dart';
import 'package:flutter/material.dart';

class SignupPinViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final SessionManager _sessionManager;
  final SignupStorage _signupStorage;

  bool loading = false;

  SignupPinViewModel({
    required AuthRepository authRepository,
    required SessionManager sessionManager,
    required SignupStorage signupStorage,
  }) : _authRepo = authRepository,
       _sessionManager = sessionManager,
       _signupStorage = signupStorage;

  /// Perform signup with the provided PIN
  /// Retrieves signup data from SignupDataService and calls the signup API
  Future<SignupResult> signup(String pin) async {
    loading = true;
    notifyListeners();

    try {
      // Retrieve saved signup data
      final signupData = await _signupStorage.getSignupData();
      if (signupData == null) {
        return const SignupFailure('Signup data not found. Please start over.');
      }

      // Format phone number
      final formattedPhone = signupData.phoneNumber.startsWith('+')
          ? signupData.phoneNumber
          : '+65${signupData.phoneNumber}';

      // Call signup API
      final success = await _authRepo.signUp(
        signupData.fullName,
        formattedPhone,
        signupData.email,
        pin,
      );

      if (success) {
        await _sessionManager.startMonitoring();
        return SignupSuccess(email: signupData.email);
      } else {
        return const SignupFailure('Invalid or used email');
      }
    } catch (e) {
      debugPrint('Error signing up: $e');
      return const SignupFailure('An error occurred, please try again');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

/// Result type for Signup operations.
sealed class SignupResult {
  const SignupResult();
}

/// Successful Signup.
class SignupSuccess extends SignupResult {
  final String email;
  const SignupSuccess({required this.email});
}

/// Failed Signup with an error message.
class SignupFailure extends SignupResult {
  final String message;
  const SignupFailure(this.message);
}
