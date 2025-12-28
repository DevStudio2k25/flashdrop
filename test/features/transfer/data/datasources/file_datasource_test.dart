import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashdrop/features/transfer/data/datasources/file_datasource.dart';
import 'package:flashdrop/core/constants/transfer_constants.dart';

void main() {
  group('FileDataSource', () {
    late FileDataSource fileDataSource;
    late Directory tempDir;

    setUp(() {
      fileDataSource = FileDataSource();
    });

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('flashdrop_test_');
    });

    tearDownAll(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('Property Tests', () {
      test(
        'Property 1: Chunk count calculation - For any file, chunks = ceil(fileSize / 64KB)',
        () async {
          // Test with various file sizes
          final testSizes = [
            1024, // 1KB
            65536, // 64KB (exactly 1 chunk)
            65537, // 64KB + 1 byte (2 chunks)
            131072, // 128KB (2 chunks)
            1048576, // 1MB
            10485760, // 10MB
          ];

          for (final size in testSizes) {
            // Create test file
            final testFile = File('${tempDir.path}/test_$size.bin');
            final data = Uint8List(size);
            await testFile.writeAsBytes(data);

            // Calculate expected chunks
            final expectedChunks = (size / TransferConstants.chunkSize).ceil();

            // Chunk the file
            final chunks = await fileDataSource.chunkFile(testFile).toList();

            // Verify chunk count
            expect(
              chunks.length,
              equals(expectedChunks),
              reason: 'File size $size should produce $expectedChunks chunks',
            );

            // Verify totalChunks field in each chunk
            for (final chunk in chunks) {
              expect(chunk.totalChunks, equals(expectedChunks));
            }

            // Cleanup
            await testFile.delete();
          }
        },
      );

      test(
        'Property 2: Checksum consistency - For any chunk, recalculating checksum produces same value',
        () async {
          // Create test file with random data
          final testFile = File('${tempDir.path}/test_checksum.bin');
          final data = Uint8List.fromList(
            List.generate(200000, (i) => i % 256),
          );
          await testFile.writeAsBytes(data);

          // Chunk the file
          final chunks = await fileDataSource.chunkFile(testFile).toList();

          // For each chunk, verify checksum consistency
          for (final chunk in chunks) {
            // The checksum in the chunk should match if we recalculate it
            // We can't directly recalculate without access to private method,
            // but we can verify by writing and reading back
            final tempChunkFile = File(
              '${tempDir.path}/chunk_${chunk.index}.bin',
            );

            // Write chunk (this verifies checksum internally)
            await fileDataSource.writeChunk(tempChunkFile, chunk);

            // Read back and verify size
            final writtenData = await tempChunkFile.readAsBytes();
            expect(writtenData.length, equals(chunk.data.length));
            expect(writtenData, equals(chunk.data));

            // Cleanup
            await tempChunkFile.delete();
          }

          // Cleanup
          await testFile.delete();
        },
      );

      test(
        'Property 3: Chunk data integrity - Concatenating all chunks reproduces original file',
        () async {
          // Create test file with known data
          final testFile = File('${tempDir.path}/test_integrity.bin');
          final originalData = Uint8List.fromList(
            List.generate(300000, (i) => (i * 7) % 256),
          );
          await testFile.writeAsBytes(originalData);

          // Chunk the file
          final chunks = await fileDataSource.chunkFile(testFile).toList();

          // Concatenate all chunk data
          final reconstructedData = <int>[];
          for (final chunk in chunks) {
            reconstructedData.addAll(chunk.data);
          }

          // Verify reconstructed data matches original
          expect(reconstructedData.length, equals(originalData.length));
          expect(reconstructedData, equals(originalData));

          // Cleanup
          await testFile.delete();
        },
      );
    });

    group('Edge Cases', () {
      test('should handle empty file', () async {
        final testFile = File('${tempDir.path}/empty.bin');
        await testFile.writeAsBytes([]);

        final chunks = await fileDataSource.chunkFile(testFile).toList();

        expect(chunks, isEmpty);

        await testFile.delete();
      });

      test('should handle file smaller than chunk size', () async {
        final testFile = File('${tempDir.path}/small.bin');
        final data = Uint8List(1024); // 1KB
        await testFile.writeAsBytes(data);

        final chunks = await fileDataSource.chunkFile(testFile).toList();

        expect(chunks.length, equals(1));
        expect(chunks.first.data.length, equals(1024));

        await testFile.delete();
      });

      test('should detect checksum mismatch', () async {
        final testFile = File('${tempDir.path}/test.bin');
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        await testFile.writeAsBytes(data);

        final chunks = await fileDataSource.chunkFile(testFile).toList();
        final chunk = chunks.first;

        // Corrupt the chunk data
        final corruptedChunk = chunk.copyWith(
          data: Uint8List.fromList([5, 4, 3, 2, 1]),
        );

        final outputFile = File('${tempDir.path}/output.bin');

        // Should throw exception due to checksum mismatch
        expect(
          () => fileDataSource.writeChunk(outputFile, corruptedChunk),
          throwsException,
        );

        await testFile.delete();
      });
    });

    group('File Metadata', () {
      test('should extract correct file metadata', () async {
        final testFile = File('${tempDir.path}/test.pdf');
        final data = Uint8List(1024);
        await testFile.writeAsBytes(data);

        final metadata = await fileDataSource.getFileMetadata(testFile);

        expect(metadata.name, equals('test.pdf'));
        expect(metadata.size, equals(1024));
        expect(metadata.mimeType, equals('application/pdf'));
        expect(metadata.path, equals(testFile.path));

        await testFile.delete();
      });
    });
  });
}
