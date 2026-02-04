import 'package:bombastic_banking/services/profile_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';
import 'package:bombastic_banking/domain/profile.dart';

class ProfileRepository {
  final ProfileService _profileService;
  final SecureStorage _secureStorage;

  ProfileRepository({
    required ProfileService profileService,
    required SecureStorage secureStorage,
  }) : _profileService = profileService,
       _secureStorage = secureStorage;

  Future<Profile> getProfileData() async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) throw Exception('Missing session token');

    return await _profileService.getProfile(sessionToken);
  }

  Future<void> updateProfile(Profile updateData) async {
    final sessionToken = await _secureStorage.getSessionToken();
    if (sessionToken == null) throw Exception('Missing session token');

    await _profileService.updateProfile(sessionToken, updateData);
  }
}