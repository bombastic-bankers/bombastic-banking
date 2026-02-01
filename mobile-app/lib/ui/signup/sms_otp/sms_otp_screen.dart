import 'package:bombastic_banking/route_observer.dart';
import 'package:bombastic_banking/ui/login/login_screen.dart';
import 'package:bombastic_banking/ui/signup/sms_otp/sms_otp_viewmodel.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SMSOTPScreen extends StatefulWidget {
  const SMSOTPScreen({super.key});

  @override
  State<SMSOTPScreen> createState() => _SMSOTPScreenState();
}

class _SMSOTPScreenState extends State<SMSOTPScreen> with RouteAware {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<String> _previousValues = List.generate(6, (_) => '');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void didPush() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOTP();
    });
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOTP();
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onOTPChanged(int index, String value, String previousValue) {
    if (value.isEmpty && previousValue.isNotEmpty) {
      return;
    }

    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.length > 1) {
      _controllers[index].text = value[0];
      _controllers[index].selection = TextSelection.fromPosition(
        const TextPosition(offset: 1),
      );
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    }
  }

  Future<void> _sendOTP() async {
    final vm = context.read<SMSOTPViewModel>();
    final result = await vm.sendOTP();

    if (!mounted) return;

    if (result is SendOTPFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  Future<void> _resendOTP() async {
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].clear();
      _previousValues[i] = '';
    }
    _focusNodes[0].requestFocus();
    await _sendOTP();
  }

  Future<void> _confirmOTP() async {
    final otp = _otpCode;
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    final vm = context.read<SMSOTPViewModel>();
    final result = await vm.confirmOTP(otp);

    if (!mounted) return;

    switch (result) {
      case OTPVerificationSuccess():
        await vm.clearSignupData();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      case OTPVerificationFailure(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SMSOTPViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Enter OTP Code',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'A One-Time Password (OTP) has been sent to your registered phone number.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => _OTPInput(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      previousValue: _previousValues[index],
                      onChanged: (value) {
                        final previousValue = _previousValues[index];
                        _previousValues[index] = value;
                        _onOTPChanged(index, value, previousValue);
                      },
                      onSubmitted: (_) {
                        if (index == 5) _confirmOTP();
                      },
                      onBackspace: () {
                        if (_controllers[index].text.isEmpty && index > 0) {
                          _controllers[index - 1].clear();
                          _previousValues[index - 1] = '';
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      if (vm.resendCountdown > 0)
                        Text(
                          'You can resend the code in ${vm.resendCountdown} seconds',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: vm.canResend ? _resendOTP : null,
                        child: Text(
                          'Resend code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: vm.canResend
                                ? const Color(0xFF212121)
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
                AppButton(
                  text: 'Confirm Code',
                  onPressed: vm.loading ? null : _confirmOTP,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OTPInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String previousValue;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onBackspace;

  const _OTPInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.previousValue,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 70,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF455A64), width: 2),
            ),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
