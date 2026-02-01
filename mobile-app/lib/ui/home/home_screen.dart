import 'package:bombastic_banking/route_observer.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_start/deposit_start_screen.dart';
import 'package:bombastic_banking/ui/atm_services/nfc_prompt/nfc_prompt_widget.dart';
import 'package:bombastic_banking/ui/atm_services/withdraw_amount/withdraw_amount_screen.dart';
import 'package:bombastic_banking/ui/transactions/transactions_screen.dart';
import 'package:bombastic_banking/ui/home/home_viewmodel.dart';
import 'package:bombastic_banking/ui/home/quick_action_widget.dart';
import 'package:bombastic_banking/ui/login/login_screen.dart';
import 'package:intl/intl.dart';
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Text(
                  'Most recent transactions',
                  style: TextStyle(
                    fontSize: 18, // Slightly bigger title
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Subtitle
              const Padding(
                padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
                child: Text(
                  'Up to 50 (last 7 days only)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              // The "Clean" Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Rounded corners like Trans Page
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12), // Soft Shadow
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (vm.recentTransactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No recent transactions'),
                      )
                    else
                      Column(
                        children: vm.recentTransactions.map((t) {
                          // Logic
                          final amount = double.tryParse(t.myChange) ?? 0.0;
                          final userAmount = amount * -1;
                          final formattedAmount = userAmount.toStringAsFixed(2);
                          final displayAmount = userAmount > 0
                              ? "+$formattedAmount"
                              : formattedAmount;

                          final dateLabel = DateFormat(
                            'd MMM',
                          ).format(t.timestamp);

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 24.0,
                            ), // Clean spacing
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left Side: Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Date (Small top label)
                                      Text(
                                        dateLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Category (Tiny)
                                      Text(
                                        "NETS QR",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      // Merchant (Bold Black)
                                      Text(
                                        t.type == 'transfer'
                                            ? (t.counterpartyName ?? 'Transfer')
                                            : t.type == 'atm'
                                            ? amount > 0
                                                  ? "Withdrawal"
                                                  : "Deposit"
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          height: 1.4,
                                        ),
                                      ),

                                      // Description (Grey)
                                      Text(
                                        t.description ?? "Transaction",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Right Side: Amount
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12.0,
                                    top: 12.0,
                                  ),
                                  child: Text(
                                    displayAmount,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: amount > 0
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(
                                              context,
                                            ).colorScheme.tertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    // View More Link
                    const Divider(height: 1, color: Colors.black12),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsScreen(),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text(
                        'View More',
                        style: TextStyle(
                          color: Color(0xFF5D6BD4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
