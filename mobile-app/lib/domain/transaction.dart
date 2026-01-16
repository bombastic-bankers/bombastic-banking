class Transaction {
  final int id;
  final DateTime timestamp;
  final String? description;
  final String myChange;
  final int? counterpartyUserId;
  final String? counterpartyName;
  final bool? counterpartyIsInternal;

  const Transaction({
    required this.id,
    required this.timestamp,
    this.description,
    required this.myChange,
    this.counterpartyUserId,
    this.counterpartyName,
    this.counterpartyIsInternal,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['transactionId'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      myChange: json['myChange'],
      counterpartyUserId: json['counterpartyUserId'],
      counterpartyName: json['counterpartyName'],
      counterpartyIsInternal: json['counterpartyIsInternal'],
    );
  }
}
