/// Network constants
class NetworkConstants {
  NetworkConstants._();

  /// Default server port (Control channel)
  static const int defaultPort = 4040;

  /// Data transfer port (File transfer channel)
  static const int dataPort = 4042;

  /// Discovery broadcast port (UDP) - Used for Finding Devices automatically
  static const int discoveryPort = 4041;

  /// Chunk size for file transfer (1MB - optimized for speed)
  /// Larger chunks = fewer network round-trips = faster transfer
  static const int chunkSize = 1024 * 1024; // 1 MB

  /// Socket buffer sizes for optimal throughput
  static const int socketSendBuffer = 2 * 1024 * 1024; // 2 MB
  static const int socketReceiveBuffer = 2 * 1024 * 1024; // 2 MB

  /// Progress update throttle (ms) - reduce UI overhead
  static const int progressUpdateThrottle = 500; // 500ms

  /// Socket timeout
  /// Socket timeout
  static const Duration socketTimeout = Duration(seconds: 5);

  /// Discovery broadcast interval
  static const Duration discoveryInterval = Duration(seconds: 2);

  /// Max retry attempts
  static const int maxRetries = 3;

  /// Protocol commands
  static const String cmdHandshake = 'HANDSHAKE';
  static const String cmdHandshakeAck = 'HANDSHAKE_ACK';
  static const String cmdFileOffer = 'FILE_OFFER';
  static const String cmdFileAccept = 'FILE_ACCEPT';
  static const String cmdFileReject = 'FILE_REJECT';
  static const String cmdFileData = 'FILE_DATA';
  static const String cmdFileComplete = 'FILE_COMPLETE';
  static const String cmdError = 'ERROR';
  static const String cmdDisconnect = 'DISCONNECT';

  /// Message delimiter
  static const String messageDelimiter = '\n';
}
