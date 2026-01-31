import 'package:bombastic_banking/ui/login/login_screen.dart';
import 'package:bombastic_banking/ui/signup/signup_viewmodel.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Email regex that the API server uses (https://colinhacks.com/essays/reasonable-email-regex)
final emailRegex = RegExp(
  r"^(?!\.)(?!.*\.\.)([a-z0-9_'+\-\.]*)[a-z0-9_+-]@([a-z0-9][a-z0-9\-]*\.)+[a-z]{2,}$",
  caseSensitive: false,
);
final phoneNumberRegex = RegExp(r'^\+[1-9]\d{1,14}$');

class PINScreen extends StatefulWidget {
  const PINScreen({super.key});

  @override
  State<PINScreen> createState() => _PINScreenState();
}

class _PINScreenState extends State<PINScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();
  final _confirmPin = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
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
                decoration: const InputDecoration(labelText: 'Re-enter PIN'),
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final vm = context.read<SignupViewModel>();
                    vm.pin = _pin.text;
                    final success = await vm.Signup();
                    if (!context.mounted) return;
                    if (success is SignupSuccess) {
                      debugPrint("Signup Success detected, navigating...");
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false, // Clears the signup stack
                      );
                      return;
                    } else if (success is SignupFailure) {
                      debugPrint(success.message);
                      return;
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Failed to push')));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
