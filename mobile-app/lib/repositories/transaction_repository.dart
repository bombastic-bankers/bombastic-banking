import 'package:bombastic_banking/domain/transaction.dart';
import 'package:bombastic_banking/services/transaction_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';

class TransactionRepository {
  final TransactionsService _transactionsService;
  final SecureStorage _secureStorage;

  TransactionRepository({
    required TransactionsService transactionsService,
    required SecureStorage secureStorage,
  }) : _transactionsService = transactionsService,
       _secureStorage = secureStorage;

  Future<List<Transaction>> getTransactions() async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) {
      throw Exception('Missing session token');
    }

    final apiTransactions = await _transactionsService.getTransactions(
      sessionToken,
    );

    return apiTransactions
        .map(
          (api) => Transaction(
            id: api.transactionId,
            timestamp: api.timestamp,
            description: api.description ?? 'Transaction',
            myChange: api.myChange,
            counterpartyUserId: api.counterpartyUserId,
            counterpartyName: api.counterpartyName,
            counterpartyIsInternal: api.counterpartyIsInternal,
            type: api.type,
          ),
        )
        .toList();
  }
}
