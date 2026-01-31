import 'package:bombastic_banking/services/verification_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';

class VerificationRepository {
  final VerificationService _verificationService;
  final SecureStorage _secureStorage;

  VerificationRepository({
    required VerificationService verificationService,
    required SecureStorage secureStorage,
  }) : _verificationService = verificationService,
       _secureStorage = secureStorage;

  /// Send SMS OTP to the authenticated user's phone number
  Future<void> sendSMSOTP() async {
    final accessToken = await _secureStorage.getSessionToken();
    if (accessToken == null) {
      throw Exception('No access token found');
    }
    await _verificationService.sendSMSOTP(accessToken);
  }

  /// Confirm SMS OTP
  Future<bool> confirmSMSOTP(String otp) async {
    final accessToken = await _secureStorage.getSessionToken();
    if (accessToken == null) {
      throw Exception('No access token found');
    }
    return await _verificationService.confirmSMSOTP(accessToken, otp);
  }

  /// Send email verification to authenticated user's email
  Future<void> sendEmailVerification() async {
    final accessToken = await _secureStorage.getSessionToken();
    if (accessToken == null) {
      throw Exception('No access token found');
    }
    await _verificationService.sendEmailVerification(accessToken);
  }

  /// Wait for email verification to complete
  Future<bool> waitForEmailVerification() async {
    final accessToken = await _secureStorage.getSessionToken();
    if (accessToken == null) {
      throw Exception('No access token found');
    }
    return await _verificationService.waitForEmailVerification(accessToken);
  }
}
