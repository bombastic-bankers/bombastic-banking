import 'package:bombastic_banking/ui/login/login_viewmodel.dart';
import 'package:bombastic_banking/ui/navbar_root/navbar_root_screen.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Email regex that the API server uses (https://colinhacks.com/essays/reasonable-email-regex)
final emailRegex = RegExp(
  r"^(?!\.)(?!.*\.\.)([a-z0-9_'+\-\.]*)[a-z0-9_+-]@([a-z0-9][a-z0-9\-]*\.)+[a-z]{2,}$",
  caseSensitive: false,
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pin = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: emailValidator,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _pin,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(labelText: 'PIN'),
                    validator: pinValidator,
                  ),
                ),

                const SizedBox(height: 30),

                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: vm.loading ? 'LOGGING IN...' : 'Login',
                    color: const Color(0xFF495A63),
                    onPressed: vm.loading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await vm.login(
                                _email.text,
                                _pin.text,
                              );
                              if (success && context.mounted) {
                                _email.clear();
                                _pin.clear();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => NavbarRootScreen(),
                                  ),
                                  (_) => false,
                                );
                              }
                            }
                          },
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Trouble logging in",
                  style: TextStyle(color: Color.fromARGB(255, 49, 77, 136)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? emailValidator(String? value) {
    if (value == null || !emailRegex.hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  String? pinValidator(String? value) {
    if (value == null || value.length != 6) {
      return 'PIN must be 6 digits';
    }
    return null;
  }
}
