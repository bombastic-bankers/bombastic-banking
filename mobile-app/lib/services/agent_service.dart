import 'dart:convert';
import 'package:http/http.dart' as http;

class TokenService {
  final String baseUrl;
  TokenService({required this.baseUrl});

  Future<String> fetchWebRtcToken({required String sessionToken}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/voice/token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to load voice token');
    }
  }
}
