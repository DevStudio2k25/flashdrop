/// Base class for all failures
sealed class Failure {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

/// File system-related failures
class FileSystemFailure extends Failure {
  final String? filePath;

  const FileSystemFailure(super.message, [this.filePath, super.stackTrace]);

  @override
  String toString() =>
      filePath != null ? '$message (File: $filePath)' : message;
}

/// Permission-related failures
class PermissionFailure extends Failure {
  final String permission;

  const PermissionFailure(super.message, this.permission, [super.stackTrace]);

  @override
  String toString() => '$message (Permission: $permission)';
}

/// Protocol/transfer-related failures
class ProtocolFailure extends Failure {
  const ProtocolFailure(super.message, [super.stackTrace]);
}

/// Checksum mismatch failure
class ChecksumMismatchFailure extends Failure {
  final int chunkIndex;

  const ChecksumMismatchFailure(
    super.message,
    this.chunkIndex, [
    super.stackTrace,
  ]);

  @override
  String toString() => '$message (Chunk: $chunkIndex)';
}

/// Connection-related failures
class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message, [super.stackTrace]);
}

/// Timeout failure
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, [super.stackTrace]);
}

/// Unknown/unexpected failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.stackTrace]);
}
