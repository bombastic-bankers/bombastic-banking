import 'package:bombastic_banking/repositories/atm_repository.dart';
import 'package:flutter/material.dart';

class DepositStartViewModel extends ChangeNotifier {
  final ATMRepository _atmRepository;
  var isCounting = false;
  String? errorMessage;

  DepositStartViewModel({required ATMRepository atmRepository})
    : _atmRepository = atmRepository;

  Future<void> startDeposit({required int atmId}) async {
    try {
      await _atmRepository.startCashDeposit(atmId);
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to start deposit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<double?> countDeposit({required int atmId}) async {
    isCounting = true;
    notifyListeners();

    try {
      final countedAmount = await _atmRepository.countCashDeposit(atmId);
      errorMessage = null;
      return countedAmount;
    } catch (e) {
      errorMessage = 'Failed to count deposit: ${e.toString()}';
      notifyListeners();
      return null;
    } finally {
      isCounting = false;
      notifyListeners();
    }
  }
}
