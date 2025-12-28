import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/peer.dart';

part 'connection_state.freezed.dart';

/// Connection state for the application
@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState.disconnected() = _Disconnected;

  const factory ConnectionState.discovering({
    required List<Peer> discoveredPeers,
  }) = _Discovering;

  const factory ConnectionState.connecting({required Peer peer}) = _Connecting;

  const factory ConnectionState.incomingRequest({required Peer peer}) =
      _IncomingRequest;

  const factory ConnectionState.connected({
    required Peer peer,
    required String dataChannelId,
  }) = _Connected;

  const factory ConnectionState.error({required String message}) =
      _ConnectionError;
}
