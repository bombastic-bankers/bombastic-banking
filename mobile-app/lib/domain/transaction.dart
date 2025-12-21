class Transaction {
  final String id;
  final String type; // deposit, withdrawal, transfer
  final String title;
  final double amount;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
  });
}
