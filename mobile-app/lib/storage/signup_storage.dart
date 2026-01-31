import 'package:shared_preferences/shared_preferences.dart';

/// Storage for temporary signup data.
/// This data persists across app restarts but is cleared after successful verification.
abstract class SignupStorage {
  Future<void> saveSignupData({
    required String fullName,
    required String email,
    required String phoneNumber,
  });
  Future<SignupData?> getSignupData();
  Future<void> clearSignupData();
}

/// Signup storage using `SharedPreferences`.
class DefaultSignupStorage implements SignupStorage {
  static const String _fullNameKey = 'signup_fullname';
  static const String _emailKey = 'signup_email';
  static const String _phoneNumberKey = 'signup_phonenumber';

  @override
  Future<void> saveSignupData({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, fullName);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_phoneNumberKey, phoneNumber);
  }

  @override
  Future<SignupData?> getSignupData() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString(_fullNameKey);
    final email = prefs.getString(_emailKey);
    final phoneNumber = prefs.getString(_phoneNumberKey);

    if (fullName == null || email == null || phoneNumber == null) {
      return null;
    }

    return SignupData(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<void> clearSignupData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fullNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneNumberKey);
  }
}

/// Data class to hold signup information
class SignupData {
  final String fullName;
  final String email;
  final String phoneNumber;

  SignupData({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });
}
