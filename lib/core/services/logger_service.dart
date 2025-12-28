import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  bool _isDebugMode = true;

  void setDebugMode(bool enabled) {
    _isDebugMode = enabled;
  }

  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_isDebugMode) {
      _log(
        LogLevel.debug,
        message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final tagStr = tag != null ? '[$tag]' : '';

    final logMessage = '$timestamp $levelStr $tagStr $message';

    // Use developer.log for better debugging in Flutter DevTools
    developer.log(
      logMessage,
      name: 'FlashDrop',
      error: error,
      stackTrace: stackTrace,
      level: _getLevelValue(level),
    );
  }

  int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  // WebRTC event logging
  void logWebRTCEvent(String event, {Map<String, dynamic>? data}) {
    debug(
      'WebRTC Event: $event${data != null ? ' - ${data.toString()}' : ''}',
      tag: 'WebRTC',
    );
  }

  // Transfer progress logging
  void logTransferProgress({
    required int currentFile,
    required int totalFiles,
    required double progress,
    required double speedMbps,
  }) {
    info(
      'Transfer Progress: File $currentFile/$totalFiles - ${(progress * 100).toStringAsFixed(1)}% - $speedMbps Mbps',
      tag: 'Transfer',
    );
  }

  // Connection event logging
  void logConnectionEvent(String event, {String? peerId, String? details}) {
    info(
      'Connection Event: $event${peerId != null ? ' (Peer: $peerId)' : ''}${details != null ? ' - $details' : ''}',
      tag: 'Connection',
    );
  }

  // Error logging with context
  void logError(
    String context,
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) {
    final errorDetails = StringBuffer();
    errorDetails.writeln('Context: $context');
    errorDetails.writeln('Error: $error');

    if (additionalInfo != null && additionalInfo.isNotEmpty) {
      errorDetails.writeln('Additional Info:');
      additionalInfo.forEach((key, value) {
        errorDetails.writeln('  $key: $value');
      });
    }

    this.error(
      errorDetails.toString(),
      tag: 'Error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // File operation logging
  void logFileOperation(String operation, String fileName, {String? details}) {
    debug(
      'File Operation: $operation - $fileName${details != null ? ' - $details' : ''}',
      tag: 'FileSystem',
    );
  }

  // Network operation logging
  void logNetworkOperation(
    String operation, {
    String? endpoint,
    String? details,
  }) {
    debug(
      'Network Operation: $operation${endpoint != null ? ' - $endpoint' : ''}${details != null ? ' - $details' : ''}',
      tag: 'Network',
    );
  }
}
