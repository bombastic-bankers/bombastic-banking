import 'package:bombastic_banking/ui/atm_services/nfc_prompt/nfc_prompt_screen.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WithdrawAmountScreen extends StatefulWidget {
  const WithdrawAmountScreen({super.key});

  @override
  State<WithdrawAmountScreen> createState() => _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState extends State<WithdrawAmountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();

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
              ),
            ),

            const SizedBox(height: 24),

            AppButton(
              text: 'Next',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NFCPromptScreen(
                        transaction: Withdrawal(double.parse(_amount.text)),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
