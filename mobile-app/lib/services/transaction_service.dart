import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionsService {
  final String baseUrl;

  TransactionsService({required this.baseUrl});

  Future<List<TransactionAPIModel>> getTransactions(String sessionToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transaction-history'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);

      return decoded
          .map(
            (json) =>
                TransactionAPIModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        'Failed to fetch transactions (Status: ${response.statusCode})',
      );
    }
  }
}

class TransactionAPIModel {
  final int transactionId;
  final DateTime timestamp;
  final String? description;
  final String myChange;
  final int? counterpartyUserId;
  final String? counterpartyName;
  final bool? counterpartyIsInternal;
  final String type;

  TransactionAPIModel({
    required this.transactionId,
    required this.timestamp,
    this.description,
    required this.myChange,
    this.counterpartyUserId,
    this.counterpartyName,
    this.counterpartyIsInternal,
    required this.type,
  });

  factory TransactionAPIModel.fromJson(Map<String, dynamic> json) {
    return TransactionAPIModel(
      transactionId: json['transactionId'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
      myChange: json['myChange'] as String,
      counterpartyUserId: json['counterpartyUserId'] as int?,
      counterpartyName: json['counterpartyName'] as String?,
      counterpartyIsInternal: json['counterpartyIsInternal'] as bool?,
      type: json['type'] as String,
    );
  }
}
