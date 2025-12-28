import 'package:flutter/material.dart';
import '../../features/transfer/domain/entities/file_metadata.dart';
import '../../features/transfer/domain/entities/transfer_progress.dart';

class FileListItem extends StatelessWidget {
  final FileMetadata file;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Widget? trailing;

  const FileListItem({
    super.key,
    required this.file,
    this.onTap,
    this.onRemove,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          _getFileIcon(file.mimeType),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(TransferProgress.formatBytes(file.size)),
      trailing:
          trailing ??
          (onRemove != null
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onRemove,
                  tooltip: 'Remove',
                )
              : null),
      onTap: onTap,
    );
  }

  IconData _getFileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return Icons.image;
    } else if (mimeType.startsWith('video/')) {
      return Icons.video_file;
    } else if (mimeType.startsWith('audio/')) {
      return Icons.audio_file;
    } else if (mimeType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (mimeType.contains('document') || mimeType.contains('word')) {
      return Icons.description;
    } else if (mimeType.contains('sheet') || mimeType.contains('excel')) {
      return Icons.table_chart;
    } else if (mimeType.contains('zip')) {
      return Icons.folder_zip;
    } else if (mimeType.contains('android.package-archive')) {
      return Icons.android;
    } else if (mimeType.contains('java-archive')) {
      return Icons.code;
    } else {
      return Icons.insert_drive_file;
    }
  }
}
