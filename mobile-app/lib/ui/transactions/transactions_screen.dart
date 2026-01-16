import 'package:bombastic_banking/domain/transaction.dart';
import 'package:bombastic_banking/ui/home/transaction_item_widget.dart';
import 'package:bombastic_banking/ui/transactions/transactions_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requested) return;
    _requested = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsViewModel>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionsViewModel>();
    final grouped = vm.groupedByDay;
    final dayKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction history',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 13,
                  children: vm.pastSixMonths.map((month) {
                    final bool isSelected = vm.selectedMonth == month;
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onPressed: () {
                        vm.selectMonth(month);
                      },
                      child: Text(
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        DateFormat.yMMM().format(month),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              if (vm.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (vm.errorMessage != null)
                Expanded(child: Center(child: Text(vm.errorMessage!)))
              else if (dayKeys.isEmpty)
                const Expanded(
                  child: Center(child: Text('No transactions this month')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: dayKeys.length,
                    itemBuilder: (context, index) {
                      final day = dayKeys[index];
                      final items = grouped[day] ?? const <Transaction>[];

                      return _TransactionDaySection(
                        date: day,
                        transactions: items,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionDaySection extends StatelessWidget {
  final DateTime date;
  final List<Transaction> transactions;

  const _TransactionDaySection({
    required this.date,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.yMMMMd().format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          ...transactions.map(
            (t) => TransactionItem(
              timestamp: t.timestamp,
              description: t.description,
              myChange: t.myChange,
              counterpartyName: t.counterpartyName,
            ),
          ),
        ],
      ),
    );
  }
}
