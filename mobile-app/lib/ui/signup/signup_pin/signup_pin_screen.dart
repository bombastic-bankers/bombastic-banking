import 'package:bombastic_banking/ui/signup/email_verification/email_verification_screen.dart';
import 'package:bombastic_banking/ui/signup/signup_pin/signup_pin_viewmodel.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PINScreen extends StatefulWidget {
  const PINScreen({super.key});

  @override
  State<PINScreen> createState() => _PINScreenState();
}

class _PINScreenState extends State<PINScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();
  final _confirmPin = TextEditingController();

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<SignupPinViewModel>();
    final result = await vm.signup(_pin.text);

    if (!mounted) return;

    if (result is SignupSuccess) {
      debugPrint(
        "Signup Success detected, navigating to email verification...",
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: result.email),
        ),
        (route) => false, // Clears the signup stack
      );
    } else if (result is SignupFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Consumer<SignupPinViewModel>(
          builder: (context, vm, _) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _pin,
                    decoration: const InputDecoration(labelText: 'Enter PIN'),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your PIN';
                      }
                      if (value.length != 6) {
                        return 'PIN must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmPin,
                    decoration: const InputDecoration(
                      labelText: 'Re-enter PIN',
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value != _pin.text) {
                        return 'PINs do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Sign Up',
                    onPressed: vm.loading ? null : _handleSignup,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
