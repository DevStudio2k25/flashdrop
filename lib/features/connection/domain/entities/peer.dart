import 'package:freezed_annotation/freezed_annotation.dart';

part 'peer.freezed.dart';

/// Represents a peer device in the network
@freezed
class Peer with _$Peer {
  const factory Peer({
    required String id,
    required String name,
    required String ipAddress,
    String? deviceType,
    @Default(37021) int port,
  }) = _Peer;
}
