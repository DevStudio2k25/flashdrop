import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chunk.freezed.dart';

/// Represents a chunk of file data
@freezed
class Chunk with _$Chunk {
  const factory Chunk({
    required int index,
    required Uint8List data,
    required String checksum,
    required int totalChunks,
  }) = _Chunk;
}
