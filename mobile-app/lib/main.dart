import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'app_constants.dart';

Future main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BankApp());
}

class BankApp extends StatefulWidget {
  const BankApp({super.key});

  @override
  State<BankApp> createState() => _BankAppState();
}

class _BankAppState extends State<BankApp> {
  // Flag to indicate when the initial token check is complete
  bool _isChecking = true;
  // Flag to hold the authentication result
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Checks for the existence of a secure token.
  Future<void> _checkAuthStatus() async {
    // Note: We need 'flutter/services.dart' for this file now.
    final token = await AuthService().getToken();

    if (mounted) {
      setState(() {
        _isAuthenticated = token != null;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;

    if (_isChecking) {
      // Show a loading indicator while checking the token
      initialScreen = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      // Route to the correct screen based on the check result
      if (_isAuthenticated) {
        initialScreen = const HomePage();
      } else {
        initialScreen = const LoginPage();
      }
    }

    return MaterialApp(
      title: 'Bombastic Banking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: brandRed),
        useMaterial3: true,
      ),
      // Set the home widget to the result of the authentication check
      home: initialScreen,
    );
  }
}
