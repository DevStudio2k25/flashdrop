/// File transfer specific constants
class TransferConstants {
  TransferConstants._();

  // Chunking
  static const int chunkSize = 65536; // 64KB
  static const int maxBufferSize = 16777216; // 16MB

  // Flow Control
  static const int windowSize = 256; // Chunks in flight
  static const int ackThreshold = 64; // Send ACK every N chunks

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 10);

  // Progress Update
  static const Duration progressUpdateInterval = Duration(milliseconds: 500);

  // Memory Management
  static const int maxMemoryUsage = 52428800; // 50MB

  // WebRTC Configuration
  static const List<String> stunServers = [
    'stun:stun.l.google.com:19302',
    'stun:stun1.l.google.com:19302',
  ];

  // DataChannel Configuration
  static const String dataChannelLabel = 'file-transfer';
  static const String dataChannelProtocol = 'flashdrop-v1';
}
