import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/ui/atm_services/nfc_prompt/nfc_prompt_widget.dart';
import 'package:bombastic_banking/ui/atm_services/transaction_complete/transaction_complete_screen.dart';
import 'package:bombastic_banking/ui/atm_services/withdrawing/withdrawing_viewmodel.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WithdrawAmountScreen extends StatefulWidget {
  const WithdrawAmountScreen({super.key});

  @override
  State<WithdrawAmountScreen> createState() => _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState extends State<WithdrawAmountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _handleWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amount.text);

    // Show NFC prompt bottom sheet
    final atmId = await showModalBottomSheet<int>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const NFCPromptWidget(),
    );
    if (atmId == null || !mounted) return;

    // Start processing
    setState(() => _isProcessing = true);

    final vm = context.read<WithdrawingViewModel>();
    await vm.withdraw(atmId: atmId, amount: amount);

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (vm.errorMessage == null) {
      // Navigate to completion screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TransactionCompleteScreen(
            transaction: CompletedWithdrawal(amount),
          ),
        ),
      );
    } else {
      // Show error in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage!),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _handleWithdrawal,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw amount')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Text(
              'Enter amount to withdraw',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 12),

            Form(
              key: _formKey,
              child: TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty || int.parse(value) <= 0
                    ? 'Enter a valid amount'
                    : null,
                enabled: !_isProcessing,
              ),
            ),

            const SizedBox(height: 24),

            _isProcessing
                ? const Column(
                    children: [
                      CircularProgressIndicator(color: brandRed),
                      SizedBox(height: 12),
                      Text(
                        'Processing withdrawal...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                : AppButton(text: 'Withdraw', onPressed: _handleWithdrawal),
          ],
        ),
      ),
    );
  }
}
