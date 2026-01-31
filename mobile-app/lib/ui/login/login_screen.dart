import 'package:bombastic_banking/ui/login/login_viewmodel.dart';
import 'package:bombastic_banking/ui/navbar_root/navbar_root_screen.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import '../signup/signup_form/signup_screen.dart';
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
  void initState() {
    super.initState();
    // Wait for the widget tree to be fully built before checking biometrics
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<LoginViewModel>();
      await vm.checkBiometricAvailability();
      if (vm.canUseBiometrics) {
        _attemptBiometricLogin();
      }
    });
  }

  Future<void> _attemptBiometricLogin() async {
    final vm = context.read<LoginViewModel>();
    final result = await vm.loginWithBiometrics();

    if (!mounted) return;
    _handleLoginResult(result);
  }

  Future<void> _attemptPINLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<LoginViewModel>();
    final result = await vm.login(_email.text, _pin.text);

    if (!mounted) return;

    if (result is LoginSuccess) {
      _email.clear();
      _pin.clear();
    }

    _handleLoginResult(result);
  }

  void _handleLoginResult(LoginResult result) {
    switch (result) {
      case LoginSuccess():
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => NavbarRootScreen()),
          (_) => false,
        );
      case LoginFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      case LoginCancelled():
        break;
    }
  }

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
      body: Padding(
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

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: vm.loading ? 'Logging in...' : 'Login',
                      color: const Color(0xFF495A63),
                      onPressed: vm.loading ? null : _attemptPINLogin,
                    ),
                  ),
                  if (vm.canUseBiometrics) ...[
                    const SizedBox(width: 12),
                    _BiometricButton(
                      onPressed: vm.loading ? null : _attemptBiometricLogin,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                ),
                child: Text(
                  'Don\'t have an account? Sign up',
                  style: TextStyle(color: Color.fromARGB(255, 49, 77, 136)),
                ),
              ),
            ],
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

class _BiometricButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _BiometricButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: IconButton(
        icon: const Icon(Icons.fingerprint, size: 32),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
