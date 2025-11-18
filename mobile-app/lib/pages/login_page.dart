import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../app_constants.dart';
import '../widgets/app_button.dart';
import 'home_page.dart';
import 'manual_login_page.dart';

/// -------------------- Login with Biometric --------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      setState(() {
        _biometricAvailable = canCheck && isDeviceSupported;
      });
    } catch (e) {
      setState(() => _biometricAvailable = false);
      // In a real app, you would use a proper logging system
      debugPrint('Error checking biometrics: $e'); 
    }
  }

  Future<void> _authenticate() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access your account',
      );

      if (authenticated) {
        Navigator.pushReplacement(context, slideRoute(const HomePage()));
      } else {
        Navigator.pushReplacement(context, slideRoute(const ManualLoginPage()));
      }
    } catch (e) {
      // Handles user canceling biometric prompt or platform errors.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color customColor = Color(0xFF495A63);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: _biometricAvailable
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Login with Fingerprint / Face ID',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      iconSize: 64,
                      icon: const Icon(Icons.fingerprint, color: brandRed),
                      onPressed: _authenticate,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Login with PIN',
                      onPressed: () => Navigator.pushReplacement(
                          context, slideRoute(const ManualLoginPage())),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Log in to OCBC Singapore',
                    color: customColor,
                    onPressed: () =>
                        Navigator.pushReplacement(context, slideRoute(const ManualLoginPage())),
                  ),
                ),
        ),
      ),
    );
  }
}