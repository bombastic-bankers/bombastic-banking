import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/ui/atm_services/withdrawal_complete/withdrawal_complete_screen.dart';
import 'package:bombastic_banking/ui/atm_services/withdrawing/withdrawing_viewmodel.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WithdrawingScreen extends StatefulWidget {
  final int atmId;
  final double amount;

  const WithdrawingScreen({
    super.key,
    required this.atmId,
    required this.amount,
  });

  @override
  State<WithdrawingScreen> createState() => _WithdrawingScreenState();
}

class _WithdrawingScreenState extends State<WithdrawingScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final vm = context.read<WithdrawingViewModel>();
    if (vm.withdrawCalled) return;

    vm.withdraw(atmId: widget.atmId, amount: widget.amount).then((_) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WithdrawalCompleteScreen(amount: widget.amount),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WithdrawingViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Withdrawing')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                vm.errorMessage == null ? Icons.security : Icons.error_outline,
                size: 84,
                color: vm.errorMessage == null ? brandRed : Colors.red,
              ),

              const SizedBox(height: 18),

              Text(
                vm.errorMessage == null
                    ? 'Validating & Processing Withdrawal...'
                    : 'Transaction Failed!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text('Amount: \$${widget.amount.toStringAsFixed(2)}'),
              Text('ATM ID: ${widget.atmId}'),

              const SizedBox(height: 20),

              if (vm.errorMessage == null) ...[
                const Text(
                  'Securing connection with the ATM...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                const CircularProgressIndicator(color: brandRed),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(0x1A),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red.shade700),
                  ),
                  child: Text(
                    vm.errorMessage ?? 'Unknown error occurred',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                AppButton(
                  text: 'Try Again',
                  onPressed: () {
                    vm.withdraw(atmId: widget.atmId, amount: widget.amount);
                  },
                ),

                const SizedBox(height: 15),

                AppButton(
                  color: const Color(0xFF495A63),
                  text: 'Cancel and Go Home',
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
