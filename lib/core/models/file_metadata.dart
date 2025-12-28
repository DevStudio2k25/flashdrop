/// File metadata for transfer
class FileMetadata {
  final String id;
  final String name;
  final int size;
  final String mimeType;
  final String? relativePath;

  const FileMetadata({
    required this.id,
    required this.name,
    required this.size,
    required this.mimeType,
    this.relativePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'size': size,
    'mimeType': mimeType,
    'relativePath': relativePath,
  };

  factory FileMetadata.fromJson(Map<String, dynamic> json) => FileMetadata(
    id: json['id'] as String,
    name: json['name'] as String,
    size: json['size'] as int,
    mimeType: json['mimeType'] as String,
    relativePath: json['relativePath'] as String?,
  );

  @override
  String toString() => 'FileMetadata($name, ${_formatBytes(size)})';

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
