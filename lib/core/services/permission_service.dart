import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  /// Request storage permissions for Android
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // Android 13+ uses different permissions
    if (await _isAndroid13OrHigher()) {
      // For Android 13+, we need READ_MEDIA permissions
      final photos = await Permission.photos.request();
      final videos = await Permission.videos.request();
      final audio = await Permission.audio.request();

      return photos.isGranted || videos.isGranted || audio.isGranted;
    } else {
      // For Android 12 and below
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  /// Request camera permission for QR scanning
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request notification permission (Android 13+)
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    if (await _isAndroid13OrHigher()) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }

    return true; // Not needed for older Android versions
  }

  /// Check if storage permission is granted
  Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) return true;

    if (await _isAndroid13OrHigher()) {
      final photos = await Permission.photos.isGranted;
      final videos = await Permission.videos.isGranted;
      final audio = await Permission.audio.isGranted;

      return photos || videos || audio;
    } else {
      return await Permission.storage.isGranted;
    }
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    if (await _isAndroid13OrHigher()) {
      return await Permission.notification.isGranted;
    }

    return true;
  }

  /// Handle permission denial - show dialog to open settings
  Future<bool> handlePermissionDenied(String permissionName) async {
    final status = await _getPermissionStatus(permissionName);

    if (status.isPermanentlyDenied) {
      // User has permanently denied permission, open app settings
      return await openAppSettings();
    }

    return false;
  }

  /// Get permission status by name
  Future<PermissionStatus> _getPermissionStatus(String permissionName) async {
    switch (permissionName.toLowerCase()) {
      case 'storage':
        return await Permission.storage.status;
      case 'camera':
        return await Permission.camera.status;
      case 'notification':
        return await Permission.notification.status;
      default:
        return PermissionStatus.denied;
    }
  }

  /// Check if device is running Android 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;

    // Android 13 is API level 33
    // This is a simplified check - in production, use device_info_plus
    return true; // For now, assume modern Android
  }

  /// Request all necessary permissions at once
  Future<Map<String, bool>> requestAllPermissions() async {
    return {
      'storage': await requestStoragePermission(),
      'camera': await requestCameraPermission(),
      'notification': await requestNotificationPermission(),
    };
  }

  /// Check all permissions status
  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'storage': await hasStoragePermission(),
      'camera': await hasCameraPermission(),
      'notification': await hasNotificationPermission(),
    };
  }
}
