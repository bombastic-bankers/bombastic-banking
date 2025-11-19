import 'dart:async';
import 'package:flutter/material.dart';

/// Utility class to mock a secure storage solution (e.g., flutter_secure_storage).
/// This class handles the persistent storage for the JWT token and the current ATM ID.
class SecureStorageService {
  static String? _storedToken;
  static String? _storedAtmId;

  /// Simulates saving the JWT token to secure storage.
  Future<void> saveToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storedToken = token;
    debugPrint('🔐 Token saved to secure storage: $token');
  }

  /// Simulates retrieving the JWT token from secure storage.
  Future<String?> getToken() async {
    await Future.delayed(const Duration(milliseconds: 50));
    debugPrint('🔎 Token retrieved: $_storedToken');
    return _storedToken;
  }
  
  /// Simulates saving the ATM ID to secure storage.
  Future<void> saveAtmId(String atmId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _storedAtmId = atmId;
    debugPrint('📍 ATM ID saved: $atmId');
  }
  
  /// Simulates retrieving the ATM ID from secure storage.
  Future<String?> getAtmId() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _storedAtmId;
  }
}