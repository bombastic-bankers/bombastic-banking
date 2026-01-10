import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionsService {
  final String baseUrl;

  TransactionsService({required this.baseUrl});

  /// Fetch all transactions for the current user.
  Future<List<TransactionAPIModel>> getTransactions(String sessionToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid response: expected a JSON list');
      }

      return decoded
          .map(
            (json) =>
                TransactionAPIModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception('Failed to fetch transactions');
    }
  }
}

class TransactionAPIModel {
  final String id;
  final String type;
  final String title;
  final double amount;
  final DateTime date;

  TransactionAPIModel({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
  });

  factory TransactionAPIModel.fromJson(Map<String, dynamic> json) {
    return TransactionAPIModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
