import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/profile.dart';

class ProfileService {
  final String baseUrl;

  ProfileService({required this.baseUrl});

  /// Fetch user profile data
  Future<Profile> getProfile(String sessionToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Profile.fromJson(data);
    } else {
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    }
  }

  /// Update user profile data
  Future<void> updateProfile(String sessionToken, Profile profile) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
      body: jsonEncode({
        'fullName': profile.name,
        'email': profile.email,
        'phoneNumber': profile.phone,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }
}
