/// Represents the progress of a file transfer
class TransferProgress {
  final int currentFileIndex;
  final int totalFiles;
  final int currentFileBytes;
  final int currentFileTotalBytes;
  final int totalBytesTransferred;
  final int totalBytes;
  final double speedBytesPerSecond;
  final Duration estimatedTimeRemaining;

  TransferProgress({
    required this.currentFileIndex,
    required this.totalFiles,
    required this.currentFileBytes,
    required this.currentFileTotalBytes,
    required this.totalBytesTransferred,
    required this.totalBytes,
    required this.speedBytesPerSecond,
    required this.estimatedTimeRemaining,
  });

  /// Overall progress as a percentage (0.0 to 1.0)
  double get overallProgress =>
      totalBytes > 0 ? totalBytesTransferred / totalBytes : 0.0;

  /// Current file progress as a percentage (0.0 to 1.0)
  double get currentFileProgress => currentFileTotalBytes > 0
      ? currentFileBytes / currentFileTotalBytes
      : 0.0;

  /// Transfer speed in Mbps
  String get speedMbps =>
      (speedBytesPerSecond * 8 / 1000000).toStringAsFixed(2);

  /// Formatted estimated time remaining
  String get formattedETA {
    final hours = estimatedTimeRemaining.inHours;
    final minutes = estimatedTimeRemaining.inMinutes % 60;
    final seconds = estimatedTimeRemaining.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format bytes to human-readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
