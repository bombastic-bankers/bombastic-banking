import 'package:bombastic_banking/repositories/atm_repository.dart';
import 'package:flutter/material.dart';

class WithdrawingViewModel extends ChangeNotifier {
  final ATMRepository _atmRepository;
  bool withdrawCalled = false;
  String? errorMessage;

  WithdrawingViewModel({required ATMRepository atmRepository})
    : _atmRepository = atmRepository;

  Future<void> withdraw({required int atmId, required double amount}) async {
    withdrawCalled = true;

    try {
      await _atmRepository.withdrawCash(atmId, amount);
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to withdraw cash: ${e.toString()}';
      notifyListeners();
    }
  }
}
