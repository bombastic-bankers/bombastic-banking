import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  /// Fetch basic user information.
  Future<UserAPIModel> getUser(String sessionToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/account-overview'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserAPIModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch user info');
    }
  }
}

class UserAPIModel {
  final String fullName;
  final num accountBalance;

  UserAPIModel({required this.fullName, required this.accountBalance});

  factory UserAPIModel.fromJson(Map<String, dynamic> json) {
    return UserAPIModel(
      fullName: json['fullName'],
      accountBalance: json['accountBalance'],
    );
  }
}
