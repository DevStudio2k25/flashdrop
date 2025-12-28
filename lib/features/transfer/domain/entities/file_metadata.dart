import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_metadata.freezed.dart';

/// Metadata for a file to be transferred
@freezed
class FileMetadata with _$FileMetadata {
  const factory FileMetadata({
    required String name,
    required int size,
    required String mimeType,
    required String path,
  }) = _FileMetadata;
}
