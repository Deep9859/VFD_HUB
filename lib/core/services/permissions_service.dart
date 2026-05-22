import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> ensureCamera() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final result = await Permission.camera.request();
    return result.isGranted;
  }

  static Future<bool> ensureMicrophone() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }
}
