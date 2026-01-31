import 'dart:convert';
import 'package:http/http.dart' as http;

class TransferService {
  final String baseUrl;

  TransferService({required this.baseUrl});

  Future<void> transferMoney(
    String authToken,
    String recipientPhone,
    double amount,
  ) async {
    final url = Uri.parse('$baseUrl/transfer');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken', // Sending the session token
      },
      body: jsonEncode({'recipient': recipientPhone, 'amount': amount}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'] ?? 'Transfer failed';
      throw Exception(error);
    }
  }
}
