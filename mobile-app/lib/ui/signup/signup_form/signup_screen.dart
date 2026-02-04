import 'package:bombastic_banking/ui/signup/signup_form/signup_viewmodel.dart';
import 'package:bombastic_banking/ui/signup/signup_pin/signup_pin_screen.dart';
import 'package:bombastic_banking/utils/validation_utils.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  static const _inputDecoration = InputDecoration(
    filled: true,
    fillColor: Color.fromARGB(26, 128, 128, 128),
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      borderSide: BorderSide(color: Colors.red),
    ),
  );

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<SignupViewModel>();
    vm.fullName = _fullnameController.text.trim();
    vm.email = _emailController.text.trim();
    vm.phoneNumber = _phoneController.text.trim();

    await vm.saveSignupData();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PINScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine loading state if needed from VM, though currently local state suffices for simple nav
    final vm = context.watch<SignupViewModel>();
    final isLoading = vm.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullnameController,
                decoration: _inputDecoration.copyWith(labelText: 'Full name'),
                keyboardType: TextInputType.name,
                validator: (v) => Validators.required(v, 'full name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration.copyWith(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration.copyWith(
                  labelText: 'Phone number',
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.phone,
              ),
              const SizedBox(height: 20),
              AppButton(text: 'Next', onPressed: isLoading ? null : _submit),
            ],
          ),
        ),
      ),
    );
  }
}
