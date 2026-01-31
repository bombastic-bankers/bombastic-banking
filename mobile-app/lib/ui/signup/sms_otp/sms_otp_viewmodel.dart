import 'dart:async';
import 'package:bombastic_banking/repositories/verification_repository.dart';
import 'package:flutter/material.dart';

class SMSOTPViewModel extends ChangeNotifier {
  final VerificationRepository _verificationRepo;

  bool loading = false;
  int resendCountdown = 0;
  Timer? _timer;

  SMSOTPViewModel({required VerificationRepository verificationRepository})
    : _verificationRepo = verificationRepository;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<SendOTPResult> sendOTP() async {
    loading = true;
    notifyListeners();

    try {
      await _verificationRepo.sendSMSOTP();
      _startResendTimer();
      return const SendOTPSuccess();
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return const SendOTPFailure('Failed to send OTP. Please try again.');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<OTPVerificationResult> confirmOTP(String otp) async {
    loading = true;
    notifyListeners();

    try {
      final verified = await _verificationRepo.confirmSMSOTP(otp);
      return verified
          ? const OTPVerificationSuccess()
          : const OTPVerificationFailure('Invalid OTP code');
    } catch (e) {
      debugPrint('Error confirming OTP: $e');
      return const OTPVerificationFailure(
        'An error occurred. Please try again.',
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _startResendTimer() {
    resendCountdown = 30;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown > 0) {
        resendCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  bool get canResend => resendCountdown == 0 && !loading;
}

sealed class OTPVerificationResult {
  const OTPVerificationResult();
}

class OTPVerificationSuccess extends OTPVerificationResult {
  const OTPVerificationSuccess();
}

class OTPVerificationFailure extends OTPVerificationResult {
  final String message;
  const OTPVerificationFailure(this.message);
}

sealed class SendOTPResult {
  const SendOTPResult();
}

class SendOTPSuccess extends SendOTPResult {
  const SendOTPSuccess();
}

class SendOTPFailure extends SendOTPResult {
  final String message;
  const SendOTPFailure(this.message);
}
