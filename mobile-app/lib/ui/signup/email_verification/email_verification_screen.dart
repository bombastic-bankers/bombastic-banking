import 'package:bombastic_banking/route_observer.dart';
import 'package:bombastic_banking/ui/signup/email_verification/email_verification_viewmodel.dart';
import 'package:bombastic_banking/ui/signup/sms_otp/sms_otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendAndWaitForVerification();
    });
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendAndWaitForVerification();
    });
  }

  Future<void> _sendAndWaitForVerification() async {
    final vm = context.read<EmailVerificationViewModel>();
    final result = await vm.sendAndWaitForEmailVerification();

    if (!mounted) return;

    switch (result) {
      case EmailVerificationSuccess():
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SMSOTPScreen()),
        );
      case EmailVerificationTimeout():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verification timed out. Please try again.'),
          ),
        );
      case EmailVerificationFailure(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmailVerificationViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Verify your email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'A confirmation email has been sent to ${widget.email}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: vm.loading
                      ? const CircularProgressIndicator()
                      : const Icon(
                          Icons.email_outlined,
                          size: 100,
                          color: Color(0xFFE53935),
                        ),
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: vm.loading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SMSOTPScreen(),
                            ),
                          );
                        },
                  child: Text(
                    'Continue to SMS Verification',
                    style: TextStyle(
                      fontSize: 16,
                      color: vm.loading ? Colors.grey[400] : Colors.grey[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
