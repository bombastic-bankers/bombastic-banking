import 'package:bombastic_banking/domain/user.dart';
import 'package:bombastic_banking/services/user_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';

class UserRepository {
  final UserService _userService;
  final SecureStorage _secureStorage;

  UserRepository({
    required UserService userService,
    required SecureStorage secureStorage,
  }) : _userService = userService,
       _secureStorage = secureStorage;

  Future<User> getUser() async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) {
      throw Exception('Missing session token');
    }

    final user = await _userService.getUser(sessionToken);
    return User(fullName: user.fullName, accountBalance: user.accountBalance);
  }
}
