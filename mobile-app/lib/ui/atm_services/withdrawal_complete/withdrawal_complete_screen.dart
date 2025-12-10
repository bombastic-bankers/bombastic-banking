import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';

class WithdrawalCompleteScreen extends StatefulWidget {
  final double amount;

  const WithdrawalCompleteScreen({super.key, required this.amount});

  @override
  State<WithdrawalCompleteScreen> createState() =>
      _WithdrawalCompleteScreenState();
}

class _WithdrawalCompleteScreenState extends State<WithdrawalCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 84, color: brandRed),
              const SizedBox(height: 18),
              Text(
                '\$${widget.amount.toStringAsFixed(2)} successfully withdrawn!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                color: const Color(0xFF495A63),
                text: 'Back to Home',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
