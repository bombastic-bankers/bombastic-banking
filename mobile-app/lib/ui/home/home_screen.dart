import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/pages/transaction_flow_pages.dart';
import 'package:bombastic_banking/ui/home/home_viewmodel.dart';
import 'package:bombastic_banking/ui/home/quick_action_widget.dart';
import 'package:bombastic_banking/ui/home/transaction_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final vm = context.read<HomeViewModel>();
    if (vm.userLoaded) return;
    vm.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${vm.user?.fullName ?? ''}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Good morning',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Quick actions
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    QuickAction(
                      icon: Icons.money_outlined,
                      label: 'Withdraw',
                      onPressed: () => Navigator.push(
                        context,
                        slideRoute(const WithdrawStep1()),
                      ),
                    ),
                    QuickAction(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Deposit',
                      onPressed: () => Navigator.push(
                        context,
                        slideRoute(const DepositNFCPromptPage()),
                      ),
                    ),
                    QuickAction(
                      icon: Icons.payment_outlined,
                      label: 'Pay',
                      onPressed: () {},
                    ),
                    QuickAction(
                      icon: Icons.swap_horiz_outlined,
                      label: 'Transfer',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bombastic Account',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '\$${vm.user?.accountBalance.toStringAsFixed(2) ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Transaction history
              TransactionItem(
                title: 'Grocery Store',
                amount: -54.20,
                date: DateTime(2025, 11, 15),
              ),
              TransactionItem(
                title: 'Salary Credit',
                amount: 3200.00,
                date: DateTime(2025, 11, 14),
              ),
              TransactionItem(
                title: 'Electricity Bill',
                amount: -120.50,
                date: DateTime(2025, 11, 12),
              ),
              TransactionItem(
                title: 'Coffee Shop',
                amount: -8.75,
                date: DateTime(2025, 11, 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
