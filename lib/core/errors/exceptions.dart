/// Base exception class
class FlashDropException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  FlashDropException(this.message, [this.stackTrace]);

  @override
  String toString() => 'FlashDropException: $message';
}

/// Network-related exception
class NetworkException extends FlashDropException {
  NetworkException(super.message, [super.stackTrace]);

  @override
  String toString() => 'NetworkException: $message';
}

/// File system-related exception
class FileSystemException extends FlashDropException {
  final String? filePath;

  FileSystemException(super.message, [this.filePath, super.stackTrace]);

  @override
  String toString() => filePath != null
      ? 'FileSystemException: $message (File: $filePath)'
      : 'FileSystemException: $message';
}

/// Permission-related exception
class PermissionException extends FlashDropException {
  final String permission;

  PermissionException(super.message, this.permission, [super.stackTrace]);

  @override
  String toString() =>
      'PermissionException: $message (Permission: $permission)';
}

/// Protocol/transfer-related exception
class ProtocolException extends FlashDropException {
  ProtocolException(super.message, [super.stackTrace]);

  @override
  String toString() => 'ProtocolException: $message';
}

/// Checksum mismatch exception
class ChecksumMismatchException extends FlashDropException {
  final int chunkIndex;

  ChecksumMismatchException(super.message, this.chunkIndex, [super.stackTrace]);

  @override
  String toString() =>
      'ChecksumMismatchException: $message (Chunk: $chunkIndex)';
}

/// Connection-related exception
class ConnectionException extends FlashDropException {
  ConnectionException(super.message, [super.stackTrace]);

  @override
  String toString() => 'ConnectionException: $message';
}

/// Timeout exception
class TimeoutException extends FlashDropException {
  TimeoutException(super.message, [super.stackTrace]);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Transfer exception
class TransferException extends FlashDropException {
  TransferException(super.message, [super.stackTrace]);

  @override
  String toString() => 'TransferException: $message';
}

/// Transfer cancelled exception
class TransferCancelledException extends FlashDropException {
  TransferCancelledException(super.message, [super.stackTrace]);

  @override
  String toString() => 'TransferCancelledException: $message';
}
