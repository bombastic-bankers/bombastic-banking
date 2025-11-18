import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_constants.dart';
import '../widgets/app_button.dart';
import 'home_page.dart';
import 'login_page.dart';

// --- Withdraw Flow ---

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
    
    Navigator.push(
      context, 
      slideRoute(NFCPromptPage(
        amount: amt,
        nextPage: WithdrawSuccessPage(amount: amt), 
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Step 1')),
      body: Padding(
        padding: const EdgeInsets.all(32.0), // Increased padding for consistency
        child: Column(
          children: [
            const Text('Enter amount to withdraw', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(prefixText: '\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            AppButton(text: 'Next', onPressed: _next),
          ],
        ),
      ),
    );
  }
}

class WithdrawSuccessPage extends StatelessWidget {
  final String amount;
  const WithdrawSuccessPage({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 84, color: brandRed),
              const SizedBox(height: 18),
              Text(
                '\$$amount successfully withdrawn!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              AppButton(
                color: const Color(0xFF495A63),
                text: 'Back to Home',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  slideRoute(const HomePage()),
                ),
              ),
              const SizedBox(height: 15),
              AppButton(
                color: const Color(0xFF495A63),
                text: 'Back to Login',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  slideRoute(const LoginPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Deposit Flow ---

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
    
    Navigator.push(
      context, 
      slideRoute(NFCPromptPage(
        amount: amt,
        nextPage: DepositSuccessPage(amount: amt),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Step 1')),
      body: Padding(
        padding: const EdgeInsets.all(32.0), // Increased padding for consistency
        child: Column(
          children: [
            const Text('Enter amount to deposit', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(prefixText: '\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            AppButton(text: 'Next', onPressed: _next),
          ],
        ),
      ),
    );
  }
}

class DepositSuccessPage extends StatelessWidget {
  final String amount;
  const DepositSuccessPage({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 84, color: brandRed),
              const SizedBox(height: 18),
              Text(
                '\$$amount successfully deposited!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              AppButton(
                color: const Color(0xFF495A63),
                text: 'Back to Home',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  slideRoute(const HomePage()),
                ),
              ),
              const SizedBox(height: 15),
              AppButton(
                color: const Color(0xFF495A63),
                text: 'Back to Login',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  slideRoute(const LoginPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- NFC Prompt Page ---

class NFCPromptPage extends StatelessWidget {
  final String amount;
  final Widget nextPage; 

  const NFCPromptPage({
    super.key, 
    required this.amount, 
    required this.nextPage,
  });

  Future<void> _startNFC(BuildContext context) async {
    // Simulate a delay for NFC scanning
    await Future.delayed(const Duration(seconds: 2)); 

    // On successful NFC scan, navigate to the final step
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        slideRoute(nextPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Automatically start NFC prompt when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNFC(context);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('NFC Tap Required')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nfc, size: 84, color: brandRed),
            const SizedBox(height: 18),
            Text(
              'Amount: \$$amount',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Please tap your card or mobile device to the NFC reader to proceed with the transaction.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: brandRed),
          ],
        ),
      ),
    );
  }
}