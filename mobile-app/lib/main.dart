import 'package:flutter/material.dart';
import 'app_constants.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const BankApp());
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