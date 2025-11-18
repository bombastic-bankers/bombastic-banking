import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

const Color brandRed = Color(0xFFEF1815);

void main() {
  runApp(const BankApp());
}

/// Slide transition helper
Route _slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (context, anim, secAnim, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: anim.drive(tween), child: child);
    },
  );
}

/// Reusable button
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

/// -------------------- Main App --------------------
class BankApp extends StatelessWidget {
  const BankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "OCBC Bank App",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: brandRed),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

/// -------------------- Login with Biometric --------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      setState(() {
        _biometricAvailable = canCheck && isDeviceSupported;
      });
    } catch (e) {
      setState(() => _biometricAvailable = false);
      print('Error checking biometrics: $e');
    }
  }

  Future<void> _authenticate() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        );

      if (authenticated) {
        Navigator.pushReplacement(context, _slideRoute(const HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _biometricAvailable
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login with Fingerprint / Face ID',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    iconSize: 64,
                    icon: const Icon(Icons.fingerprint, color: brandRed),
                    onPressed: _authenticate,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Login with PIN',
                    onPressed: () => Navigator.pushReplacement(
                        context, _slideRoute(const HomePage())),
                  ),
                ],
              )
            : AppButton(
                text: 'Login',
                onPressed: () =>
                    Navigator.pushReplacement(context, _slideRoute(const HomePage())),
              ),
      ),
    );
  }
}

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
      Navigator.push(context, _slideRoute(const ChoicePage()));
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Navigator.push(context, _slideRoute(const WithdrawStep1()));
            }
            if (label == 'Deposit') {
              Navigator.push(context, _slideRoute(const DepositStep1()));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: brandRed.withValues(),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255), size: 28),
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

/// -------------------- Choice Page --------------------
class ChoicePage extends StatelessWidget {
  const ChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make a Transaction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              text: 'Withdraw',
              onPressed: () => Navigator.push(context, _slideRoute(const WithdrawStep1())),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Deposit',
              onPressed: () => Navigator.push(context, _slideRoute(const DepositStep1())),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- Withdraw Flow --------------------
class WithdrawStep1 extends StatefulWidget {
  const WithdrawStep1({super.key});

  @override
  State<WithdrawStep1> createState() => _WithdrawStep1State();
}

class _WithdrawStep1State extends State<WithdrawStep1> {
  final _controller = TextEditingController();

  void _next() {
    final amt = _controller.text.trim();
    if (amt.isEmpty) return;
    Navigator.push(context, _slideRoute(WithdrawStep2(amount: amt)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Step 1')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Enter amount to withdraw', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: '\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 18),
            AppButton(text: 'Next', onPressed: _next),
          ],
        ),
      ),
    );
  }
}

class WithdrawStep2 extends StatelessWidget {
  final String amount;
  const WithdrawStep2({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Step 2')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Confirm withdrawal: \$$amount', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            AppButton(
              text: 'Confirm & Finish',
              onPressed: () => Navigator.pushReplacement(
                context,
                _slideRoute(const ThankYouPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- Deposit Flow --------------------
class DepositStep1 extends StatefulWidget {
  const DepositStep1({super.key});

  @override
  State<DepositStep1> createState() => _DepositStep1State();
}

class _DepositStep1State extends State<DepositStep1> {
  final _controller = TextEditingController();

  void _next() {
    final amt = _controller.text.trim();
    if (amt.isEmpty) return;
    Navigator.push(context, _slideRoute(DepositStep2(amount: amt)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Step 1')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Enter amount to deposit', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: '\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 18),
            AppButton(text: 'Next', onPressed: _next),
          ],
        ),
      ),
    );
  }
}

class DepositStep2 extends StatelessWidget {
  final String amount;
  const DepositStep2({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Step 2')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Confirm deposit: \$$amount', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            AppButton(
              text: 'Confirm & Finish',
              onPressed: () => Navigator.pushReplacement(
                context,
                _slideRoute(const ThankYouPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- Thank You Page --------------------
class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 84, color: brandRed),
            const SizedBox(height: 18),
            const Text(
              'Thank you for banking with us!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Back to Home',
              onPressed: () => Navigator.pushReplacement(
                context,
                _slideRoute(const HomePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
