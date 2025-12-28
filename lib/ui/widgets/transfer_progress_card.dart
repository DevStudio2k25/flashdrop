import 'package:flutter/material.dart';
import '../../core/models/transfer_task.dart';
import '../theme/app_colors.dart';

/// Transfer progress card widget
class TransferProgressCard extends StatelessWidget {
  final TransferTask task;

  const TransferProgressCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  task.direction == TransferDirection.send
                      ? Icons.upload
                      : Icons.download,
                  color: task.direction == TransferDirection.send
                      ? AppColors.primary
                      : AppColors.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.fileMetadata.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatBytes(task.fileMetadata.size),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusIcon(),
              ],
            ),
            if (task.isActive) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: task.progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(task.progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    _formatSpeed(task.speed),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
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

  Widget _buildStatusIcon() {
    switch (task.status) {
      case TransferStatus.completed:
        return const Icon(Icons.check_circle, color: AppColors.success);
      case TransferStatus.failed:
      case TransferStatus.cancelled:
        return const Icon(Icons.error, color: AppColors.error);
      case TransferStatus.inProgress:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      default:
        return const Icon(Icons.pending, color: AppColors.warning);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024)
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(2)} KB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
  }
}
