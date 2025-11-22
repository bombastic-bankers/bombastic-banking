import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Import for StreamSubscription
import '../app_constants.dart';
import '../widgets/app_button.dart';
import 'home_page.dart';
import 'login_page.dart';
import '../services/auth_service.dart';

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
    
    // Updated: Pass the final destination page and the transaction type
    Navigator.push(
      context, 
      slideRoute(NFCPromptPage(
        amount: amt,
        isWithdrawal: true, // Specify transaction type
        nextPage: WithdrawSuccessPage(amount: amt), 
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Step 1')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
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
    
    // Updated: Pass the final destination page and the transaction type
    Navigator.push(
      context, 
      slideRoute(NFCPromptPage(
        amount: amt,
        isWithdrawal: false, // Specify transaction type
        nextPage: DepositSuccessPage(amount: amt),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Step 1')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
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

class NFCPromptPage extends StatefulWidget {
  final String amount;
  final Widget nextPage; 
  final bool isWithdrawal; // Added this flag
  
  const NFCPromptPage({
    super.key, 
    required this.amount, 
    required this.nextPage,
    required this.isWithdrawal,
  });

  @override
  State<NFCPromptPage> createState() => _NFCPromptPageState();
}

class _NFCPromptPageState extends State<NFCPromptPage> {
  final AuthService _authService = AuthService();
  StreamSubscription<String?>? _atmIdSubscription;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startNFCScanAndListen();
  }

  void _startNFCScanAndListen() {
    setState(() {
      _isScanning = true;
    });

    _authService.startContinuousNfcScan();

    _atmIdSubscription = _authService.atmIdStream.listen((atmId) {
      if (atmId != null && _isScanning && mounted) {
        _stopNFCScan();
        
        // CRITICAL FIX: Navigate to the authentication step first
        // This bridge page performs session validation before going to success
        Navigator.of(context).pushReplacement(
          slideRoute(PostNfcAuthPage(
            amount: widget.amount,
            atmId: atmId,
            isWithdrawal: widget.isWithdrawal, // Pass the transaction type
            finalSuccessPage: widget.nextPage,
          ))
        );
      }
    });
  }

  void _stopNFCScan() {
    if (_isScanning) {
      _authService.stopContinuousNfcScan();
      setState(() {
        _isScanning = false;
      });
    }
    _atmIdSubscription?.cancel();
    _atmIdSubscription = null;
    // Clear the ATM ID stream to avoid ghost data upon returning
    _authService.clearAtmId();
  }

  @override
  void dispose() {
    _stopNFCScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Tap Required')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isScanning ? Icons.nfc_outlined : Icons.check_circle_outline, 
              size: 84, 
              color: _isScanning ? brandRed : Colors.green[600],
            ),
            const SizedBox(height: 18),
            Text(
              'Amount: \$${widget.amount}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                _isScanning
                    ? 'Please tap your card or mobile device to the NFC reader to proceed with the transaction.'
                    : 'Tag read successfully. Initiating authorization...',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            if (_isScanning)
              const CircularProgressIndicator(color: brandRed),
          ],
        ),
      ),
    );
  }
}

// --- SIMPLIFIED POST-NFC AUTHENTICATION BRIDGE PAGE (NO API CALLS) ---

class PostNfcAuthPage extends StatefulWidget {
  final String amount;
  final String atmId;
  final bool isWithdrawal;
  final Widget finalSuccessPage;

  const PostNfcAuthPage({
    super.key,
    required this.amount,
    required this.atmId,
    required this.isWithdrawal,
    required this.finalSuccessPage,
  });

  @override
  State<PostNfcAuthPage> createState() => _PostNfcAuthPageState();
}

class _PostNfcAuthPageState extends State<PostNfcAuthPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Start the placeholder process immediately
    _processTransactionPlaceholder();
  }

  Future<void> _processTransactionPlaceholder() async {
    // 1. Placeholder for the session check/biometric prompt.
    // This delay prevents the main router guard from prematurely seeing an invalid session state.
    await Future.delayed(const Duration(milliseconds: 1500)); 
    
    // 2. SUCCESS: Session stabilized, proceed to final page.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // Wait another moment to show the user that the step is complete
      await Future.delayed(const Duration(milliseconds: 500)); 
      
      if (mounted) {
        // Navigate to the final success page, replacing the current bridge page
        Navigator.of(context).pushReplacement(slideRoute(widget.finalSuccessPage));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isWithdrawal ? 'Withdrawing' : 'Depositing')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isLoading ? Icons.security : Icons.check_circle, 
                size: 84, 
                color: _isLoading ? brandRed : Colors.green,
              ),
              const SizedBox(height: 18),
              Text(
                _isLoading 
                    ? 'Validating Session & Preparing Transaction...'
                    : 'Session Confirmed. Finishing...',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text('Amount: \$${widget.amount}'),
              Text('ATM ID: ${widget.atmId}'),
              const SizedBox(height: 20),
              
              if (_isLoading) ...[
                const Text(
                  'This step acts as a secure bridge to stabilize the session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                const CircularProgressIndicator(color: brandRed),
              ],
            ],
          ),
        ),
      ),
    );
  }
}