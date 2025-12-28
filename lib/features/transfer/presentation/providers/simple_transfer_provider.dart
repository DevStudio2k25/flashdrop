import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/file_metadata.dart';
import '../../domain/entities/transfer_progress.dart';
import '../../../connection/presentation/providers/simple_connection_provider.dart';

part 'simple_transfer_provider.freezed.dart';
part 'simple_transfer_provider.g.dart';

/// Transfer state
@freezed
class SimpleTransferState with _$SimpleTransferState {
  const factory SimpleTransferState.idle() = _Idle;
  const factory SimpleTransferState.preparing({
    required List<FileMetadata> files,
  }) = _Preparing;
  const factory SimpleTransferState.transferring({
    required TransferProgress progress,
    required List<FileMetadata> files,
  }) = _Transferring;
  const factory SimpleTransferState.completed({
    required List<FileMetadata> files,
    required Duration duration,
  }) = _Completed;
  const factory SimpleTransferState.failed({required String error}) = _Failed;
}

/// Simple HTTP-based transfer notifier
@riverpod
class SimpleTransfer extends _$SimpleTransfer {
  DateTime? _transferStartTime;

  @override
  SimpleTransferState build() {
    return const SimpleTransferState.idle();
  }

  /// Send files using HTTP
  Future<void> sendFiles(List<FileMetadata> files) async {
    if (files.isEmpty) {
      state = const SimpleTransferState.failed(error: 'No files selected');
      return;
    }

    state = SimpleTransferState.preparing(files: files);

    try {
      final connectionNotifier = ref.read(simpleConnectionProvider.notifier);
      final httpService = connectionNotifier.httpService;

      if (httpService == null) {
        throw Exception('Not connected to any peer');
      }

      _transferStartTime = DateTime.now();

      // Send files one by one
      for (int i = 0; i < files.length; i++) {
        final fileMetadata = files[i];
        final file = File(fileMetadata.path);

        // Update progress
        final progress = TransferProgress(
          currentFileIndex: i,
          totalFiles: files.length,
          currentFileBytes: 0,
          currentFileTotalBytes: fileMetadata.size,
          totalBytesTransferred: files
              .take(i)
              .fold(0, (sum, f) => sum + f.size),
          totalBytes: files.fold(0, (sum, f) => sum + f.size),
          speedBytesPerSecond: 0,
          estimatedTimeRemaining: Duration.zero,
        );

        state = SimpleTransferState.transferring(
          progress: progress,
          files: files,
        );

        // Send file via HTTP
        await connectionNotifier.sendFile(file);

        // Update progress after file sent
        final completedProgress = TransferProgress(
          currentFileIndex: i,
          totalFiles: files.length,
          currentFileBytes: fileMetadata.size,
          currentFileTotalBytes: fileMetadata.size,
          totalBytesTransferred: files
              .take(i + 1)
              .fold(0, (sum, f) => sum + f.size),
          totalBytes: files.fold(0, (sum, f) => sum + f.size),
          speedBytesPerSecond: 0,
          estimatedTimeRemaining: Duration.zero,
        );

        state = SimpleTransferState.transferring(
          progress: completedProgress,
          files: files,
        );
      }

      // Transfer complete
      final duration = DateTime.now().difference(_transferStartTime!);
      state = SimpleTransferState.completed(files: files, duration: duration);
    } catch (e) {
      state = SimpleTransferState.failed(error: e.toString());
    }
  }

  /// Reset state
  void reset() {
    state = const SimpleTransferState.idle();
    _transferStartTime = null;
  }
}
