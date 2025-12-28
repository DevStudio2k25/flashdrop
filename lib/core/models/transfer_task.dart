import 'file_metadata.dart';

/// Transfer direction
enum TransferDirection { send, receive }

/// Transfer status
enum TransferStatus {
  pending,
  inProgress,
  paused,
  completed,
  failed,
  cancelled,
}

/// Transfer task model
class TransferTask {
  final String id;
  final FileMetadata fileMetadata;
  final TransferDirection direction;
  final TransferStatus status;
  final int bytesTransferred;
  final double speed; // bytes per second
  final DateTime startTime;
  final DateTime? endTime;
  final String? errorMessage;
  final String? savePath;

  const TransferTask({
    required this.id,
    required this.fileMetadata,
    required this.direction,
    required this.status,
    this.bytesTransferred = 0,
    this.speed = 0,
    required this.startTime,
    this.endTime,
    this.errorMessage,
    this.savePath,
  });

  /// Calculate progress percentage
  double get progress {
    if (fileMetadata.size == 0) return 0;
    return (bytesTransferred / fileMetadata.size).clamp(0.0, 1.0);
  }

  /// Check if transfer is active
  bool get isActive =>
      status == TransferStatus.inProgress || status == TransferStatus.pending;

  /// Check if transfer is complete
  bool get isComplete => status == TransferStatus.completed;

  /// Check if transfer has failed
  bool get hasFailed =>
      status == TransferStatus.failed || status == TransferStatus.cancelled;

  /// Copy with updated fields
  TransferTask copyWith({
    TransferStatus? status,
    int? bytesTransferred,
    double? speed,
    DateTime? endTime,
    String? errorMessage,
    String? savePath,
  }) {
    return TransferTask(
      id: id,
      fileMetadata: fileMetadata,
      direction: direction,
      status: status ?? this.status,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      speed: speed ?? this.speed,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      errorMessage: errorMessage ?? this.errorMessage,
      savePath: savePath ?? this.savePath,
    );
  }

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileMetadata.name,
    'fileSize': fileMetadata.size,
    'mimeType': fileMetadata.mimeType,
    'direction': direction.name,
    'status': status.name,
    'bytesTransferred': bytesTransferred,
    'speed': speed,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'errorMessage': errorMessage,
    'savePath': savePath,
  };

  /// Create from JSON (database)
  factory TransferTask.fromJson(Map<String, dynamic> json) {
    return TransferTask(
      id: json['id'] as String,
      fileMetadata: FileMetadata(
        id: json['id'] as String,
        name: json['fileName'] as String,
        size: json['fileSize'] as int,
        mimeType: json['mimeType'] as String,
      ),
      direction: TransferDirection.values.firstWhere(
        (e) => e.name == json['direction'],
      ),
      status: TransferStatus.values.firstWhere((e) => e.name == json['status']),
      bytesTransferred: json['bytesTransferred'] as int,
      speed: (json['speed'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      savePath: json['savePath'] as String?,
    );
  }

  @override
  String toString() =>
      'TransferTask(${fileMetadata.name}, ${direction.name}, ${status.name}, ${(progress * 100).toStringAsFixed(1)}%)';
}
