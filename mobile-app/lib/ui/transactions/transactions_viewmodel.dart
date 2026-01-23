import 'package:bombastic_banking/domain/transaction.dart';
import 'package:bombastic_banking/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;

  TransactionsViewModel({required TransactionRepository transactionRepository})
      : _transactionRepository = transactionRepository {
    //initialize selectedMonth to now
    _selectedMonth = DateTime.now();
  }

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

  List<Transaction> get currentMonthTransactions {
    // Fallback to now() if null, though our constructor fixes this
    final targetDate = _selectedMonth ?? DateTime.now(); 
    
    final filtered = _transactions.where((t) {
      return t.timestamp.year == targetDate.year && 
             t.timestamp.month == targetDate.month;
    }).toList();

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  Map<DateTime, List<Transaction>> get groupedByDay {
    final map = <DateTime, List<Transaction>>{};

    for (final t in currentMonthTransactions) {
      // Create a key with just Year/Month/Day (strip time)
      final dayKey = DateTime(
        t.timestamp.year,
        t.timestamp.month,
        t.timestamp.day,
      );
      map.putIfAbsent(dayKey, () => []).add(t);
    }

    // Sort entries if needed, or rely on UI to sort keys
    return map;
  }

  List<DateTime> get pastSixMonths {
    final now = DateTime.now();
    return List.generate(6, (i) {
      return DateTime(now.year, now.month - i, 1);
    });
  }

  DateTime? _selectedMonth;
  DateTime? get selectedMonth => _selectedMonth;

  void selectMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }
}