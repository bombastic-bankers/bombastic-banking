import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage for session and refresh tokens.
abstract class SecureStorage {
  Future<void> saveSessionToken(String token);
  Future<String?> getSessionToken();
  Future<void> deleteSessionToken();

  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> deleteRefreshToken();
}

/// Secure storage using `FlutterSecureStorage`.
class DefaultSecureStorage implements SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> saveSessionToken(String token) async {
    await _storage.write(key: 'session_token', value: token);
  }

  @override
  Future<String?> getSessionToken() async {
    return await _storage.read(key: 'session_token');
  }

  @override
  Future<void> deleteSessionToken() async {
    await _storage.delete(key: 'session_token');
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  @override
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }
}
