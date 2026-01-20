import '../services/agent_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';

class TokenRepository {
  final TokenService _tokenService;
  final SecureStorage _secureStorage;

  TokenRepository({
    required TokenService tokenService,
    required SecureStorage secureStorage,
  }) : _tokenService = tokenService,
       _secureStorage = secureStorage;
  Future<String> getConversationToken() async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) {
      throw Exception('Missing session token');
    }
    return await _tokenService.fetchWebRtcToken(sessionToken: sessionToken);
  }
}
