import 'package:flutter/foundation.dart';
import '../services/logger_service.dart';

class DebugHelper {
  static final DebugHelper _instance = DebugHelper._internal();
  factory DebugHelper() => _instance;
  DebugHelper._internal();

  final _logger = LoggerService();
  bool _isDebugMode = kDebugMode;

  /// Enable/disable debug mode
  void setDebugMode(bool enabled) {
    _isDebugMode = enabled;
    _logger.setDebugMode(enabled);
  }

  /// Check if running in debug mode
  bool get isDebugMode => _isDebugMode;

  /// Log app lifecycle events
  void logLifecycleEvent(String event) {
    if (_isDebugMode) {
      _logger.info('Lifecycle: $event', tag: 'Debug');
    }
  }

  /// Log screen navigation
  void logNavigation(String from, String to) {
    if (_isDebugMode) {
      _logger.info('Navigation: $from → $to', tag: 'Debug');
    }
  }

  /// Log user action
  void logUserAction(String action, {Map<String, dynamic>? data}) {
    if (_isDebugMode) {
      _logger.info(
        'User Action: $action${data != null ? ' - $data' : ''}',
        tag: 'Debug',
      );
    }
  }

  /// Log network event
  void logNetworkEvent(String event, {String? details}) {
    if (_isDebugMode) {
      _logger.info(
        'Network: $event${details != null ? ' - $details' : ''}',
        tag: 'Debug',
      );
    }
  }

  /// Log state change
  void logStateChange(String stateName, dynamic oldState, dynamic newState) {
    if (_isDebugMode) {
      _logger.debug(
        'State Change: $stateName\n  Old: $oldState\n  New: $newState',
        tag: 'Debug',
      );
    }
  }

  /// Print debug banner
  void printDebugBanner() {
    if (_isDebugMode) {
      debugPrint('╔════════════════════════════════════════╗');
      debugPrint('║        FlashDrop Debug Mode            ║');
      debugPrint('║  Logging enabled for testing           ║');
      debugPrint('╚════════════════════════════════════════╝');
    }
  }

  /// Print device info
  void printDeviceInfo(Map<String, dynamic> info) {
    if (_isDebugMode) {
      debugPrint('\n=== Device Information ===');
      info.forEach((key, value) {
        debugPrint('$key: $value');
      });
      debugPrint('========================\n');
    }
  }

  /// Print test scenario
  void printTestScenario(String scenario) {
    if (_isDebugMode) {
      debugPrint('\n>>> Testing: $scenario <<<\n');
    }
  }

  /// Print test result
  void printTestResult(String test, bool passed, {String? message}) {
    if (_isDebugMode) {
      final status = passed ? '✓ PASS' : '✗ FAIL';
      debugPrint('$status: $test${message != null ? ' - $message' : ''}');
    }
  }
}
