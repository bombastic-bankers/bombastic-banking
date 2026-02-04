import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificationService {
  final String baseUrl;

  VerificationService({required this.baseUrl});

  /// Send SMS OTP to authenticated user's phone number
  Future<void> sendSMSOTP(String accessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/sms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send SMS OTP: ${response.body}');
    }
  }

  /// Confirm SMS OTP for authenticated user
  Future<bool> confirmSMSOTP(String accessToken, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/sms/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'otp': otp}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['verified'] == true;
    } else if (response.statusCode == 400) {
      return false;
    } else {
      throw Exception('Failed to confirm SMS OTP: ${response.body}');
    }
  }

  /// Send email verification to authenticated user's email
  Future<void> sendEmailVerification(String accessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send email verification: ${response.body}');
    }
  }

  /// Wait for email verification to complete
  /// Returns true when email is verified, false on timeout
  Future<bool> waitForEmailVerification(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/verification/email/wait'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['verified'] == true;
    } else if (response.statusCode == 408) {
      // Timeout
      return false;
    } else {
      throw Exception(
        'Failed to wait for email verification: ${response.body}',
      );
    }
  }
}
