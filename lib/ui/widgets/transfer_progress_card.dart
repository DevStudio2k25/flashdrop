import 'package:flutter/material.dart';
import '../../core/models/transfer_task.dart';
import '../theme/app_colors.dart';

/// Transfer progress card widget
class TransferProgressCard extends StatelessWidget {
  final TransferTask task;

  const TransferProgressCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildFileIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.fileMetadata.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            task.direction == TransferDirection.send
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: task.direction == TransferDirection.send
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatBytes(task.fileMetadata.size),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            if (task.isActive) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: task.progress,
                  minHeight: 8,
                  backgroundColor: AppColors.border.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    task.direction == TransferDirection.send
                        ? AppColors.primary
                        : AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(task.progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatSpeed(task.speed),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon() {
    // Simple extension check
    final ext = task.fileMetadata.name.split('.').last.toLowerCase();
    IconData icon = Icons.insert_drive_file;
    Color color = AppColors.textTertiary;

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      icon = Icons.image;
      color = Colors.purple;
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) {
      icon = Icons.movie;
      color = Colors.red;
    } else if (['mp3', 'wav', 'aac', 'flac'].contains(ext)) {
      icon = Icons.music_note;
      color = Colors.pink;
    } else if (['pdf', 'doc', 'docx'].contains(ext)) {
      icon = Icons.description;
      color = Colors.blue;
    } else if (['zip', 'rar', '7z'].contains(ext)) {
      icon = Icons.folder_zip;
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildStatusBadge() {
    switch (task.status) {
      case TransferStatus.completed:
        return const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 28,
        );
      case TransferStatus.failed:
      case TransferStatus.cancelled:
        return const Icon(
          Icons.error_rounded,
          color: AppColors.error,
          size: 28,
        );
      case TransferStatus.inProgress:
        // No icon here, progress shown below
        return const SizedBox.shrink();
      default:
        return const Icon(
          Icons.pending_rounded,
          color: AppColors.warning,
          size: 24,
        );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024)
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}
