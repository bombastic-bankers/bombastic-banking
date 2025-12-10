// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'secure_storage_service.dart';
import '../app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// NOTE: Channel name must match the Kotlin/Android implementation
const MethodChannel _channel = MethodChannel('com.ocbc.nfc_service/methods');

/// Model to hold user's personal details fetched from the backend.
class UserInfo {
  final String fullName;
  final num accountBalance;

  UserInfo({required this.fullName, required this.accountBalance});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      fullName: json['fullName'] as String,
      accountBalance: json['accountBalance'] as num,
    );
  }
}

/// The main authentication and state management service class.
class OldAuthService {
  // Singleton pattern implementation
  static final OldAuthService _instance = OldAuthService._internal();
  factory OldAuthService() => _instance;

  OldAuthService._internal() {
    // 1. Set up the Method Call Handler to receive data from Native (Kotlin)
    _channel.setMethodCallHandler(_handleNativeCall);
    debugPrint('AuthService: Native Method Channel listener initialized.');
  }

  final OldSecureStorageService _storageService = OldSecureStorageService();

  // --- Global ATM ID State Management ---
  final StreamController<String?> _atmIdController =
      StreamController<String?>.broadcast();
  Stream<String?> get atmIdStream => _atmIdController.stream;
  Future<String?> get currentAtmId => _storageService.getAtmId();

  /// Immediately clears the ATM ID event from the stream by pushing a null value
  /// and clearing persistent storage.
  void clearAtmId() {
    if (!_atmIdController.isClosed) {
      debugPrint('AuthService: ATM ID stream state cleared (pushed null).');
      _storageService.deleteAtmId();
      _atmIdController.sink.add(null);
    }
  }

  // --- Foreground NFC Listener Setup (Commands) ---
  void startContinuousNfcScan() {
    debugPrint(
      'AuthService: NFC Platform Listener Setup Initiated (Foreground Mode).',
    );
    try {
      // CRITICAL FIX: The method name must match the one defined in MainActivity.kt
      _channel.invokeMethod('startContinuousNfcScan');
      debugPrint('AuthService: Sent command to ENABLE native NFC Reader Mode.');
    } on PlatformException catch (e) {
      debugPrint(
        "AuthService Error: Failed to enable NFC reader mode: ${e.message}",
      );
    }
  }

  /// Stops the continuous foreground NFC scanner.
  void stopContinuousNfcScan() {
    debugPrint('AuthService: Stopping continuous NFC Scan (Foreground Mode).');
    try {
      // CRITICAL FIX: The method name must match the one defined in MainActivity.kt
      _channel.invokeMethod('stopContinuousNfcScan');
      debugPrint(
        'AuthService: Sent command to DISABLE native NFC Reader Mode.',
      );
    } on PlatformException catch (e) {
      debugPrint(
        "AuthService Error: Failed to disable NFC reader mode: ${e.message}",
      );
    }
  }

