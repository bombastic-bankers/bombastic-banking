import 'package:bombastic_banking/domain/transaction.dart';
import 'package:bombastic_banking/domain/user.dart';
import 'package:bombastic_banking/repositories/transaction_repository.dart';
import 'package:bombastic_banking/repositories/user_repository.dart';
import 'package:bombastic_banking/services/session_manager.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final SessionManager _sessionManager;
  final SecureStorage _secureStorage;
  final TransactionRepository _transactionRepository;

  User? user;

  HomeViewModel({
    required UserRepository userRepository,
    required SessionManager sessionManager,
    required SecureStorage secureStorage,
    required TransactionRepository transactionRepository,
  }) : _userRepository = userRepository,
       _sessionManager = sessionManager,
       _secureStorage = secureStorage,
       _transactionRepository = transactionRepository;

  List<Transaction> _recentTransactions = [];
  List<Transaction> get recentTransactions => _recentTransactions;

  /// Refreshes user data and recent transactions from the repository.
  Future<User> refreshUser() async {
    user = await _userRepository.getUser();
    try {
      final allTransactions = await _transactionRepository.getTransactions();

      allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _recentTransactions = allTransactions.take(5).toList();
    } catch (e) {
      debugPrint("Error loading recent transactions: $e");
      _recentTransactions = [];
    }

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
