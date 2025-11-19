import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart'; 
import 'secure_storage_service.dart'; 
import '../app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- PLATFORM CHANNEL SETUP ---
const MethodChannel _channel = MethodChannel('com.ocbc.nfc_service/methods'); 

// -------------------- NEW DATA MODEL --------------------
/// Model to hold user's personal details fetched from the backend.
class UserInfo {
  final String fullName;
  final num accountBalance; // Storing as String for direct display, including currency symbol

  UserInfo({required this.fullName, required this.accountBalance});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      fullName: json['fullName'] as String,
      accountBalance: json['accountBalance'] as num,
    );
  }
}
// -------------------- END DATA MODEL --------------------


/// The main authentication and state management service class.
class AuthService {
  // Singleton pattern implementation
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  AuthService._internal() {
    // 1. Set up the Method Call Handler to receive data from Native (Kotlin)
    _channel.setMethodCallHandler(_handleNativeCall);
    debugPrint('AuthService: Native Method Channel listener initialized.');
  }

  final SecureStorageService _storageService = SecureStorageService();
  
  // --- Global ATM ID State Management ---
  final StreamController<String?> _atmIdController = StreamController<String?>.broadcast();
  Stream<String?> get atmIdStream => _atmIdController.stream;
  Future<String?> get currentAtmId => _storageService.getAtmId(); 

  /// Immediately clears the ATM ID event from the stream by pushing a null value.
  void clearAtmId() {
    if (!_atmIdController.isClosed) {
      debugPrint('AuthService: ATM ID stream state cleared (pushed null).');
      _atmIdController.sink.add(null);
    }
  }

  // --- Foreground NFC Listener Setup (Commands) ---
  void startContinuousNfcScan() { 
    debugPrint('AuthService: NFC Platform Listener Setup Initiated (Foreground Mode).');
    try {
      _channel.invokeMethod('enableReaderMode');
      debugPrint('AuthService: Sent command to ENABLE native NFC Reader Mode.');
    } on PlatformException catch (e) {
      debugPrint("AuthService Error: Failed to enable NFC reader mode: ${e.message}");
    }
  }

  /// Stops the continuous foreground NFC scanner.
  void stopContinuousNfcScan() {
    debugPrint('AuthService: Stopping continuous NFC Scan (Foreground Mode).');
    try {
      _channel.invokeMethod('disableReaderMode');
      debugPrint('AuthService: Sent command to DISABLE native NFC Reader Mode.');
    } on PlatformException catch (e) {
      debugPrint("AuthService Error: Failed to disable NFC reader mode: ${e.message}");
    }
  }

  // --- NFC LISTENER (Receives data from Kotlin) ---
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'tagRead') {
      final String? atmId = call.arguments as String?;
      if (atmId != null) {
        await _handleNfcTagRead(atmId);
      }
      return true;
    }
    return null;
  }

  Future<void> _handleNfcTagRead(String? atmId) async {
    if (atmId != null) {
      await _storageService.saveAtmId(atmId);
      if (!_atmIdController.isClosed) {
        _atmIdController.sink.add(atmId);
        debugPrint('Continuous Scan Success: ATM ID $atmId pushed to stream.');
      }
    }
  }
  
  // --- Authentication and Single NFC Read (used in transaction flow) ---

  /// Performs the network API call to the login endpoint using provided credentials.
  Future<String> authenticate(String accessCode, String pin) async {
    const url = '$apiBaseUrl/auth/login';
    final uri = Uri.parse(url);

    debugPrint('AuthService: Attempting login for Access Code: $accessCode');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': accessCode, 
          'password': pin,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body); 
        final token = body['token'];
        
        if (token != null) {
          await _storageService.saveToken(token);
          debugPrint('AuthService: Login successful. Token saved and returned.');
          return token;
        } else {
          throw Exception('Login succeeded, but authentication token was missing from the response.');
        }
      } else {
        String apiError = 'Authentication failed with status code ${response.statusCode}.';

        try {
          final body = jsonDecode(response.body);
          apiError = body['error'] ?? body['message'] ?? apiError;
        } on FormatException {
          apiError = 'Login failed: Server returned non-JSON error body.';
        }

        debugPrint('AuthService: Final error message: $apiError');
        throw Exception(apiError);
      }
    } catch (e) {
      debugPrint('AuthService Network/Parsing Error: $e');
      rethrow;
    }
  }

  // -------------------- NEW METHOD TO FETCH USER INFO --------------------
  /// Fetches the user's name and account balance using the stored JWT token.
  Future<UserInfo> fetchUserInfo() async {
    final token = await _storageService.getToken();

    if (token == null) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    const url = '$apiBaseUrl/userinfo';
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
        throw Exception('Session expired. Please log in to refresh your token.');
      } else {
        String apiError = 'Failed to fetch user data with status code ${response.statusCode}.';
        
        try {
          final body = jsonDecode(response.body);
          apiError = body['error'] ?? body['message'] ?? apiError;
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
  // -------------------- END NEW METHOD --------------------

  /// Initiates a single NFC reading event and extracts the ATM ID.
  Future<String> readNfcTag() async {
    debugPrint('Single NFC Scan initiated (Platform Channel)...');
    
    const placeholderAtmId = "OCBC-ATM-SG-90210"; 
    await _storageService.saveAtmId(placeholderAtmId);

    return placeholderAtmId;
  }

  /// Retrieves stored JWT token.
  Future<String?> getAuthToken() => _storageService.getToken();

  /// Disposes of all resources held by the service.
  void dispose() {
    _atmIdController.close();
    stopContinuousNfcScan();
    debugPrint('AuthService disposed.');
  }
}
