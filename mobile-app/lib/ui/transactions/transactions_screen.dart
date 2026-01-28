import 'package:bombastic_banking/domain/transaction.dart';
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
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Transaction history',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Month Selectors (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: vm.pastSixMonths.map((month) {
                  final bool isSelected = vm.selectedMonth == month;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ElevatedButton(
                      onPressed: () => vm.selectMonth(month),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFFE50513) // Bombastic Red
                            : Colors.white,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.grey,
                        elevation: 0,
                        shape: const StadiumBorder(), // Capsule shape
                        side: isSelected
                            ? BorderSide.none
                            : const BorderSide(color: Colors.grey, width: 0.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        DateFormat.yMMM().format(month),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Transaction List
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                  ? Center(child: Text(vm.errorMessage!))
                  : dayKeys.isEmpty
                  ? const Center(child: Text('No transactions this month'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: dayKeys.length,
                      itemBuilder: (context, index) {
                        final day = dayKeys[index];
                        final items = grouped[day] ?? [];
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
    // Format: "12 Dec"
    final label = DateFormat('d MMM').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header inside the card
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Transactions List
          ...transactions.map((t) {
            // Logic: Parse amount and flip sign for User View
            final amount = double.tryParse(t.myChange) ?? 0.0;
            final userAmount = amount * -1;
            final formattedAmount = userAmount.toStringAsFixed(2);
            // Add '+' only if positive
            final displayAmount = userAmount > 0
                ? "+$formattedAmount"
                : formattedAmount;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 24.0,
              ), // Spacing between items
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT SIDE: Description & Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NETS QR", // You can replace this with a Category if you have one
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
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
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          t.description ?? "Transaction",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RIGHT SIDE: Amount
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      displayAmount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: amount > 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
