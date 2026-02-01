import 'package:flutter/material.dart';
import 'package:bombastic_banking/repositories/profile_repository.dart';
import 'package:bombastic_banking/domain/profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({required ProfileRepository repository})
    : _repository = repository;

  Profile? profile;
  bool isLoading = false;
  bool isEditing = false;

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      profile = await _repository.getProfileData();
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(String name, String email, String phone) async {
    isLoading = true;
    notifyListeners();

    try {
      final updatedProfile = Profile(name: name, email: email, phone: phone);
      await _repository.updateProfile(updatedProfile);

      isEditing = false;
      await loadProfile();

      debugPrint("Profile synced successfully with Database");
    } catch (e) {
      debugPrint("Update failed: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
