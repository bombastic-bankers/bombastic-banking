import 'package:bombastic_banking/domain/user.dart';
import 'package:bombastic_banking/repositories/user_repository.dart';
import 'package:bombastic_banking/services/session_manager.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final SessionManager _sessionManager;
  final SecureStorage _secureStorage;

  User? user;

  HomeViewModel({
    required UserRepository userRepository,
    required SessionManager sessionManager,
    required SecureStorage secureStorage,
  }) : _userRepository = userRepository,
       _sessionManager = sessionManager,
       _secureStorage = secureStorage;

  /// Refreshes [user] from the repository, returning the updated user.
  Future<User> refreshUser() async {
    user = await _userRepository.getUser();
    notifyListeners();
    return user!;
  }

  /// Logout the user by stopping session monitoring and clearing the session token.
  /// The refresh token is preserved for biometric login.
  Future<void> logout() async {
    _sessionManager.stopMonitoring();
    await _secureStorage.deleteSessionToken();
    user = null;
    notifyListeners();
  }
}
