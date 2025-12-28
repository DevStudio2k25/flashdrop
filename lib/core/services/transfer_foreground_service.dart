import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/foundation.dart';

/// Background transfer service using Foreground Task
class TransferForegroundService {
  static bool _isRunning = false;

  /// Initialize foreground service
  static Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'flashdrop_transfer',
        channelName: 'File Transfer',
        channelDescription: 'Shows file transfer progress',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Start foreground service for transfer
  static Future<bool> startService({
    required String fileName,
    required int totalFiles,
  }) async {
    if (_isRunning) {
      debugPrint('⚠️ [ForegroundService] Already running');
      return false;
    }

    final hasPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (hasPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'FlashDrop - Transferring',
      notificationText: totalFiles > 1
          ? 'Transferring $totalFiles files...'
          : 'Transferring $fileName...',
      callback: startCallback,
    );

    // Check if service is actually running
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      _isRunning = true;
      debugPrint('✅ [ForegroundService] Started');
    }

    return isRunning;
  }

  /// Update notification with progress
  static Future<void> updateProgress({
    required String fileName,
    required int progress,
    required String speed,
  }) async {
    if (!_isRunning) return;

    await FlutterForegroundTask.updateService(
      notificationTitle: 'FlashDrop - Transferring',
      notificationText: '$fileName - $progress% ($speed)',
    );
  }

  /// Stop foreground service
  static Future<bool> stopService() async {
    if (!_isRunning) return false;

    await FlutterForegroundTask.stopService();

    // Check if service is actually stopped
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (!isRunning) {
      _isRunning = false;
      debugPrint('🔴 [ForegroundService] Stopped');
    }

    return !isRunning;
  }

  /// Check if service is running
  static bool get isRunning => _isRunning;
}

/// Callback for foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(TransferTaskHandler());
}

/// Task handler for foreground service
class TransferTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('🚀 [TaskHandler] Started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This is called every 5 seconds (as per interval)
    // We don't need to do anything here as updates are manual
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('🔴 [TaskHandler] Destroyed');
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button press if needed
  }

  @override
  void onNotificationPressed() {
    // Bring app to foreground when notification is tapped
    FlutterForegroundTask.launchApp('/');
  }
}
