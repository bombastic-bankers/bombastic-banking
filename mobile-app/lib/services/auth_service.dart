// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:bombastic_banking/domain/auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  /// Retrieve a session token from user credentials. Throws [InvalidCredentialsException] if credentials are invalid.
  Future<AuthTokens> login(String email, String pin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'pin': pin}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } else if (response.statusCode == 401) {
      throw InvalidCredentialsException();
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  /// Refresh the session using a refresh token. Throws [InvalidCredentialsException] if token is invalid or expired.
  Future<AuthTokens> refreshSession(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } else if (response.statusCode == 401) {
      throw InvalidCredentialsException();
    } else {
      throw Exception('Failed to refresh session: ${response.body}');
    }
  }

  /// Creates an unverified user
  Future<AuthTokens> signUp(
    String fullName,
    String phoneNumber,
    String email,
    String pin,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'pin': pin,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AuthTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } else {
      throw Exception('Failed to sign up: ${response.body}');
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
