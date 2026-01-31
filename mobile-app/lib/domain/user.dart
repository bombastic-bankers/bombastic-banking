class User {
  final String fullName;
  final num accountBalance;
  final String? phoneNumber;

  User({
    required this.fullName,
    required this.accountBalance,
    this.phoneNumber,
  });

  String get initials {
    if (fullName.isEmpty) return "?";
    return fullName[0].toUpperCase();
  }
}
