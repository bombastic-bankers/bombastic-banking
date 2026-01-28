import 'package:bombastic_banking/services/auth_service.dart';
import 'package:bombastic_banking/services/biometric_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';

class AuthRepository {
  final AuthService _authService;
  final SecureStorage _secureStorage;
  final BiometricService _biometricService;

  AuthRepository({
    required AuthService authService,
    required SecureStorage secureStorage,
    required BiometricService biometricService,
  }) : _secureStorage = secureStorage,
       _authService = authService,
       _biometricService = biometricService;

  Future<bool> login(String email, String pin) async {
    try {
      final tokens = await _authService.login(email, pin);
      await _secureStorage.saveSessionToken(tokens.accessToken);
      await _secureStorage.saveRefreshToken(tokens.refreshToken);
      return true;
    } on InvalidCredentialsException {
      return false;
    }
  }

  Future<bool> loginWithRefreshToken(String refreshToken) async {
    try {
      final tokens = await _authService.refreshSession(refreshToken);
      await _secureStorage.saveSessionToken(tokens.accessToken);
      await _secureStorage.saveRefreshToken(tokens.refreshToken);
      return true;
    } on InvalidCredentialsException {
      return false;
    }
  }

  /// Check if biometric login is available (device supports it and refresh token exists)
  Future<bool> canUseBiometrics() async {
    final hasBiometrics = await _biometricService.canUseBiometrics();
    if (!hasBiometrics) {
      return false;
    }

    final refreshToken = await _secureStorage.getRefreshToken();
    return refreshToken != null;
  }

  /// Perform biometric verification and return the result.
  /// [canUseBiometrics] should be called before this.
  Future<BiometricResult> verifyBiometrics() async {
    return await _biometricService.authenticate();
  }

  /// Return the user's stored refresh token.
  Future<String?> getRefreshToken() async {
    return await _secureStorage.getRefreshToken();
  }
}
