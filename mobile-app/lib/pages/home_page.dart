import 'package:flutter/material.dart';
import '../app_constants.dart';
import 'choice_page.dart';
import 'transaction_flow_pages.dart';

/// -------------------- Home Page --------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
    final List<Widget> pages = [
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Hello, John',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Good morning', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 20),

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
                children: const [
                  Text('Savings Account', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                  Text('\$12,345.67',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            // Transaction History
            const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _transactionItem('Grocery Store', '-\$54.20', 'Nov 15, 2025'),
            _transactionItem('Salary Credit', '+\$3,200.00', 'Nov 14, 2025'),
            _transactionItem('Electricity Bill', '-\$120.50', 'Nov 12, 2025'),
            _transactionItem('Coffee Shop', '-\$8.75', 'Nov 11, 2025'),
          ],
        ),
      ),
      const Center(child: Text('Plan Page (Placeholder)')),
      const SizedBox.shrink(), // ATM Services handled by nav tap
      const Center(child: Text('Pay & Transfer Page (Placeholder)')),
      const Center(child: Text('Rewards Page (Placeholder)')),
      const Center(child: Text('More Page (Placeholder)')),
    ];

    return Scaffold(
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
              color: brandRed.withValues(), // Using withOpacity instead of withValues()
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.money_outlined, color: Colors.white, size: 28), // Simplified icon logic
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