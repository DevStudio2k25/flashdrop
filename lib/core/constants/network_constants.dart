/// Network constants
class NetworkConstants {
  NetworkConstants._();

  /// Default server port
  static const int defaultPort = 8888;

  /// Discovery broadcast port (UDP)
  static const int discoveryPort = 8889;

  /// Chunk size for file transfer (128KB - optimized for speed)
  static const int chunkSize = 128 * 1024;

  /// Socket timeout
  static const Duration socketTimeout = Duration(seconds: 30);

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
