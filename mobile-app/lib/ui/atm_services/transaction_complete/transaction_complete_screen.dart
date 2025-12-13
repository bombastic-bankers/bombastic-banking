import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';

sealed class CompletedTransaction {
  final double amount;
  const CompletedTransaction(this.amount);
}

class CompletedWithdrawal extends CompletedTransaction {
  const CompletedWithdrawal(super.amount);
}

class CompletedDeposit extends CompletedTransaction {
  const CompletedDeposit(super.amount);
}

class TransactionCompleteScreen extends StatelessWidget {
  final CompletedTransaction transaction;

  const TransactionCompleteScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isWithdrawal = transaction is CompletedWithdrawal;
    final actionText = isWithdrawal ? 'withdrawn' : 'deposited';

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
                '\$${transaction.amount.toStringAsFixed(2)} successfully $actionText!',
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
