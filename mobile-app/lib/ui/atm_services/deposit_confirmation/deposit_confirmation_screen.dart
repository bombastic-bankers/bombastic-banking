import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/route_observer.dart';
import 'package:bombastic_banking/ui/atm_services/transaction_complete/transaction_complete_screen.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_confirmation/deposit_confirmation_viewmodel.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DepositConfirmationScreen extends StatefulWidget {
  final int atmId;
  final double amount;

  const DepositConfirmationScreen({
    super.key,
    required this.atmId,
    required this.amount,
  });

  @override
  State<DepositConfirmationScreen> createState() =>
      _DepositConfirmationScreenState();
}

class _DepositConfirmationScreenState extends State<DepositConfirmationScreen>
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
  void didPopNext() {
    final vm = context.read<DepositConfirmationViewModel>();
    vm.reset();
  }

  void _confirmDeposit() {
    final vm = context.read<DepositConfirmationViewModel>();

    vm.confirmDeposit(atmId: widget.atmId).then((_) {
      if (!mounted) return;

      if (vm.errorMessage == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TransactionCompleteScreen(
              transaction: CompletedDeposit(widget.amount),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DepositConfirmationViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${widget.amount.toStringAsFixed(2)} counted',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            if (vm.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(0x0F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade700),
                ),
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            if (vm.isLoading)
              const CircularProgressIndicator(color: brandRed)
            else
              AppButton(text: 'Confirm Deposit', onPressed: _confirmDeposit),
          ],
        ),
      ),
    );
  }
}
