import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    // For Android 13+ (API 33+), we use READ_MEDIA_* permissions
    // But image_gallery_saver often handles saving.
    // We'll request photos permission for iOS/Android 13+
    if (await Permission.photos.isLimited ||
        await Permission.photos.isGranted) {
      return true;
    }
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.camera,
      Permission.locationWhenInUse,
      Permission.microphone,
      Permission.photos,
    ].request();
  }
}
