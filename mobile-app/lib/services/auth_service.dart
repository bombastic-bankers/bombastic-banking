import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart'; 
// Import the separated secure storage service (assuming it exists)
import 'secure_storage_service.dart'; 

// --- PLATFORM CHANNEL SETUP ---
// This channel name MUST match the CHANNEL constant in MainActivity.kt
const MethodChannel _channel = MethodChannel('com.ocbc.nfc_service/methods'); 

/// The main authentication and state management service class.
/// This acts as a **Singleton** to maintain global state consistency across the application.
class AuthService {
  // Singleton pattern implementation
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  AuthService._internal() {
    // 1. Set up the Method Call Handler to receive data from Native (Kotlin)
    _channel.setMethodCallHandler(_handleNativeCall);
    debugPrint('AuthService: Native Method Channel listener initialized.');
  }

  final SecureStorageService _storageService = SecureStorageService();
  
  // --- Global ATM ID State Management ---
  
  // Stream to notify listeners about new ATM ID scans
  final StreamController<String?> _atmIdController = StreamController<String?>.broadcast();
  
  // Public stream for widgets to listen to
  Stream<String?> get atmIdStream => _atmIdController.stream;
  
  // Public getter for the current ATM ID from storage
  Future<String?> get currentAtmId => _storageService.getAtmId(); 

  // --- CRITICAL FIX: Method to clear the stream event ---
  /// Immediately clears the ATM ID event from the stream by pushing a null value.
  void clearAtmId() {
    if (!_atmIdController.isClosed) {
      debugPrint('AuthService: ATM ID stream state cleared (pushed null).');
      _atmIdController.sink.add(null);
    }
  }

  // --- Foreground NFC Listener Setup (Commands) ---
  
  /// Starts actively listening for NFC tag taps while the app is in the **foreground**.
  /// This command tells the native Android Activity to enable Reader Mode.
  void startContinuousNfcScan() { 
    debugPrint('AuthService: NFC Platform Listener Setup Initiated (Foreground Mode).');
    
    // Call native code to ENABLE reader mode using the Platform Channel.
    try {
      _channel.invokeMethod('enableReaderMode');
      debugPrint('AuthService: Sent command to ENABLE native NFC Reader Mode.');
    } on PlatformException catch (e) {
      debugPrint("AuthService Error: Failed to enable NFC reader mode: ${e.message}");
    }
  }

  /// Stops the continuous foreground NFC scanner.
  void stopContinuousNfcScan() {
    debugPrint('AuthService: Stopping continuous NFC Scan (Foreground Mode).');
    // Call native code to DISABLE reader mode using the Platform Channel.
    try {
      _channel.invokeMethod('disableReaderMode');
      debugPrint('AuthService: Sent command to DISABLE native NFC Reader Mode.');
    } on PlatformException catch (e) {
      debugPrint("AuthService Error: Failed to disable NFC reader mode: ${e.message}");
    }
  }

  // --- NFC LISTENER (Receives data from Kotlin) ---
  
  /// Handles incoming method calls from the native platform channel (Kotlin/Swift).
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    // Looks for the 'tagRead' method call that Kotlin sends back
    if (call.method == 'tagRead') {
      final String? atmId = call.arguments as String?;
      if (atmId != null) {
         // Route the received ATM ID to the internal handler
         await _handleNfcTagRead(atmId);
      }
      return true;
    }
    return null;
  }

  /// This method is designed to be called by the native platform channel code 
  /// when an ATM NFC tag is successfully read in the **foreground** reader session.
  /// It stores the ID and notifies all Flutter listeners.
  Future<void> _handleNfcTagRead(String? atmId) async {
    if (atmId != null) {
      await _storageService.saveAtmId(atmId);
      if (!_atmIdController.isClosed) {
        _atmIdController.sink.add(atmId);
        debugPrint('Continuous Scan Success: ATM ID $atmId pushed to stream.');
      }
    }
  }
  
  // --- Authentication and Single NFC Read (used in transaction flow) ---

  /// Mocks the network API call to the OCBC login endpoint.
  Future<String> login(String username, String password) async {
    // Retaining delay to simulate network latency
    await Future.delayed(const Duration(seconds: 2));

    const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJvY2JjLXNnX3VzZXIxMjMiLCJpc3MiOiJvYmNjLXNnIiwiaWF0IjoxNjczMDgwODAwfQ.S9J8K0Ld_3Z3xY7T7P0mD4v2o5tE2cM1jI6P4QZ9Y1M';
    await _storageService.saveToken(mockToken);

    return mockToken;
  }

  /// Initiates a single, explicit NFC reading event and extracts the ATM ID.
  Future<String> readNfcTag() async {
    debugPrint('Single NFC Scan initiated (Platform Channel)...');
    
    // Placeholder to satisfy return type while removing simulation
    const placeholderAtmId = "OCBC-ATM-SG-90210"; 
    
    // Simulating successful native read for function completion
    await _storageService.saveAtmId(placeholderAtmId);

    return placeholderAtmId;
  }

  /// Helper to retrieve the token for future API calls
  Future<String?> getAuthToken() => _storageService.getToken();

  /// Disposes of all resources held by the service.
  void dispose() {
    _atmIdController.close();
    // Stop the foreground platform listeners during disposal
    stopContinuousNfcScan(); 
    debugPrint('AuthService disposed.');
  }
}