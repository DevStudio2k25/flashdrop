import 'dart:typed_data';

class ChunkOptimizer {
  /// Optimize chunk size based on network conditions
  static int getOptimalChunkSize({
    required double speedBytesPerSecond,
    int minChunkSize = 32 * 1024, // 32KB
    int maxChunkSize = 256 * 1024, // 256KB
    int defaultChunkSize = 64 * 1024, // 64KB
  }) {
    // For very slow connections (< 100 KB/s), use smaller chunks
    if (speedBytesPerSecond < 100 * 1024) {
      return minChunkSize;
    }

    // For fast connections (> 1 MB/s), use larger chunks
    if (speedBytesPerSecond > 1024 * 1024) {
      return maxChunkSize;
    }

    // For medium connections, use default
    return defaultChunkSize;
  }

  /// Calculate optimal buffer size for chunk processing
  static int getOptimalBufferSize(int chunkSize) {
    // Buffer should be able to hold multiple chunks
    return chunkSize * 4;
  }

  /// Compress chunk data if beneficial
  static Uint8List? tryCompress(Uint8List data) {
    // Placeholder for compression logic
    // In production, use packages like archive or zlib
    // Only compress if it reduces size by at least 10%
    return null; // Return null if compression not beneficial
  }

  /// Calculate transfer window size (number of chunks to send before waiting for ACK)
  static int getTransferWindowSize({
    required double speedBytesPerSecond,
    required int chunkSize,
    int minWindow = 1,
    int maxWindow = 256,
  }) {
    // For slow connections, use smaller window
    if (speedBytesPerSecond < 100 * 1024) {
      return minWindow;
    }

    // For fast connections, use larger window
    if (speedBytesPerSecond > 10 * 1024 * 1024) {
      return maxWindow;
    }

    // Calculate based on bandwidth-delay product
    // Assume 50ms RTT
    final rttSeconds = 0.05;
    final bytesInFlight = speedBytesPerSecond * rttSeconds;
    final chunksInFlight = (bytesInFlight / chunkSize).ceil();

    return chunksInFlight.clamp(minWindow, maxWindow);
  }

  /// Estimate optimal timeout for chunk acknowledgment
  static Duration getAckTimeout({
    required double speedBytesPerSecond,
    required int chunkSize,
    Duration minTimeout = const Duration(milliseconds: 100),
    Duration maxTimeout = const Duration(seconds: 5),
  }) {
    // Calculate expected transfer time for one chunk
    final transferTimeSeconds = chunkSize / speedBytesPerSecond;

    // Add 2x buffer for network variance
    final timeoutSeconds = transferTimeSeconds * 2;

    final timeout = Duration(milliseconds: (timeoutSeconds * 1000).toInt());

    return Duration(
      milliseconds: timeout.inMilliseconds.clamp(
        minTimeout.inMilliseconds,
        maxTimeout.inMilliseconds,
      ),
    );
  }

  /// Check if chunk should be cached
  static bool shouldCacheChunk(int chunkIndex, int totalChunks) {
    // Cache first and last chunks for quick access
    return chunkIndex == 0 || chunkIndex == totalChunks - 1;
  }

  /// Calculate optimal number of parallel transfers
  static int getOptimalParallelTransfers({
    required int availableCores,
    required double speedBytesPerSecond,
    int minParallel = 1,
    int maxParallel = 4,
  }) {
    // For slow connections, don't parallelize
    if (speedBytesPerSecond < 500 * 1024) {
      return minParallel;
    }

    // Use up to half of available cores
    final optimal = (availableCores / 2).ceil();

    return optimal.clamp(minParallel, maxParallel);
  }
}
