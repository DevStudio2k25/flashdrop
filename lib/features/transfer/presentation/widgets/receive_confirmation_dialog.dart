import 'package:flutter/material.dart';
import '../../domain/entities/file_metadata.dart';
import '../../domain/entities/transfer_progress.dart';

class ReceiveConfirmationDialog extends StatelessWidget {
  final String senderName;
  final String senderDevice;
  final List<FileMetadata> files;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ReceiveConfirmationDialog({
    super.key,
    required this.senderName,
    required this.senderDevice,
    required this.files,
    required this.onAccept,
    required this.onReject,
  });

  int get _totalSize => files.fold(0, (sum, file) => sum + file.size);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Incoming Files'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        senderDevice,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Files Summary
            Text(
              'Files (${files.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            // Files List
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_getFileIcon(file.mimeType), size: 20),
                    title: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: Text(
                      TransferProgress.formatBytes(file.size),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            // Total Size
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Size',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  TransferProgress.formatBytes(_totalSize),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onReject, child: const Text('Reject')),
        ElevatedButton(onPressed: onAccept, child: const Text('Accept')),
      ],
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
