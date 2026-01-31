import 'package:bombastic_banking/ui/signup/signup_viewmodel.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:bombastic_banking/ui/signup/signup_pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Email regex that the API server uses (https://colinhacks.com/essays/reasonable-email-regex)
final emailRegex = RegExp(
  r"^(?!\.)(?!.*\.\.)([a-z0-9_'+\-\.]*)[a-z0-9_+-]@([a-z0-9][a-z0-9\-]*\.)+[a-z]{2,}$",
  caseSensitive: false,
);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullname = TextEditingController();
  final _email = TextEditingController();
  final _phoneNumber = TextEditingController();

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
                controller: _fullname,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Color.fromARGB(26, 128, 128, 128),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Color.fromARGB(26, 128, 128, 128),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _phoneNumber,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  counterText: '',
                  filled: true,
                  fillColor: Color.fromARGB(26, 128, 128, 128),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 8) {
                    return 'Phone number must be 8 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Next',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final vm = context.read<SignupViewModel>();
                    vm.fullName = _fullname.text;
                    vm.email = _email.text;
                    vm.phoneNumber = _phoneNumber.text;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PINScreen()),
                    );
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

/*Future<void> _attemptSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<SignupViewModel>();
    final result = await vm.signup(_email.text, _pin.text);

    if (!mounted) return; */
