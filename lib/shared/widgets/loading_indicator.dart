import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? progress;

  const LoadingIndicator({super.key, this.message, this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null)
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(value: progress, strokeWidth: 6),
            )
          else
            const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LinearLoadingIndicator extends StatelessWidget {
  final double? progress;
  final String? label;

  const LinearLoadingIndicator({super.key, this.progress, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
        ],
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        if (progress != null) ...[
          const SizedBox(height: 4),
          Text(
            '${(progress! * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.right,
          ),
        ],
      ],
    );
  }
}
