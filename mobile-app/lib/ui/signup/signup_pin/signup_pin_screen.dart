import 'package:bombastic_banking/ui/signup/email_verification/email_verification_screen.dart';
import 'package:bombastic_banking/ui/signup/signup_pin/signup_pin_viewmodel.dart';
import 'package:bombastic_banking/utils/validation_utils.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PINScreen extends StatefulWidget {
  const PINScreen({super.key});

  @override
  State<PINScreen> createState() => _PINScreenState();
}

class _PINScreenState extends State<PINScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<SignupPinViewModel>();
    final result = await vm.signup(_pinController.text);

    if (result is SignupSuccess) {
      await vm.saveEmailVerificationStage();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: result.email),
        ),
        (route) => false,
      );
    } else if (result is SignupFailure) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignupPinViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'Enter PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: Validators.pin,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPinController,
                decoration: const InputDecoration(labelText: 'Re-enter PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  if (value != _pinController.text) {
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
        ),
      ),
    );
  }
}
