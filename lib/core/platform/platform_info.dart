import 'dart:io';
import 'package:flutter/foundation.dart';

/// Platform detection utilities
class PlatformInfo {
  PlatformInfo._();

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Check if running on Web
  static bool get isWeb => kIsWeb;

  /// Check if running on mobile platform
  static bool get isMobile => isAndroid || isIOS;

  /// Check if running on desktop platform
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// Get platform name as string
  static String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  /// Get device type (mobile/desktop/web)
  static String get deviceType {
    if (isMobile) return 'mobile';
    if (isDesktop) return 'desktop';
    if (isWeb) return 'web';
    return 'unknown';
  }
}
