import 'package:bombastic_banking/services/atm_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';

class ATMRepository {
  final ATMService _atmService;
  final SecureStorage _secureStorage;

  ATMRepository({
    required ATMService atmService,
    required SecureStorage secureStorage,
  }) : _secureStorage = secureStorage,
       _atmService = atmService;

  Future<void> withdrawCash(int atmId, double amount) async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) {
      throw Exception('Missing session token');
    }

    await _atmService.withdrawCash(
      sessionToken: sessionToken,
      atmId: atmId,
      amount: amount,
    );
  }

  Future<void> startCashDeposit(int atmId) async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) {
      throw Exception('Missing session token');
    }

    await _atmService.startCashDeposit(
      sessionToken: sessionToken,
      atmId: atmId,
    );
  }

  Future<double> countCashDeposit(int atmId) async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) {
      throw Exception('Missing session token');
    }

    return await _atmService.countCashDeposit(
      sessionToken: sessionToken,
      atmId: atmId,
    );
  }

  Future<void> confirmCashDeposit(int atmId) async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) {
      throw Exception('Missing session token');
    }

    await _atmService.confirmCashDeposit(
      sessionToken: sessionToken,
      atmId: atmId,
    );
  }

  Future<void> cancelCashDeposit(int atmId) async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) {
      throw Exception('Missing session token');
    }

    await _atmService.cancelCashDeposit(
      sessionToken: sessionToken,
      atmId: atmId,
    );
  }

  Future<void> exit(int atmId) async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) {
      throw Exception('Missing session token');
    }

    await _atmService.exit(sessionToken: sessionToken, atmId: atmId);
  }
}
