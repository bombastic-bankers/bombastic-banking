import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// - JWT Token is stored securely using FlutterSecureStorage (encrypted).
/// - ATM ID is stored using SharedPreferences (standard, non-encrypted).
class SecureStorageService {
  // Singleton pattern implementation
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  SecureStorageService._internal() {
    // Start the asynchronous initialization of SharedPreferences immediately
    _initializationFuture = _initializePreferences();
  }
  // ------------------------------------

  // Storage Clients
  // 1. For sensitive data (JWT Token) - instantiated immediately
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // 2. For non-sensitive data (ATM ID) - requires async initialization
  late SharedPreferences _prefs;

  // This future tracks the completion of the SharedPreferences initialization
  late Future<void> _initializationFuture;

  /// Asynchronously initializes the SharedPreferences instance.
  Future<void> _initializePreferences() async {
    try {
      // SharedPreferences must be awaited before use
      _prefs = await SharedPreferences.getInstance();
      debugPrint('Shared Preferences Initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing Shared Preferences: $e');
      rethrow;
    }
  }

  // --- JWT TOKEN (SECURE STORAGE) ---
  static const String _tokenKey = 'jwt_token';

  /// Saves the JWT token using FlutterSecureStorage
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    debugPrint('Token saved to secure storage.');
  }

  /// Retrieves the JWT token from secure storage.
  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    debugPrint('Token retrieved: ${token != null ? "Found" : "Not Found"}');
    return token;  
  }
  
  /// Deletes the JWT token from secure storage.
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
    debugPrint('Token deleted from secure storage.');
  }
  
  // --- ATM ID (STANDARD PREFERENCES) ---
  static const String _atmIdKey = 'current_atm_id';

  /// Saves the ATM ID using SharedPreferences.
  Future<void> saveAtmId(String atmId) async {
    await _initializationFuture;
    await _prefs.setString(_atmIdKey, atmId);
    debugPrint('ATM ID saved: $atmId');
  }
  
  /// Retrieves the ATM ID from SharedPreferences.
  Future<String?> getAtmId() async {
    // Wait for SharedPreferences to be ready before using it
    await _initializationFuture;
    final atmId = _prefs.getString(_atmIdKey);
    return atmId;
  }
  
  /// Deletes the ATM ID from SharedPreferences.
  Future<void> deleteAtmId() async {
    // Wait for SharedPreferences to be ready before using it
    await _initializationFuture;
    await _prefs.remove(_atmIdKey);
    debugPrint('ATM ID deleted from preferences.');
  }
}