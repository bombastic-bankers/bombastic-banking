import 'package:bombastic_banking/domain/user.dart';
import 'package:bombastic_banking/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  User? user;
  var userLoaded = false;

  HomeViewModel({required UserRepository userRepository})
    : _userRepository = userRepository;

  /// Refreshes [user] from the repository, returning the updated user.
  Future<User> refreshUser() async {
    user = await _userRepository.getUser();
    userLoaded = true;
    notifyListeners();
    return user!;
  }
}
