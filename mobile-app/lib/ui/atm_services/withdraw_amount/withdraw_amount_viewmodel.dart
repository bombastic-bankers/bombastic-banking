import 'package:bombastic_banking/repositories/atm_repository.dart';
import 'package:flutter/material.dart';

class WithdrawAmountViewModel extends ChangeNotifier {
  final ATMRepository _atmRepository;
  var _isProcessing = false;
  bool get isProcessing => _isProcessing;
  set isProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  String? errorMessage;

  WithdrawAmountViewModel({required ATMRepository atmRepository})
    : _atmRepository = atmRepository;

  Future<void> withdraw({required int atmId, required double amount}) async {
    isProcessing = true;
    try {
      await _atmRepository.withdrawCash(atmId, amount);
    } catch (e) {
      errorMessage = e.toString();
    }

    isProcessing = false;
  }
}
