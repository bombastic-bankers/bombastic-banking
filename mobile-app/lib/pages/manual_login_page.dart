import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_constants.dart';
import '../widgets/app_button.dart';
import 'home_page.dart';
// Import the updated AuthService singleton
import '../services/auth_service.dart'; 

// -------------------- Manual PIN Login --------------------
class ManualLoginPage extends StatefulWidget {
  const ManualLoginPage({super.key});

  @override
  State<ManualLoginPage> createState() => _ManualLoginPageState();
}

class _ManualLoginPageState extends State<ManualLoginPage> {
  // 1. Text Controllers for input fields
  final _accessCodeController = TextEditingController();
  final _pinController = TextEditingController();

  // 2. State variables for UI feedback
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _accessCodeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  /// Authenticates the user by calling the AuthService.
  Future<void> _authenticate() async {
    // Clear previous error and show loading state
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final accessCode = _accessCodeController.text.trim();
    final pin = _pinController.text.trim();

    // Basic client-side validation
    if (accessCode.isEmpty || pin.isEmpty) {//pin.length != 6
      setState(() {
        _errorMessage = "Please enter a valid access code and 6-digit PIN.";
        _isLoading = false;
      });
      return;
    }

    try {
      // Calls the AuthService, which handles network request and token storage.
      await AuthService().authenticate(accessCode, pin);

      // If the service call completes without throwing an exception:
      if (mounted) {
        // Navigate to the HomePage and remove all previous routes.
        // This prevents the user from navigating back to the login screen using the back button.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // If the AuthService throws an exception (due to network error or 
      // API failure), display the error message.
      setState(() {
        // Tries to clean up the "Exception: " prefix from the error string
        _errorMessage = e.toString().contains('Exception: ') 
                        ? e.toString().split('Exception: ').last 
                        : 'Login failed. Please try again.';
      });
    } finally {
      // Ensure loading state is turned off regardless of success or failure
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using a placeholder color for the error message, assuming brandRed wasn't defined.
    // Replace Colors.red[700] with a properly defined constant if available.
    const Color errorColor = Color(0xFFCC0000); 

    return Scaffold(
      appBar: AppBar(
        // Allows user to return to the Biometric prompt
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: _accessCodeController, // Use controller
                  keyboardType: TextInputType.text,
                  maxLength: 50,
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(
                    labelText: 'Gmail or Access Code',
                    counterText: '', 
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // PIN Field (6 digits only)
              SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: _pinController, // Use controller
                  keyboardType: TextInputType.number,
                  maxLength: 10, //was 6
                  obscureText: true,
                  textAlign: TextAlign.left,
                  inputFormatters: [
                    // Enforces only digits 0-9
                    //FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Password or PIN',
                    counterText: '', 
                  ),
                ),
              ),
              
              const SizedBox(height: 30),

              // Error Message Display
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: errorColor, fontWeight: FontWeight.bold), 
                  ),
                ),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: _isLoading ? 'LOGGING IN...' : 'Login',
                  color: const Color(0xFF495A63),
                  // Use _authenticate method, provide a non-null VoidCallback and call the async method inside a void closure
                  onPressed: _isLoading ? () {} : () { _authenticate(); }, 
                ),
              ),
              const SizedBox(height: 20),
              const Text("Trouble logging in", style: TextStyle(color: Color.fromARGB(255, 49, 77, 136))),
            ],
          ),
        ),
      ),
    );
  }
}