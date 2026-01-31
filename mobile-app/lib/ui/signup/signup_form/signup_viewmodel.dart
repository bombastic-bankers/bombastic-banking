import 'package:bombastic_banking/storage/signup_storage.dart';
import 'package:flutter/material.dart';

class SignupViewModel extends ChangeNotifier {
  final SignupStorage _signupStorage;

  String? fullName;
  String? phoneNumber;
  String? email;

  bool loading = false;

  SignupViewModel({required SignupStorage signupStorage})
    : _signupStorage = signupStorage;

  /// Save signup form data to SharedPreferences
  Future<void> saveSignupData() async {
    if (fullName == null || phoneNumber == null || email == null) {
      debugPrint('Cannot save incomplete signup data');
      return;
    }

    loading = true;
    notifyListeners();

    try {
      await _signupStorage.saveSignupData(
        fullName: fullName!,
        email: email!,
        phoneNumber: phoneNumber!,
      );
    } catch (e) {
      debugPrint('Error saving signup data: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
