// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  /// Retrieve a session token from user credentials. Throws [InvalidCredentialsException] if credentials are invalid.
  Future<String> login(String email, String pin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'pin': pin}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['accessToken'];
    } else if (response.statusCode == 401) {
      throw InvalidCredentialsException();
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
}

class InvalidCredentialsException implements Exception {
  final String? message;

  InvalidCredentialsException([this.message]);

  @override
  String toString() {
    if (message == null) return 'InvalidCredentialsException';
    return 'InvalidCredentialsException: $message';
  }
}
