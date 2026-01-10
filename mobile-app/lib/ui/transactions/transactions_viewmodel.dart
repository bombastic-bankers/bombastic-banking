import 'package:bombastic_banking/domain/transaction.dart';
import 'package:bombastic_banking/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;

  TransactionsViewModel({required TransactionRepository transactionRepository})
    : _transactionRepository = transactionRepository;

  var _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? errorMessage;

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    isLoading = true;
    errorMessage = null;

    try {
      _transactions = await _transactionRepository.getTransactions();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
  }

  /// Transactions for the month
  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    final filtered = _transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  /// Groups by day
  Map<DateTime, List<Transaction>> get groupedByDay {
    final map = <DateTime, List<Transaction>>{};

    for (final t in currentMonthTransactions) {
      final dayKey = DateTime(t.date.year, t.date.month, t.date.day);
      map.putIfAbsent(dayKey, () => []).add(t);
    }

    for (final entry in map.entries) {
      entry.value.sort((a, b) => b.date.compareTo(a.date));
    }

    return map;
  }

  List<DateTime> get pastSixMonths {
    final now = DateTime.now();
    return List.generate(6, (i) {
      return DateTime(now.year, now.month - i, 1);
    });
  }
}
