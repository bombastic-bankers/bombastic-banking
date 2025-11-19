import 'package:flutter/material.dart';
import '../app_constants.dart';
import 'choice_page.dart';
import 'transaction_flow_pages.dart';
// Import the AuthService and UserInfo model
import '../services/auth_service.dart';

/// -------------------- Home Page --------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  UserInfo? _userInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  /// Fetches the user's name and account balance on page load.
  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final info = await AuthService().fetchUserInfo();
      setState(() {
        _userInfo = info;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load user data: ${e.toString().split('Exception: ').last}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    if (index == 2) {
      // ATM Services > ChoicePage
      Navigator.push(context, slideRoute(const ChoicePage()));
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Content for the Home tab (index 0)
    Widget homeContent;

    if (_isLoading) {
      homeContent = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      homeContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchUserInfo,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else {
      // Data loaded successfully
      final String displayName = _userInfo?.fullName ?? 'User';
      final num balance = _userInfo?.accountBalance ?? 0;

      homeContent = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $displayName',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Good morning', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions 
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _quickAction(Icons.money_outlined, 'Withdraw'),
                  _quickAction(Icons.account_balance_wallet_outlined, 'Deposit'),
                  _quickAction(Icons.payment_outlined, 'Pay'),
                  _quickAction(Icons.swap_horiz_outlined, 'Transfer'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: brandRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Savings Account', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('$balance',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            // Transaction History
            const SizedBox(height: 24),
            const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _transactionItem('Grocery Store', '-\$54.20', 'Nov 15, 2025'),
            _transactionItem('Salary Credit', '+\$3,200.00', 'Nov 14, 2025'),
            _transactionItem('Electricity Bill', '-\$120.50', 'Nov 12, 2025'),
            _transactionItem('Coffee Shop', '-\$8.75', 'Nov 11, 2025'),
          ],
        ),
      );
    }

    final List<Widget> pages = [
      homeContent, // The dynamic Home content
      const Center(child: Text('Plan Page (Placeholder)')),
      const SizedBox.shrink(), // ATM Services handled by nav tap
      const Center(child: Text('Pay & Transfer Page (Placeholder)')),
      const Center(child: Text('Rewards Page (Placeholder)')),
      const Center(child: Text('More Page (Placeholder)')),
    ];

    return Scaffold(
      appBar: _selectedIndex != 0 
          ? AppBar(title: Text(_getAppBarTitle(_selectedIndex)))
          : null,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: brandRed,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.local_atm_outlined), label: 'ATM Services'),
          BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), label: 'Pay & Transfer'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 1: return 'Plan';
      case 3: return 'Pay & Transfer';
      case 4: return 'Rewards';
      case 5: return 'More';
      default: return '';
    }
  }

  Widget _quickAction(IconData icon, String label) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (label == 'Withdraw') {
              Navigator.push(context, slideRoute(const WithdrawStep1()));
            }
            if (label == 'Deposit') {
              Navigator.push(context, slideRoute(const DepositStep1()));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: brandRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: brandRed, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _transactionItem(String title, String amount, String date) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date, style: const TextStyle(color: Colors.grey)),
        trailing: Text(
          amount,
          style: TextStyle(
            color: amount.startsWith('-') ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
