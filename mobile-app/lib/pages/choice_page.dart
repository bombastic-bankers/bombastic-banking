import 'package:flutter/material.dart';
import '../app_constants.dart';
import '../widgets/app_button.dart';
import 'transaction_flow_pages.dart';

/// -------------------- Choice Page --------------------
class ChoicePage extends StatelessWidget {
  const ChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ATM Services')),
      // Padding is reduced from 64 to 32 to give more screen width to the buttons
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
              // AppButton now automatically uses double.infinity width
              AppButton(
                text: 'Withdraw',
                onPressed: () => Navigator.push(context, slideRoute(const WithdrawStep1())),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Deposit',
                onPressed: () => Navigator.push(context, slideRoute(const DepositStep1())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}