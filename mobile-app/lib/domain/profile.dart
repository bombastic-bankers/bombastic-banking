class Profile {
  final String name;
  final String email;
  final String phone;

  Profile({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      name: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phoneNumber'] ?? '',
    );
  }
}