import 'package:bombastic_banking/ui/atm_services/deposit_start/deposit_start_screen.dart';
import 'package:bombastic_banking/ui/atm_services/nfc_prompt/nfc_prompt_widget.dart';
import 'package:bombastic_banking/ui/atm_services/withdraw_amount/withdraw_amount_screen.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';

class ATMServicesScreen extends StatelessWidget {
  const ATMServicesScreen({super.key});

  Future<void> _handleDeposit(BuildContext context) async {
    final atmId = await showModalBottomSheet<int>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const NFCPromptWidget(),
    );
    if (atmId != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DepositStartScreen(atmId: atmId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ATM Services')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: double.infinity,
                height: 50,
                child: Text(
                  'Choose the service you would like to proceed with',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 32),

              AppButton(
                text: 'Withdraw',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WithdrawAmountScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              AppButton(
                text: 'Deposit',
                onPressed: () => _handleDeposit(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
