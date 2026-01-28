import 'package:flutter/rendering.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

/// Service for handling biometric authentication (fingerprint, face recognition, etc.)
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if the device has biometric hardware and the user has enrolled biometrics
  Future<bool> canUseBiometrics() async {
    final canAuthenticate =
        await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();

    if (!canAuthenticate) {
      return false;
    }

    return (await _localAuth.getAvailableBiometrics()).isNotEmpty;
  }

  /// Authenticate the user using biometrics.
  Future<BiometricResult> authenticate() async {
    try {
      final success = await _localAuth.authenticate(
        localizedReason: 'Authenticate to Bombastic Banking',
        authMessages: [
          // The default messages are just clutter
          AndroidAuthMessages(
            signInTitle: 'Sign in with biometrics', // This must be non-empty
            signInHint: '',
          ),
        ],
      );
      return success ? const BiometricSuccess() : const BiometricFailure();
    } on LocalAuthException catch (e) {
      debugPrint("LocalAuthException caught: ${e.code}");
      if (e.code == LocalAuthExceptionCode.userCanceled) {
        return const BiometricCancelled();
      }
      return const BiometricFailure();
    }
  }
}

/// Result type for biometric authentication operations.
sealed class BiometricResult {
  const BiometricResult();
}

/// Successful biometric authentication.
class BiometricSuccess extends BiometricResult {
  const BiometricSuccess();
}

/// Failed biometric authentication (wrong fingerprint, etc.).
class BiometricFailure extends BiometricResult {
  const BiometricFailure();
}

/// User cancelled the biometric authentication.
class BiometricCancelled extends BiometricResult {
  const BiometricCancelled();
}
