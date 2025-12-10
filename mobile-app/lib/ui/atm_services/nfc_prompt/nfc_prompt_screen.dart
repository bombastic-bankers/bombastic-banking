import 'package:bombastic_banking/ui/atm_services/nfc_prompt/nfc_prompt_viewmodel.dart';
import 'package:bombastic_banking/ui/atm_services/withdrawing/withdrawing_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

sealed class TransactionType {}

class Withdrawal extends TransactionType {
  final double amount;
  Withdrawal(this.amount);
}

class Deposit extends TransactionType {}

class NFCPromptScreen extends StatefulWidget {
  final TransactionType transaction;

  const NFCPromptScreen({super.key, required this.transaction});

  @override
  State<NFCPromptScreen> createState() => _NFCPromptScreenState();
}

class _NFCPromptScreenState extends State<NFCPromptScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final vm = context.read<NFCPromptViewModel>();
    vm.startReading();

    vm.atmTags.first.then((tag) {
      vm.stopReading();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => widget.transaction is Withdrawal
              ? WithdrawingScreen(
                  atmId: tag.id,
                  amount: (widget.transaction as Withdrawal).amount,
                )
              : Container(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<NFCPromptViewModel>().stopReading();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('NFC Tap Required')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nfc_outlined,
                size: 84,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 18),

              if (widget.transaction is Withdrawal)
                Text(
                  'Amount: \$${(widget.transaction as Withdrawal).amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Tap your phone on the ATM\'s NFC reader to proceed',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
