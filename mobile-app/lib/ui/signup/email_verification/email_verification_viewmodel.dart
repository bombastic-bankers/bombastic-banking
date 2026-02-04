import 'package:bombastic_banking/repositories/verification_repository.dart';
import 'package:flutter/material.dart';

class EmailVerificationViewModel extends ChangeNotifier {
  final VerificationRepository _verificationRepo;

  bool loading = false;

  EmailVerificationViewModel({
    required VerificationRepository verificationRepository,
  }) : _verificationRepo = verificationRepository;

  Future<void> sendEmailVerification() async {
    loading = true;
    notifyListeners();

    try {
      await _verificationRepo.sendEmailVerification();
    } catch (e) {
      debugPrint('Error sending email verification: $e');
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<EmailVerificationResult> waitForEmailVerification() async {
    loading = true;
    notifyListeners();

    try {
      final verified = await _verificationRepo.waitForEmailVerification();
      return verified
          ? const EmailVerificationSuccess()
          : const EmailVerificationTimeout();
    } catch (e) {
      debugPrint('Error with email verification: $e');
      // Check if this is a connection abort (happens when app backgrounds)
      if (e.toString().contains('Software caused connection abort') ||
          e.toString().contains('ClientException')) {
        return const EmailVerificationWaitCancelled();
      }
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

class EmailVerificationWaitCancelled extends EmailVerificationResult {
  const EmailVerificationWaitCancelled();
}
