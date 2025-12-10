import 'dart:convert';
import 'package:http/http.dart' as http;

class ATMService {
  final String baseUrl;

  ATMService({required this.baseUrl});

  /// Command the ATM to withdraw the specified amount of cash.
  Future<void> withdrawCash({
    required String sessionToken,
    required int atmId,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/touchless/$atmId/withdraw'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to withdraw cash');
    }
  }

  /// Command the ATM to allow a cash deposit.
  Future<void> startCashDeposit({
    required String sessionToken,
    required int atmId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/touchless/$atmId/deposit/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to start cash deposit');
    }
  }

  /// Command the ATM to count the deposited cash and return the amount.
  Future<double> countCashDeposit({
    required String sessionToken,
    required int atmId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/touchless/$atmId/deposit/count'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['amount'] as num).toDouble();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to count cash deposit');
    }
  }

  /// Command the ATM to finalize the cash deposit.
  Future<void> confirmCashDeposit({
    required String sessionToken,
    required int atmId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/touchless/$atmId/deposit/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to confirm cash deposit');
    }
  }

  /// Command the ATM to cancel the cash deposit, returning the
  /// cash to the user and allowing for another deposit attempt.
  Future<void> cancelCashDeposit({
    required String sessionToken,
    required int atmId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/touchless/$atmId/deposit/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to cancel cash deposit');
    }
  }

  /// Command the ATM to return to idle state, ending the touchless session.
  Future<void> exit({required String sessionToken, required int atmId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/touchless/$atmId/exit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to exit touchless session');
    }
  }
}
