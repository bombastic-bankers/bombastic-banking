import 'package:bombastic_banking/repositories/atm_repository.dart';
import 'package:flutter/material.dart';

class DepositConfirmationViewModel extends ChangeNotifier {
  final ATMRepository _atmRepository;
  String? errorMessage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DepositConfirmationViewModel({required ATMRepository atmRepository})
    : _atmRepository = atmRepository;

  Future<void> confirmDeposit({required int atmId}) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _atmRepository.confirmCashDeposit(atmId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to confirm deposit: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
