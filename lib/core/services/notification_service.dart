import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }

    _initialized = true;
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'flashdrop_transfers',
      'File Transfers',
      description: 'Notifications for file transfer progress and completion',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification action
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and handle action
      // e.g., open file location, show transfer details
    }
  }

  /// Show transfer started notification
  Future<void> showTransferStarted({
    required int id,
    required String title,
    required int fileCount,
  }) async {
    await _notifications.show(
      id,
      title,
      'Transferring $fileCount file(s)...',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flashdrop_transfers',
          'File Transfers',
          channelDescription: 'File transfer notifications',
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: 100,
          progress: 0,
          ongoing: true,
          autoCancel: false,
        ),
      ),
    );
  }

  /// Update transfer progress notification
  Future<void> updateTransferProgress({
    required int id,
    required String title,
    required int progress,
    required String speedMbps,
  }) async {
    await _notifications.show(
      id,
      title,
      'Progress: $progress% • Speed: $speedMbps Mbps',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'flashdrop_transfers',
          'File Transfers',
          channelDescription: 'File transfer notifications',
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          ongoing: true,
          autoCancel: false,
        ),
      ),
    );
  }

  /// Show transfer completed notification
  Future<void> showTransferCompleted({
    required int id,
    required String title,
    required int fileCount,
    required String savePath,
  }) async {
    await _notifications.show(
      id,
      'Transfer Complete',
      '$title - $fileCount file(s) received',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'flashdrop_transfers',
          'File Transfers',
          channelDescription: 'File transfer notifications',
          importance: Importance.high,
          priority: Priority.high,
          autoCancel: true,
          actions: [
            const AndroidNotificationAction('open_folder', 'Open Folder'),
            const AndroidNotificationAction('dismiss', 'Dismiss'),
          ],
        ),
      ),
      payload: savePath,
    );
  }

  /// Show transfer failed notification
  Future<void> showTransferFailed({
    required int id,
    required String title,
    required String error,
  }) async {
    await _notifications.show(
      id,
      'Transfer Failed',
      '$title - $error',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flashdrop_transfers',
          'File Transfers',
          channelDescription: 'File transfer notifications',
          importance: Importance.high,
          priority: Priority.high,
          autoCancel: true,
        ),
      ),
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Show simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flashdrop_transfers',
          'File Transfers',
          channelDescription: 'File transfer notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }
}
