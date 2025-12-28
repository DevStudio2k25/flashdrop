import 'package:flutter_test/flutter_test.dart';
import 'package:flashdrop/features/transfer/domain/entities/transfer_progress.dart';

void main() {
  group('TransferProgress', () {
    test('overallProgress calculates correctly', () {
      final progress = TransferProgress(
        currentFileIndex: 0,
        totalFiles: 2,
        currentFileBytes: 500,
        currentFileTotalBytes: 1000,
        totalBytesTransferred: 500,
        totalBytes: 2000,
        speedBytesPerSecond: 100.0,
        estimatedTimeRemaining: const Duration(seconds: 15),
      );

      expect(progress.overallProgress, 0.25);
    });

    test('currentFileProgress calculates correctly', () {
      final progress = TransferProgress(
        currentFileIndex: 0,
        totalFiles: 1,
        currentFileBytes: 750,
        currentFileTotalBytes: 1000,
        totalBytesTransferred: 750,
        totalBytes: 1000,
        speedBytesPerSecond: 100.0,
        estimatedTimeRemaining: const Duration(seconds: 2),
      );

      expect(progress.currentFileProgress, 0.75);
    });

    test('speedMbps converts correctly', () {
      final progress = TransferProgress(
        currentFileIndex: 0,
        totalFiles: 1,
        currentFileBytes: 500,
        currentFileTotalBytes: 1000,
        totalBytesTransferred: 500,
        totalBytes: 1000,
        speedBytesPerSecond: 1250000.0, // 1.25 MB/s = 10 Mbps
        estimatedTimeRemaining: const Duration(seconds: 1),
      );

      expect(progress.speedMbps, '10.00');
    });

    test('formattedETA formats hours correctly', () {
      final progress = TransferProgress(
        currentFileIndex: 0,
        totalFiles: 1,
        currentFileBytes: 0,
        currentFileTotalBytes: 1000,
        totalBytesTransferred: 0,
        totalBytes: 1000,
        speedBytesPerSecond: 100.0,
        estimatedTimeRemaining: const Duration(hours: 2, minutes: 30),
      );

      expect(progress.formattedETA, '2h 30m');
    });

    test('formattedETA formats minutes correctly', () {
      final progress = TransferProgress(
        currentFileIndex: 0,
        totalFiles: 1,
        currentFileBytes: 0,
        currentFileTotalBytes: 1000,
        totalBytesTransferred: 0,
        totalBytes: 1000,
        speedBytesPerSecond: 100.0,
        estimatedTimeRemaining: const Duration(minutes: 5, seconds: 30),
      );

      expect(progress.formattedETA, '5m 30s');
    });

    test('formattedETA formats seconds correctly', () {
      final progress = TransferProgress(
        currentFileIndex: 0,
        totalFiles: 1,
        currentFileBytes: 0,
        currentFileTotalBytes: 1000,
        totalBytesTransferred: 0,
        totalBytes: 1000,
        speedBytesPerSecond: 100.0,
        estimatedTimeRemaining: const Duration(seconds: 45),
      );

      expect(progress.formattedETA, '45s');
    });

    test('formatBytes formats correctly', () {
      expect(TransferProgress.formatBytes(500), '500 B');
      expect(TransferProgress.formatBytes(1024), '1.00 KB');
      expect(TransferProgress.formatBytes(1024 * 1024), '1.00 MB');
      expect(TransferProgress.formatBytes(1024 * 1024 * 1024), '1.00 GB');
    });

    test('overallProgress returns 0 when totalBytes is 0', () {
      final progress = TransferProgress(
        currentFileIndex: 0,
        totalFiles: 1,
        currentFileBytes: 0,
        currentFileTotalBytes: 0,
        totalBytesTransferred: 0,
        totalBytes: 0,
        speedBytesPerSecond: 0.0,
        estimatedTimeRemaining: Duration.zero,
      );

      expect(progress.overallProgress, 0.0);
    });
  });
}
