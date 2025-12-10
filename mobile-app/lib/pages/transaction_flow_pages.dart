// lib/pages/transaction_flow.dart

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
      slideRoute(
        WithdrawNFCPromptPage(
          amount: amt,
          isWithdrawal: true, // Specify transaction type
          nextPage: WithdrawSuccessPage(amount: amt),
        ),
      ),
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
            const Text(
              'Enter amount to withdraw',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
  final String? atmId; // From DepositNFCPromptPage after NFC scan
  final String amount; // Amount already counted

  const DepositStep1({super.key, required this.amount, this.atmId});

  @override
  State<DepositStep1> createState() => _DepositStep1State();
}

class _DepositStep1State extends State<DepositStep1> {
  final OldAuthService _authService = OldAuthService();

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  void _confirmDeposit() async {
    if (widget.atmId == null) {
      // If no ATM ID, go back to NFC prompt
      Navigator.push(
        context,
        slideRoute(DepositNFCPromptPage(amount: widget.amount)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await _authService.confirmDeposit(
        atmId: widget.atmId!,
        // amount: widget.amount,
      );

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(slideRoute(DepositSuccessPage(amount: widget.amount)));
    } catch (e) {
      String err = e.toString();
      if (err.startsWith('Exception: '))
        err = err.substring('Exception: '.length);
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${widget.amount} counted',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // --- ERROR BOX ---
            if (_hasError)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade700),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // --- confirm button/ throbber ---
            if (_isLoading)
              const CircularProgressIndicator(color: brandRed)
            else
              AppButton(text: 'Confirm Deposit', onPressed: _confirmDeposit),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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

// --- Deposit NFC Prompt Page ---

class DepositNFCPromptPage extends StatefulWidget {
  final String? amount; // optional: if you want to pass an amount prefilled

  const DepositNFCPromptPage({super.key, this.amount});

  @override
  State<DepositNFCPromptPage> createState() => _DepositNFCPromptPageState();
}

class _DepositNFCPromptPageState extends State<DepositNFCPromptPage> {
  final OldAuthService _authService = OldAuthService();
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

        // Navigate to DepositStep1 and pass atmId so we can confirm later
        Navigator.of(context).pushReplacement(
          slideRoute(
            DepositStep1(atmId: atmId, amount: '20'),
          ), // Pass hardcoded amount for now, need to implement counting notes
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
      appBar: AppBar(title: const Text('Tap Phone to Deposit')),
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
            if (widget.amount != null)
              Text(
                'Amount (prefilled): \$${widget.amount}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text(
                'Tap your card to start the deposit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                _isScanning
                    ? 'Please tap your card or mobile device to the NFC reader to capture the ATM.'
                    : 'Card detected. Proceeding to enter deposit amount...',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            if (_isScanning) const CircularProgressIndicator(color: brandRed),
          ],
        ),
      ),
    );
  }
}
// --- Withdraw NFC Prompt Page ---

class WithdrawNFCPromptPage extends StatefulWidget {
  final String amount;
  final Widget nextPage;
  final bool isWithdrawal;

  const WithdrawNFCPromptPage({
    super.key,
    required this.amount,
    required this.nextPage,
    required this.isWithdrawal,
  });

  @override
  State<WithdrawNFCPromptPage> createState() => _WithdrawNFCPromptPageState();
}

class _WithdrawNFCPromptPageState extends State<WithdrawNFCPromptPage> {
  final OldAuthService _authService = OldAuthService();
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

        Navigator.of(context).pushReplacement(
          slideRoute(
            PostNfcAuthPage(
              amount: widget.amount,
              atmId: atmId,
              isWithdrawal: widget.isWithdrawal, // Transaction type
              finalSuccessPage: widget.nextPage,
            ),
          ),
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
            if (_isScanning) const CircularProgressIndicator(color: brandRed),
          ],
        ),
      ),
    );
  }
}

// --- POST-NFC AUTHENTICATION BRIDGE PAGE ---

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
  final OldAuthService _authService = OldAuthService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _processTransaction();
  }

  Future<void> _processTransaction() async {
    try {
      await _authService.performTransaction(
        atmId: widget.atmId,
        amount: widget.amount,
        isWithdrawal: widget.isWithdrawal,
      );

      // SUCCESS
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await Future.delayed(const Duration(milliseconds: 700));

        if (mounted) {
          // Navigate to the final success page
          Navigator.of(
            context,
          ).pushReplacement(slideRoute(widget.finalSuccessPage));
        }
      }
    } catch (e) {
      if (mounted) {
        // error message extraction for cleaner display
        String errorText = e.toString();
        if (errorText.startsWith('Exception: ')) {
          errorText = errorText.substring('Exception: '.length);
        } else if (errorText.startsWith('SocketException: ')) {
          errorText = 'Network Error: Could not reach the ATM service.';
        }

        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = errorText;
          debugPrint('Transaction Failed: $_errorMessage');
        });
      }
    }
  }

  void _backToHome() {
    Navigator.of(context).pushReplacement(slideRoute(const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isWithdrawal ? 'Withdrawing' : 'Depositing';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isLoading
                    ? Icons.security
                    : (_hasError ? Icons.error_outline : Icons.check_circle),
                size: 84,
                color: _isLoading
                    ? brandRed
                    : (_hasError ? Colors.red : Colors.green),
              ),
              const SizedBox(height: 18),

              Text(
                _isLoading
                    ? 'Validating & Processing $title...'
                    : (_hasError
                          ? 'Transaction Failed!'
                          : 'Transaction Authorized.'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),
              Text('Amount: \$${widget.amount}'),
              Text('ATM ID: ${widget.atmId}'),
              const SizedBox(height: 20),

              if (_isLoading) ...[
                const Text(
                  'Securing connection with the ATM...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                const CircularProgressIndicator(color: brandRed),
              ] else if (_hasError) ...[
                // ERROR MESSAGE DISPLAY
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red.shade700),
                  ),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppButton(
                  text: 'Try Again',
                  onPressed: () {
                    // Reset state and retry transaction
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                      _errorMessage = '';
                    });
                    _processTransaction();
                  },
                ),
                const SizedBox(height: 15),
                AppButton(
                  color: const Color(0xFF495A63),
                  text: 'Cancel and Go Home',
                  onPressed: _backToHome,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
