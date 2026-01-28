import 'package:bombastic_banking/route_observer.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_start/deposit_start_screen.dart';
import 'package:bombastic_banking/ui/atm_services/nfc_prompt/nfc_prompt_widget.dart';
import 'package:bombastic_banking/ui/atm_services/withdraw_amount/withdraw_amount_screen.dart';
import 'package:bombastic_banking/ui/transactions/transactions_screen.dart';
import 'package:bombastic_banking/ui/home/home_viewmodel.dart';
import 'package:bombastic_banking/ui/home/quick_action_widget.dart';
import 'package:bombastic_banking/ui/home/transaction_item_widget.dart';
import 'package:bombastic_banking/ui/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
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
    final vm = context.read<HomeViewModel>();
    vm.refreshUser();
  }

  @override
  void didPopNext() {
    final vm = context.read<HomeViewModel>();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
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

                      Text('Good morning', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 24),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      await vm.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (_) => false,
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      alignment: Alignment.topCenter,
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),

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
                        MaterialPageRoute(
                          builder: (_) => const WithdrawAmountScreen(),
                        ),
                      ),
                    ),
                    QuickAction(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Deposit',
                      onPressed: () => _handleDeposit(context),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bombastic Account',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '\$${vm.user?.accountBalance.toStringAsFixed(2) ?? ''}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
                      ),
                    ),
                    child: const Text('See All'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Transaction history
              TransactionItem(
                type: 'NETS QR',
                title: 'Grocery Store',
                amount: -54.20,
                date: DateTime(2025, 11, 15),
              ),
              TransactionItem(
                type: 'GIRO',
                title: 'Salary Credit',
                amount: 3200.00,
                date: DateTime(2025, 11, 14),
              ),
              TransactionItem(
                type: 'GIRO',
                title: 'Electricity Bill',
                amount: -120.50,
                date: DateTime(2025, 11, 12),
              ),
              TransactionItem(
                type: "DEBIT PURCHASE",
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
}
