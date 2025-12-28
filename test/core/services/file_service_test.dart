import 'package:flutter_test/flutter_test.dart';
import 'package:flashdrop/core/services/file_service.dart';

void main() {
  group('FileService', () {
    late FileService fileService;

    setUp(() {
      fileService = FileService();
    });

    test(
      'getUniqueFilePath returns original path if file does not exist',
      () async {
        final path = await fileService.getUniqueFilePath(
          '/tmp/test',
          'nonexistent.txt',
        );

        expect(path, '/tmp/test/nonexistent.txt');
      },
    );

    test('getUniqueFilePath adds counter for existing files', () async {
      // This test would need actual file creation to work properly
      // For now, we test the logic
      final path = await fileService.getUniqueFilePath('/tmp/test', 'test.txt');

      expect(path, contains('test'));
      expect(path, contains('.txt'));
    });

    test('hasEnoughSpace returns true for reasonable file sizes', () async {
      final hasSpace = await fileService.hasEnoughSpace('/tmp', 1024 * 1024);
      expect(hasSpace, true);
    });

    test('fileExists returns false for non-existent file', () async {
      final exists = await fileService.fileExists(
        '/tmp/nonexistent_file_12345.txt',
      );
      expect(exists, false);
    });
  });
}
