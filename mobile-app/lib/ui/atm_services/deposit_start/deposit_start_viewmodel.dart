import 'package:bombastic_banking/repositories/atm_repository.dart';
import 'package:flutter/material.dart';

class DepositStartViewModel extends ChangeNotifier {
  final ATMRepository _atmRepository;
  bool isSuccess = false;
  String? errorMessage;

  DepositStartViewModel({required ATMRepository atmRepository})
    : _atmRepository = atmRepository;

  Future<void> startDeposit({required int atmId}) async {
    isSuccess = false;
    notifyListeners();

    try {
      await _atmRepository.startCashDeposit(atmId);
      errorMessage = null;
      isSuccess = true;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to start deposit: ${e.toString()}';
      isSuccess = false;
      notifyListeners();
    }
  }

  void reset() {
    isSuccess = false;
    errorMessage = null;
    notifyListeners();
  }
}
