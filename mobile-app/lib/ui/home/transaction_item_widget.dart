import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final DateTime timestamp;
  final String? description;
  final String myChange;
  final String? counterpartyName;

  const TransactionItem({
    super.key,
    required this.timestamp,
    this.description,
    required this.myChange,
    this.counterpartyName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          description ?? 'No description',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(timestamp),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          "\$ $myChange",
          style: TextStyle(
            color: myChange.startsWith('-')
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
