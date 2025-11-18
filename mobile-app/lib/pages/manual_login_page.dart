import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_constants.dart';
import '../widgets/app_button.dart';
import 'home_page.dart';

// -------------------- Manual PIN Login --------------------
class ManualLoginPage extends StatelessWidget {
  const ManualLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Access Code Field (8 characters)
              SizedBox(
                width: double.infinity,
                child: TextField(
                  keyboardType: TextInputType.text,
                  maxLength: 8,
                  textAlign: TextAlign.left,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(14),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Access Code',
                    counterText: '', 
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // PIN Field (6 digits only)
              SizedBox(
                width: double.infinity,
                child: TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  textAlign: TextAlign.left,
                  inputFormatters: [
                    // Enforces only digits 0-9
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    counterText: '', 
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Login',
                  color: const Color(0xFF495A63),
                  onPressed: () {
                    // Placeholder: Navigate to HomePage on successful verification
                    Navigator.pushReplacement(
                      context,
                      slideRoute(const HomePage()),
                    );
                  },
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