import 'package:flutter/foundation.dart';

class NavbarRootViewModel extends ChangeNotifier {
  var _index = 0;
  int get index => _index;
  set index(int i) {
    _index = i;
    notifyListeners();
  }
}
