import 'package:bombastic_banking/services/auth_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';

class AuthRepository {
  final AuthService _authService;
  final SecureStorage _secureStorage;

  AuthRepository({
    required AuthService authService,
    required SecureStorage secureStorage,
  }) : _secureStorage = secureStorage,
       _authService = authService;

  Future<bool> login(String email, String pin) async {
    try {
      final token = await _authService.login(email, pin);
      await _secureStorage.saveSessionToken(token);
      return true;
    } on InvalidCredentialsException {
      return false;
    }
  }
}
