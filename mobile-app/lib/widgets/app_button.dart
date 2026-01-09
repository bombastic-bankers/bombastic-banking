import 'package:flutter/material.dart';
import '../app_constants.dart';

/// Reusable button
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? height;
  final Color? color;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? brandRed;
    return SizedBox(
      width: double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
