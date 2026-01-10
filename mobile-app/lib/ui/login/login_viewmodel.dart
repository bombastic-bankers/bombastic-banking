import 'package:bombastic_banking/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  bool loading = false;
  String? errorMessage;
  final AuthRepository _authRepo;

  LoginViewModel({required AuthRepository authRepository})
    : _authRepo = authRepository;

  Future<bool> login(String email, String pin) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepo.login(email, pin);
      if (!result) {
        errorMessage = 'Incorrect email or PIN';
      }
      return result;
    } catch (e) {
      errorMessage = 'An error occurred. Please try again.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
