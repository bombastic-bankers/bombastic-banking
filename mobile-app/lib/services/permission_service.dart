import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> isPermanentlyDenied() async {
    return await Permission.microphone.isPermanentlyDenied;
  }
}
