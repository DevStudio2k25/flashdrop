import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../../domain/entities/chunk.dart';
import '../../domain/entities/file_metadata.dart';
import '../../../../core/constants/transfer_constants.dart';

/// Data source for file operations
class FileDataSource {
  /// Chunk a file into smaller pieces
  Stream<Chunk> chunkFile(File file) async* {
    final fileSize = await file.length();
    final totalChunks = (fileSize / TransferConstants.chunkSize).ceil();

    final randomAccessFile = await file.open(mode: FileMode.read);

    try {
      int chunkIndex = 0;
      int offset = 0;

      while (offset < fileSize) {
        final remainingBytes = fileSize - offset;
        final currentChunkSize = remainingBytes < TransferConstants.chunkSize
            ? remainingBytes
            : TransferConstants.chunkSize;

        final bytes = await randomAccessFile.read(currentChunkSize);
        final checksum = _calculateChecksum(bytes);

        yield Chunk(
          index: chunkIndex,
          data: Uint8List.fromList(bytes),
          checksum: checksum,
          totalChunks: totalChunks,
        );

        offset += currentChunkSize;
        chunkIndex++;
      }
    } finally {
      await randomAccessFile.close();
    }
  }

  /// Write a chunk to file
  Future<void> writeChunk(File file, Chunk chunk) async {
    final randomAccessFile = await file.open(mode: FileMode.append);

    try {
      // Verify checksum
      final calculatedChecksum = _calculateChecksum(chunk.data);
      if (calculatedChecksum != chunk.checksum) {
        throw Exception('Checksum mismatch for chunk ${chunk.index}');
      }

      await randomAccessFile.writeFrom(chunk.data);
    } finally {
      await randomAccessFile.close();
    }
  }

  /// Get file metadata
  Future<FileMetadata> getFileMetadata(File file) async {
    final stat = await file.stat();
    final name = file.path.split(Platform.pathSeparator).last;

    return FileMetadata(
      name: name,
      size: stat.size,
      mimeType: _getMimeType(name),
      path: file.path,
    );
  }

  /// Calculate SHA-256 checksum
  String _calculateChecksum(List<int> bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get MIME type from filename
  String _getMimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    const mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
      'zip': 'application/zip',
      'txt': 'text/plain',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    };

    return mimeTypes[extension] ?? 'application/octet-stream';
  }
}
