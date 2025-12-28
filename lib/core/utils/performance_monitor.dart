import 'dart:async';
import '../services/logger_service.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final _logger = LoggerService();
  final Map<String, DateTime> _startTimes = {};
  final Map<String, List<Duration>> _measurements = {};

  /// Start measuring an operation
  void startMeasurement(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  /// End measuring an operation and log the duration
  void endMeasurement(String operationName) {
    final startTime = _startTimes[operationName];
    if (startTime == null) {
      _logger.warning('No start time found for operation: $operationName');
      return;
    }

    final duration = DateTime.now().difference(startTime);
    _startTimes.remove(operationName);

    // Store measurement
    _measurements.putIfAbsent(operationName, () => []).add(duration);

    _logger.debug(
      'Operation completed: $operationName - ${duration.inMilliseconds}ms',
      tag: 'Performance',
    );
  }

  /// Measure an async operation
  Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startMeasurement(operationName);
    try {
      return await operation();
    } finally {
      endMeasurement(operationName);
    }
  }

  /// Measure a sync operation
  T measure<T>(String operationName, T Function() operation) {
    startMeasurement(operationName);
    try {
      return operation();
    } finally {
      endMeasurement(operationName);
    }
  }

  /// Get average duration for an operation
  Duration? getAverageDuration(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) {
      return null;
    }

    final totalMs = measurements.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ measurements.length);
  }

  /// Get statistics for an operation
  Map<String, dynamic> getStatistics(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) {
      return {};
    }

    final durations = measurements.map((d) => d.inMilliseconds).toList()
      ..sort();
    final count = durations.length;
    final sum = durations.reduce((a, b) => a + b);
    final avg = sum / count;
    final min = durations.first;
    final max = durations.last;
    final median = count.isOdd
        ? durations[count ~/ 2]
        : (durations[count ~/ 2 - 1] + durations[count ~/ 2]) / 2;

    return {
      'operation': operationName,
      'count': count,
      'average_ms': avg.toStringAsFixed(2),
      'min_ms': min,
      'max_ms': max,
      'median_ms': median.toStringAsFixed(2),
      'total_ms': sum,
    };
  }

  /// Get all statistics
  Map<String, Map<String, dynamic>> getAllStatistics() {
    final stats = <String, Map<String, dynamic>>{};
    for (final operationName in _measurements.keys) {
      stats[operationName] = getStatistics(operationName);
    }
    return stats;
  }

  /// Log all statistics
  void logAllStatistics() {
    final stats = getAllStatistics();
    if (stats.isEmpty) {
      _logger.info('No performance measurements recorded', tag: 'Performance');
      return;
    }

    _logger.info('=== Performance Statistics ===', tag: 'Performance');
    stats.forEach((operation, data) {
      _logger.info(
        '$operation: avg=${data['average_ms']}ms, min=${data['min_ms']}ms, max=${data['max_ms']}ms, count=${data['count']}',
        tag: 'Performance',
      );
    });
  }

  /// Clear all measurements
  void clear() {
    _startTimes.clear();
    _measurements.clear();
  }

  /// Clear measurements for a specific operation
  void clearOperation(String operationName) {
    _startTimes.remove(operationName);
    _measurements.remove(operationName);
  }
}

/// Memory usage monitoring
class MemoryMonitor {
  static final MemoryMonitor _instance = MemoryMonitor._internal();
  factory MemoryMonitor() => _instance;
  MemoryMonitor._internal();

  final _logger = LoggerService();
  Timer? _monitoringTimer;

  /// Start monitoring memory usage
  void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(interval, (_) {
      _logMemoryUsage();
    });
  }

  /// Stop monitoring memory usage
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  void _logMemoryUsage() {
    // Note: Actual memory monitoring would require platform channels
    // This is a placeholder for the monitoring structure
    _logger.debug('Memory monitoring active', tag: 'Memory');
  }

  /// Log memory snapshot
  void logSnapshot(String label) {
    _logger.info('Memory snapshot: $label', tag: 'Memory');
  }
}
