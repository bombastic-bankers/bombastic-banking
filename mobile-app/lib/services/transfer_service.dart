import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

class TransferService {
  final String baseUrl;
  final SecureStorage secureStorage;

  TransferService({required this.baseUrl, required this.secureStorage});

  Future<int> transferMoney({
    required String recipient,
    required num amount,
  }) async {
    final sessionToken = await secureStorage.getSessionToken();

    if (sessionToken == null) {
      throw Exception('No session token available. Please log in again.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/transfer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
      body: jsonEncode({'recipient': recipient, 'amount': amount}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['transactionId']; // Success
    } else {
      // Parse error message from response body if available
      String errorMessage;
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage =
            errorBody['message'] ?? errorBody['error'] ?? response.body;
      } catch (_) {
        errorMessage = response.body.isNotEmpty
            ? response.body
            : 'Transfer failed with status ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }
}
