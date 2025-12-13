import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/route_observer.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_confirmation/deposit_confirmation_screen.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_counting/deposit_counting_viewmodel.dart';
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
  bool _isCounting = false;

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
    final vm = context.read<DepositStartViewModel>();
    vm.reset();
    vm.startDeposit(atmId: widget.atmId);
  }

  Future<void> _handleCountDeposit() async {
    setState(() => _isCounting = true);

    final countingVm = context.read<DepositCountingViewModel>();
    await countingVm.countDeposit(atmId: widget.atmId);

    if (!mounted) return;

    setState(() => _isCounting = false);

    if (countingVm.errorMessage != null) {
      // Show error in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(countingVm.errorMessage!),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _handleCountDeposit,
          ),
        ),
      );
    } else if (countingVm.countedAmount != null) {
      // Navigate to confirmation screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DepositConfirmationScreen(
            atmId: widget.atmId,
            amount: countingVm.countedAmount!,
          ),
        ),
      );
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
              if (!vm.isSuccess && vm.errorMessage == null) ...[
                const CircularProgressIndicator(color: brandRed),
                const SizedBox(height: 20),
                const Text(
                  'Initializing deposit session...',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ] else if (vm.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(0x1A),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red.shade700),
                  ),
                  child: Text(
                    vm.errorMessage!,
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
                    vm.reset();
                    vm.startDeposit(atmId: widget.atmId);
                  },
                ),
                const SizedBox(height: 15),
                AppButton(
                  color: const Color(0xFF495A63),
                  text: 'Cancel',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ] else ...[
                const Text(
                  'Insert your cash into the ATM, then press the button below to count it.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _isCounting
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
            ],
          ),
        ),
      ),
    );
  }
}
