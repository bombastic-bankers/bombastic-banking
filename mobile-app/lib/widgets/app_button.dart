import 'package:flutter/material.dart';
import '../app_constants.dart';

/// Reusable button
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  
  // To handle the full width requirement, we remove the fixed width in the SizedBox 
  // and let it take the full width available from its parent (usually controlled by padding).
  const AppButton({super.key, required this.text, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? brandRed;
    return SizedBox(
      width: double.infinity, // Set width to take full available space
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
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