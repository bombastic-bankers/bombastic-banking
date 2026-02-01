import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/domain/user.dart';
import 'package:bombastic_banking/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bombastic_banking/ui/transfer/input_amount_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _storage = const FlutterSecureStorage();

  final _userService = UserService(baseUrl: apiBaseUrl);

  List<User> _contacts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      setState(() => _isLoading = true);

      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setState(() {
          _errorMessage = "Permission to access contacts was denied";
          _isLoading = false;
        });
        return;
      }

      final realContacts = await FlutterContacts.getContacts(
        withProperties: true,
      );

      // Step C: Clean up phone numbers
      final List<String> phoneNumbersToCheck = realContacts
          .expand(
            (c) => c.phones.map(
              (p) => p.number.replaceAll(RegExp(r'[ ()\-]'), ''),
            ),
          )
          .where((number) => number.startsWith('+'))
          .toList();

      if (phoneNumbersToCheck.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = "No contacts found on your device.";
            _isLoading = false;
          });
        }
        return;
      }

      print("🔍 SENDING THESE NUMBERS TO SERVER: $phoneNumbersToCheck");

      final token = await _storage.read(key: 'session_token');
      if (token == null) throw Exception("No token found");

      final users = await _userService.findContacts(token, phoneNumbersToCheck);

      if (mounted) {
        setState(() {
          _contacts = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transfer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false, // Hides back button
      ),
      body: Column(
        children: [
          // Search Bar Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Search by name or mobile number',
              leading: const Icon(Icons.search, color: Colors.black54),
              backgroundColor: WidgetStateProperty.all(Colors.grey.shade200),
              elevation: WidgetStateProperty.all(0),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _contacts.isEmpty
                ? const Center(
                    child: Text(
                      "None of your contacts use Bombastic Banking yet.",
                    ),
                  )
                : ListView.separated(
                    itemCount: _contacts.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 16),
                    itemBuilder: (context, index) {
                      final user = _contacts[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blueGrey.shade700,
                          child: Text(
                            user.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user.phoneNumber ?? "No number"),
                        onTap: () {
                          // Navigate to Input Amount Screen, passing the selected user
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InputAmountScreen(recipient: user),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
