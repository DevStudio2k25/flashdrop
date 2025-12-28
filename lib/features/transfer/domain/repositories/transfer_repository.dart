import '../entities/file_metadata.dart';
import '../entities/transfer_progress.dart';

/// Repository interface for file transfers
abstract class TransferRepository {
  /// Send files to a peer
  Stream<TransferProgress> sendFiles(List<FileMetadata> files);

  /// Receive files from a peer
  Stream<TransferProgress> receiveFiles(String savePath);

  /// Pause ongoing transfer
  void pauseTransfer();

  /// Resume paused transfer
  Future<void> resumeTransfer();

  /// Cancel ongoing transfer
  void cancelTransfer();
}