  // --- NFC LISTENER (Receives data from Kotlin) ---
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'TagRead') {
      final String? atmId = call.arguments as String?;
      if (atmId != null) {
        await _handleNfcTagRead(atmId);
      }
      return true;
    }
    return null;
  }

  // Helper function to clean the NFC payload (strip 'en' prefix)
  String _cleanNfcPayload(String rawAtmId) {
    if (rawAtmId.length >= 2) {
      final cleanedId = rawAtmId.substring(2);
      debugPrint('NFC Payload Cleaned: "$rawAtmId" -> "$cleanedId"');
      return cleanedId;
    }
    return rawAtmId;
  }

  Future<void> _handleNfcTagRead(String? rawAtmId) async {
    if (rawAtmId != null) {
      final cleanedAtmId = _cleanNfcPayload(rawAtmId);

      await _storageService.saveAtmId(cleanedAtmId);
      if (!_atmIdController.isClosed) {
        _atmIdController.sink.add(cleanedAtmId);
        debugPrint(
          'Continuous Scan Success: ATM ID $cleanedAtmId pushed to stream.',
        );
      }
    }
  }

  /// Performs the withdrawal or deposit API call after NFC tap.
  Future<void> performTransaction({
    required String atmId,
    required String amount,
    required bool isWithdrawal,
  }) async {
    final token = await _storageService.getToken();

    if (token == null) {
      throw Exception(
        'Session Expired: Authentication token is missing. Please log in again.',
      );
    }

    final action = isWithdrawal ? 'withdraw' : 'deposit';
    final int? parsedAmount = int.tryParse(amount);

    late final String url;
    late final Map<String, dynamic>? body;

    if (isWithdrawal) {
      url = '$apiBaseUrl/touchless/$atmId/withdraw';
      body = {'amount': parsedAmount};
    } else {
      url = '$apiBaseUrl/touchless/$atmId/initiate-deposit';
      body = null;
    }

    final uri = Uri.parse(url);

    debugPrint('AuthService: Attempting $action at ATM $atmId.');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('AuthService: Transaction success: $action complete.');
        return;
      } else {
        String apiError =
            'Transaction failed with status code ${response.statusCode}.';

        try {
          final body = jsonDecode(response.body);
          // Ensure the extracted error message is always a String, not a Map.
          final dynamic rawError = body['error'] ?? body['message'];

          if (rawError is String) {
            apiError = rawError;
          } else if (rawError != null) {
            // Convert any other JSON object (like a nested error Map) to its string representation.
            apiError = rawError.toString();
          }
        } on FormatException {
          apiError =
              'Transaction failed: Server returned non-JSON error body: "${response.body}"';
        }

        debugPrint('AuthService: Transaction error: $apiError');
        throw Exception(apiError);
      }
    } catch (e) {
      debugPrint('AuthService Network/Parsing Error during transaction: $e');
      rethrow;
    }
  }

  Future<void> confirmDeposit({
    required String atmId,
    //  required String amount,
  }) async {
    final token = await _storageService.getToken();

    if (token == null) {
      throw Exception(
        'Session Expired: Authentication token is missing. Please log in again.',
      );
    }

    // final int? parsedAmount = int.tryParse(amount);
    // if (parsedAmount == null) {
    // throw Exception('Invalid amount.');
    // }

    final url = '$apiBaseUrl/touchless/$atmId/confirm-deposit';
    final uri = Uri.parse(url);

    // debugPrint('AuthService: Confirming deposit at ATM $atmId for amount $parsedAmount.');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // body: jsonEncode({'amount': parsedAmount}),
        body: null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('AuthService: Deposit confirmed successfully.');
        return;
      } else {
        String apiError =
            'Deposit confirmation failed with status code ${response.statusCode}.';
        try {
          final body = jsonDecode(response.body);
          final dynamic rawError = body['error'] ?? body['message'];
          if (rawError is String) {
            apiError = rawError;
          } else if (rawError != null) {
            apiError = rawError.toString();
          }
        } on FormatException {
          apiError =
              'Deposit failed: Server returned non-JSON error body: "${response.body}"';
        }
        debugPrint('AuthService: Deposit error: $apiError');
        throw Exception(apiError);
      }
    } catch (e) {
      debugPrint(
        'AuthService Network/Parsing Error during deposit confirmation: $e',
      );
      rethrow;
    }
  }

  // --- Authentication and Info Methods  ---

  /// Performs the network API call to the login endpoint using provided credentials.
  Future<String> authenticate(String accessCode, String pin) async {
    var url = '$apiBaseUrl/auth/login';
    final uri = Uri.parse(url);

    debugPrint('AuthService: Attempting login for Access Code: $accessCode');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': accessCode, 'password': pin}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];

        if (token != null) {
          await _storageService.saveToken(token);
          debugPrint(
            'AuthService: Login successful. Token saved and returned.',
          );
          return token as String;
        } else {
          throw Exception(
            'Login succeeded, but authentication token was missing from the response.',
          );
        }
      } else {
        String apiError =
            'Authentication failed with status code ${response.statusCode}.';

        try {
          final body = jsonDecode(response.body);
          // Ensure the extracted error message is always a String, not a Map.
          final dynamic rawError = body['error'] ?? body['message'];

          if (rawError is String) {
            apiError = rawError;
          } else if (rawError != null) {
            apiError = rawError.toString();
          }
        } on FormatException {
          apiError =
              'Login failed: Server returned non-JSON error body: "${response.body}"';
        }

        debugPrint('AuthService: Final error message: $apiError');
        throw Exception(apiError);
      }
    } catch (e) {
      debugPrint('AuthService Network/Parsing Error: $e');
      rethrow;
    }
  }

  /// Fetches the user's name and account balance using the stored JWT token.
  Future<UserInfo> fetchUserInfo() async {
    final token = await _storageService.getToken();

    if (token == null) {
      // This error will be caught by HomePage and trigger the logout/redirect.
      throw Exception(
        'Unauthenticated: Authentication token is missing. Please log in again.',
      );
    }

    var url = '$apiBaseUrl/userinfo';
    final uri = Uri.parse(url);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return UserInfo.fromJson(body);
      } else if (response.statusCode == 401) {
        // Explicitly throw a recognizable error for the HomePage to handle
        throw Exception(
          'Unauthenticated: Session expired. Please log in to refresh your token.',
        );
      } else {
        String apiError =
            'Failed to fetch user data with status code ${response.statusCode}.';

        try {
          final body = jsonDecode(response.body);
          final dynamic rawError = body['error'] ?? body['message'];

          if (rawError is String) {
            apiError = rawError;
          } else if (rawError != null) {
            apiError = rawError.toString();
          }
        } on FormatException {
          apiError = response.body.isNotEmpty
              ? response.body
              : 'Failed to fetch user data. Unknown server error.';
        }

        throw Exception(apiError);
      }
    } catch (e) {
      debugPrint('AuthService User Info Error: $e');
      rethrow;
    }
  }

  /// Retrieves stored JWT token.
  Future<String?> getToken() => _storageService.getToken();

  /// Clears the user's authentication token and ATM ID from storage.
  Future<void> signOut() async {
    await _storageService.deleteToken();
    clearAtmId();
    debugPrint('AuthService: User signed out. Token and ATM ID cleared.');
  }

  /// Disposes of all resources held by the service.
  void dispose() {
    _atmIdController.close();
    stopContinuousNfcScan();
    debugPrint('AuthService disposed.');
  }
}

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
      return jsonDecode(response.body)['token'];
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
