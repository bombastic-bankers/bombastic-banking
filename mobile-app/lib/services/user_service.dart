import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/user.dart';

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

  /// NEW: Send a list of phone numbers to find which ones are Bombastic users
  Future<List<User>> findContacts(
    String sessionToken,
    List<String> phoneNumbersToCheck,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contacts'), // Assuming your route is /contacts
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionToken',
      },
      // We send the list of numbers as a JSON array
      body: jsonEncode(phoneNumbersToCheck),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Convert the list of JSON objects into a list of Users
      return data
          .map((json) => UserAPIModel.fromJson(json).toDomain())
          .toList();
    } else {
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    }
  }
}

class UserAPIModel {
  final String fullName;
  final num accountBalance;
  final String? phoneNumber;

  UserAPIModel({
    required this.fullName,
    required this.accountBalance,
    this.phoneNumber,
  });

  factory UserAPIModel.fromJson(Map<String, dynamic> json) {
    return UserAPIModel(
      fullName: json['fullName'] ?? 'Unknown',
      accountBalance: json['accountBalance'] ?? 0,
      phoneNumber: json['phoneNumber'],
    );
  }

  User toDomain() {
    return User(
      fullName: fullName,
      accountBalance: accountBalance,
      phoneNumber: phoneNumber,
    );
  }
}
