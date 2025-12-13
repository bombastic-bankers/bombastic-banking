import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/route_observer.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_confirmation/deposit_confirmation_screen.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_start/deposit_start_viewmodel.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DepositStartScreen extends StatefulWidget {
  final int atmId;

  const DepositStartScreen({super.key, required this.atmId});

  @override
  State<DepositStartScreen> createState() => _DepositStartScreenState();
}

class _DepositStartScreenState extends State<DepositStartScreen>
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
    Future.microtask(() {
      if (!mounted) return;
      final vm = context.read<DepositStartViewModel>();
      vm.startDeposit(atmId: widget.atmId);
    });
  }

  @override
  void didPopNext() {
    Future.microtask(() {
      if (!mounted) return;
      final vm = context.read<DepositStartViewModel>();
      vm.startDeposit(atmId: widget.atmId);
    });
  }

  Future<void> _handleCountDeposit() async {
    final vm = context.read<DepositStartViewModel>();
    final countedAmount = await vm.countDeposit(atmId: widget.atmId);

    if (!mounted) return;
    if (vm.errorMessage != null) {
      // Show error in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage!),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _handleCountDeposit,
          ),
        ),
      );
    } else if (countedAmount != null) {
      // Navigate to confirmation screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DepositConfirmationScreen(
            atmId: widget.atmId,
            amount: countedAmount,
          ),
        ),
      );
    } else {
      debugPrint('Counted amount is null despite no error message.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DepositStartViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Insert your cash into the ATM, then press the button below to count it.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              vm.isCounting
                  ? const Column(
                      children: [
                        CircularProgressIndicator(color: brandRed),
                        SizedBox(height: 12),
                        Text(
                          'Counting deposit...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  : AppButton(
                      text: 'Count Deposit',
                      onPressed: _handleCountDeposit,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
