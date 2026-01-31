import 'package:bombastic_banking/repositories/verification_repository.dart';
import 'package:flutter/material.dart';

class EmailVerificationViewModel extends ChangeNotifier {
  final VerificationRepository _verificationRepo;

  bool loading = false;

  EmailVerificationViewModel({
    required VerificationRepository verificationRepository,
  }) : _verificationRepo = verificationRepository;

  Future<EmailVerificationResult> sendAndWaitForEmailVerification() async {
    loading = true;
    notifyListeners();

    try {
      await _verificationRepo.sendEmailVerification();
      final verified = await _verificationRepo.waitForEmailVerification();
      return verified
          ? const EmailVerificationSuccess()
          : const EmailVerificationTimeout();
    } catch (e) {
      debugPrint('Error with email verification: $e');
      return EmailVerificationFailure('An error occurred: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

sealed class EmailVerificationResult {
  const EmailVerificationResult();
}

class EmailVerificationSuccess extends EmailVerificationResult {
  const EmailVerificationSuccess();
}

class EmailVerificationTimeout extends EmailVerificationResult {
  const EmailVerificationTimeout();
}

class EmailVerificationFailure extends EmailVerificationResult {
  final String message;
  const EmailVerificationFailure(this.message);
}
