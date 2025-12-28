import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../errors/exceptions.dart';

class FileService {
  /// Get the default downloads directory
  Future<Directory> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // On Android, use external storage downloads directory
      final directory = Directory('/storage/emulated/0/Download/FlashDrop');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    } else if (Platform.isWindows) {
      // On Windows, use user's Downloads folder
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final directory = Directory('$userProfile\\Downloads\\FlashDrop');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return directory;
      }
    }

    // Fallback to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/FlashDrop');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Check available storage space
  Future<int> getAvailableSpace(String path) async {
    try {
      // This is a simplified check
      // In production, use platform-specific APIs for accurate space
      return 1024 * 1024 * 1024 * 10; // Return 10GB as placeholder
    } catch (e) {
      throw FileSystemException('Failed to check storage space: $e');
    }
  }

  /// Check if there's enough space for files
  Future<bool> hasEnoughSpace(String path, int requiredBytes) async {
    try {
      final availableSpace = await getAvailableSpace(path);
      // Add 10% buffer for safety
      final requiredWithBuffer = (requiredBytes * 1.1).toInt();
      return availableSpace >= requiredWithBuffer;
    } catch (e) {
      // If we can't check, assume there's space
      return true;
    }
  }

  /// Write file with error handling
  Future<File> writeFile(String path, List<int> bytes) async {
    try {
      final file = File(path);

      // Check if parent directory exists
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      // Write file
      await file.writeAsBytes(bytes);
      return file;
    } on FileSystemException catch (e) {
      if (e.message.contains('No space left')) {
        throw FileSystemException('Insufficient storage space');
      } else if (e.message.contains('Permission denied')) {
        throw FileSystemException('Permission denied to write file');
      } else {
        throw FileSystemException('Failed to write file: ${e.message}');
      }
    } catch (e) {
      throw FileSystemException('Unexpected error writing file: $e');
    }
  }

  /// Append data to file
  Future<void> appendToFile(String path, List<int> bytes) async {
    try {
      final file = File(path);
      await file.writeAsBytes(bytes, mode: FileMode.append);
    } on FileSystemException catch (e) {
      if (e.message.contains('No space left')) {
        throw FileSystemException('Insufficient storage space');
      } else if (e.message.contains('Permission denied')) {
        throw FileSystemException('Permission denied to write file');
      } else {
        throw FileSystemException('Failed to append to file: ${e.message}');
      }
    } catch (e) {
      throw FileSystemException('Unexpected error appending to file: $e');
    }
  }

  /// Delete file with error handling
  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileSystemException('Failed to delete file: $e');
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get file size
  Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      throw FileSystemException('Failed to get file size: $e');
    }
  }

  /// Create unique filename if file already exists
  Future<String> getUniqueFilePath(String directory, String filename) async {
    var path = '$directory/$filename';
    var counter = 1;

    while (await fileExists(path)) {
      final parts = filename.split('.');
      if (parts.length > 1) {
        final name = parts.sublist(0, parts.length - 1).join('.');
        final extension = parts.last;
        path = '$directory/$name ($counter).$extension';
      } else {
        path = '$directory/$filename ($counter)';
      }
      counter++;
    }

    return path;
  }

  /// Open file location in file explorer
  Future<void> openFileLocation(String path) async {
    try {
      final file = File(path);
      final directory = file.parent;

      if (Platform.isWindows) {
        // Open Windows Explorer
        await Process.run('explorer', [directory.path]);
      } else if (Platform.isAndroid) {
        // On Android, this would require platform channel
        // For now, just return
        return;
      }
    } catch (e) {
      throw FileSystemException('Failed to open file location: $e');
    }
  }
}
