/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Metadata
  static const String appName = 'FlashDrop';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Fast, Private, Peer-to-Peer File Transfer';

  // Network
  static const int signalingServerPort = 37021;
  static const int connectionTimeoutSeconds = 30;
  static const int discoveryTimeoutSeconds = 10;

  // File System
  static const String defaultDownloadFolder = 'FlashDrop';

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
