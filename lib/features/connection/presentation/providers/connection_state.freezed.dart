// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConnectionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function(List<Peer> discoveredPeers) discovering,
    required TResult Function(Peer peer) connecting,
    required TResult Function(Peer peer) incomingRequest,
    required TResult Function(Peer peer, String dataChannelId) connected,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function(List<Peer> discoveredPeers)? discovering,
    TResult? Function(Peer peer)? connecting,
    TResult? Function(Peer peer)? incomingRequest,
    TResult? Function(Peer peer, String dataChannelId)? connected,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function(List<Peer> discoveredPeers)? discovering,
    TResult Function(Peer peer)? connecting,
    TResult Function(Peer peer)? incomingRequest,
    TResult Function(Peer peer, String dataChannelId)? connected,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Disconnected value) disconnected,
    required TResult Function(_Discovering value) discovering,
    required TResult Function(_Connecting value) connecting,
    required TResult Function(_IncomingRequest value) incomingRequest,
    required TResult Function(_Connected value) connected,
    required TResult Function(_ConnectionError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Disconnected value)? disconnected,
    TResult? Function(_Discovering value)? discovering,
    TResult? Function(_Connecting value)? connecting,
    TResult? Function(_IncomingRequest value)? incomingRequest,
    TResult? Function(_Connected value)? connected,
    TResult? Function(_ConnectionError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Disconnected value)? disconnected,
    TResult Function(_Discovering value)? discovering,
    TResult Function(_Connecting value)? connecting,
    TResult Function(_IncomingRequest value)? incomingRequest,
    TResult Function(_Connected value)? connected,
    TResult Function(_ConnectionError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionStateCopyWith<$Res> {
  factory $ConnectionStateCopyWith(
    ConnectionState value,
    $Res Function(ConnectionState) then,
  ) = _$ConnectionStateCopyWithImpl<$Res, ConnectionState>;
}

/// @nodoc
class _$ConnectionStateCopyWithImpl<$Res, $Val extends ConnectionState>
    implements $ConnectionStateCopyWith<$Res> {
  _$ConnectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DisconnectedImplCopyWith<$Res> {
  factory _$$DisconnectedImplCopyWith(
    _$DisconnectedImpl value,
    $Res Function(_$DisconnectedImpl) then,
  ) = __$$DisconnectedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DisconnectedImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$DisconnectedImpl>
    implements _$$DisconnectedImplCopyWith<$Res> {
  __$$DisconnectedImplCopyWithImpl(
    _$DisconnectedImpl _value,
    $Res Function(_$DisconnectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DisconnectedImpl implements _Disconnected {
  const _$DisconnectedImpl();

  @override
  String toString() {
    return 'ConnectionState.disconnected()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DisconnectedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function(List<Peer> discoveredPeers) discovering,
    required TResult Function(Peer peer) connecting,
    required TResult Function(Peer peer) incomingRequest,
    required TResult Function(Peer peer, String dataChannelId) connected,
    required TResult Function(String message) error,
  }) {
    return disconnected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function(List<Peer> discoveredPeers)? discovering,
    TResult? Function(Peer peer)? connecting,
    TResult? Function(Peer peer)? incomingRequest,
    TResult? Function(Peer peer, String dataChannelId)? connected,
    TResult? Function(String message)? error,
  }) {
    return disconnected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function(List<Peer> discoveredPeers)? discovering,
    TResult Function(Peer peer)? connecting,
    TResult Function(Peer peer)? incomingRequest,
    TResult Function(Peer peer, String dataChannelId)? connected,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (disconnected != null) {
      return disconnected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Disconnected value) disconnected,
    required TResult Function(_Discovering value) discovering,
    required TResult Function(_Connecting value) connecting,
    required TResult Function(_IncomingRequest value) incomingRequest,
    required TResult Function(_Connected value) connected,
    required TResult Function(_ConnectionError value) error,
  }) {
    return disconnected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Disconnected value)? disconnected,
    TResult? Function(_Discovering value)? discovering,
    TResult? Function(_Connecting value)? connecting,
    TResult? Function(_IncomingRequest value)? incomingRequest,
    TResult? Function(_Connected value)? connected,
    TResult? Function(_ConnectionError value)? error,
  }) {
    return disconnected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Disconnected value)? disconnected,
    TResult Function(_Discovering value)? discovering,
    TResult Function(_Connecting value)? connecting,
    TResult Function(_IncomingRequest value)? incomingRequest,
    TResult Function(_Connected value)? connected,
    TResult Function(_ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (disconnected != null) {
      return disconnected(this);
    }
    return orElse();
  }
}

abstract class _Disconnected implements ConnectionState {
  const factory _Disconnected() = _$DisconnectedImpl;
}

/// @nodoc
abstract class _$$DiscoveringImplCopyWith<$Res> {
  factory _$$DiscoveringImplCopyWith(
    _$DiscoveringImpl value,
    $Res Function(_$DiscoveringImpl) then,
  ) = __$$DiscoveringImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Peer> discoveredPeers});
}

/// @nodoc
class __$$DiscoveringImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$DiscoveringImpl>
    implements _$$DiscoveringImplCopyWith<$Res> {
  __$$DiscoveringImplCopyWithImpl(
    _$DiscoveringImpl _value,
    $Res Function(_$DiscoveringImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? discoveredPeers = null}) {
    return _then(
      _$DiscoveringImpl(
        discoveredPeers: null == discoveredPeers
            ? _value._discoveredPeers
            : discoveredPeers // ignore: cast_nullable_to_non_nullable
                  as List<Peer>,
      ),
    );
  }
}

/// @nodoc

class _$DiscoveringImpl implements _Discovering {
  const _$DiscoveringImpl({required final List<Peer> discoveredPeers})
    : _discoveredPeers = discoveredPeers;

  final List<Peer> _discoveredPeers;
  @override
  List<Peer> get discoveredPeers {
    if (_discoveredPeers is EqualUnmodifiableListView) return _discoveredPeers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_discoveredPeers);
  }

  @override
  String toString() {
    return 'ConnectionState.discovering(discoveredPeers: $discoveredPeers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoveringImpl &&
            const DeepCollectionEquality().equals(
              other._discoveredPeers,
              _discoveredPeers,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_discoveredPeers),
  );

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoveringImplCopyWith<_$DiscoveringImpl> get copyWith =>
      __$$DiscoveringImplCopyWithImpl<_$DiscoveringImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function(List<Peer> discoveredPeers) discovering,
    required TResult Function(Peer peer) connecting,
    required TResult Function(Peer peer) incomingRequest,
    required TResult Function(Peer peer, String dataChannelId) connected,
    required TResult Function(String message) error,
  }) {
    return discovering(discoveredPeers);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function(List<Peer> discoveredPeers)? discovering,
    TResult? Function(Peer peer)? connecting,
    TResult? Function(Peer peer)? incomingRequest,
    TResult? Function(Peer peer, String dataChannelId)? connected,
    TResult? Function(String message)? error,
  }) {
    return discovering?.call(discoveredPeers);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function(List<Peer> discoveredPeers)? discovering,
    TResult Function(Peer peer)? connecting,
    TResult Function(Peer peer)? incomingRequest,
    TResult Function(Peer peer, String dataChannelId)? connected,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (discovering != null) {
      return discovering(discoveredPeers);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Disconnected value) disconnected,
    required TResult Function(_Discovering value) discovering,
    required TResult Function(_Connecting value) connecting,
    required TResult Function(_IncomingRequest value) incomingRequest,
    required TResult Function(_Connected value) connected,
    required TResult Function(_ConnectionError value) error,
  }) {
    return discovering(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Disconnected value)? disconnected,
    TResult? Function(_Discovering value)? discovering,
    TResult? Function(_Connecting value)? connecting,
    TResult? Function(_IncomingRequest value)? incomingRequest,
    TResult? Function(_Connected value)? connected,
    TResult? Function(_ConnectionError value)? error,
  }) {
    return discovering?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Disconnected value)? disconnected,
    TResult Function(_Discovering value)? discovering,
    TResult Function(_Connecting value)? connecting,
    TResult Function(_IncomingRequest value)? incomingRequest,
    TResult Function(_Connected value)? connected,
    TResult Function(_ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (discovering != null) {
      return discovering(this);
    }
    return orElse();
  }
}

abstract class _Discovering implements ConnectionState {
  const factory _Discovering({required final List<Peer> discoveredPeers}) =
      _$DiscoveringImpl;

  List<Peer> get discoveredPeers;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoveringImplCopyWith<_$DiscoveringImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectingImplCopyWith<$Res> {
  factory _$$ConnectingImplCopyWith(
    _$ConnectingImpl value,
    $Res Function(_$ConnectingImpl) then,
  ) = __$$ConnectingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Peer peer});

  $PeerCopyWith<$Res> get peer;
}

/// @nodoc
class __$$ConnectingImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$ConnectingImpl>
    implements _$$ConnectingImplCopyWith<$Res> {
  __$$ConnectingImplCopyWithImpl(
    _$ConnectingImpl _value,
    $Res Function(_$ConnectingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? peer = null}) {
    return _then(
      _$ConnectingImpl(
        peer: null == peer
            ? _value.peer
            : peer // ignore: cast_nullable_to_non_nullable
                  as Peer,
      ),
    );
  }

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PeerCopyWith<$Res> get peer {
    return $PeerCopyWith<$Res>(_value.peer, (value) {
      return _then(_value.copyWith(peer: value));
    });
  }
}

/// @nodoc

class _$ConnectingImpl implements _Connecting {
  const _$ConnectingImpl({required this.peer});

  @override
  final Peer peer;

  @override
  String toString() {
    return 'ConnectionState.connecting(peer: $peer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectingImpl &&
            (identical(other.peer, peer) || other.peer == peer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, peer);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectingImplCopyWith<_$ConnectingImpl> get copyWith =>
      __$$ConnectingImplCopyWithImpl<_$ConnectingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function(List<Peer> discoveredPeers) discovering,
    required TResult Function(Peer peer) connecting,
    required TResult Function(Peer peer) incomingRequest,
    required TResult Function(Peer peer, String dataChannelId) connected,
    required TResult Function(String message) error,
  }) {
    return connecting(peer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function(List<Peer> discoveredPeers)? discovering,
    TResult? Function(Peer peer)? connecting,
    TResult? Function(Peer peer)? incomingRequest,
    TResult? Function(Peer peer, String dataChannelId)? connected,
    TResult? Function(String message)? error,
  }) {
    return connecting?.call(peer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function(List<Peer> discoveredPeers)? discovering,
    TResult Function(Peer peer)? connecting,
    TResult Function(Peer peer)? incomingRequest,
    TResult Function(Peer peer, String dataChannelId)? connected,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (connecting != null) {
      return connecting(peer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Disconnected value) disconnected,
    required TResult Function(_Discovering value) discovering,
    required TResult Function(_Connecting value) connecting,
    required TResult Function(_IncomingRequest value) incomingRequest,
    required TResult Function(_Connected value) connected,
    required TResult Function(_ConnectionError value) error,
  }) {
    return connecting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Disconnected value)? disconnected,
    TResult? Function(_Discovering value)? discovering,
    TResult? Function(_Connecting value)? connecting,
    TResult? Function(_IncomingRequest value)? incomingRequest,
    TResult? Function(_Connected value)? connected,
    TResult? Function(_ConnectionError value)? error,
  }) {
    return connecting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Disconnected value)? disconnected,
    TResult Function(_Discovering value)? discovering,
    TResult Function(_Connecting value)? connecting,
    TResult Function(_IncomingRequest value)? incomingRequest,
    TResult Function(_Connected value)? connected,
    TResult Function(_ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (connecting != null) {
      return connecting(this);
    }
    return orElse();
  }
}

abstract class _Connecting implements ConnectionState {
  const factory _Connecting({required final Peer peer}) = _$ConnectingImpl;

  Peer get peer;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectingImplCopyWith<_$ConnectingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IncomingRequestImplCopyWith<$Res> {
  factory _$$IncomingRequestImplCopyWith(
    _$IncomingRequestImpl value,
    $Res Function(_$IncomingRequestImpl) then,
  ) = __$$IncomingRequestImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Peer peer});

  $PeerCopyWith<$Res> get peer;
}

/// @nodoc
class __$$IncomingRequestImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$IncomingRequestImpl>
    implements _$$IncomingRequestImplCopyWith<$Res> {
  __$$IncomingRequestImplCopyWithImpl(
    _$IncomingRequestImpl _value,
    $Res Function(_$IncomingRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? peer = null}) {
    return _then(
      _$IncomingRequestImpl(
        peer: null == peer
            ? _value.peer
            : peer // ignore: cast_nullable_to_non_nullable
                  as Peer,
      ),
    );
  }

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PeerCopyWith<$Res> get peer {
    return $PeerCopyWith<$Res>(_value.peer, (value) {
      return _then(_value.copyWith(peer: value));
    });
  }
}

/// @nodoc

class _$IncomingRequestImpl implements _IncomingRequest {
  const _$IncomingRequestImpl({required this.peer});

  @override
  final Peer peer;

  @override
  String toString() {
    return 'ConnectionState.incomingRequest(peer: $peer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomingRequestImpl &&
            (identical(other.peer, peer) || other.peer == peer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, peer);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomingRequestImplCopyWith<_$IncomingRequestImpl> get copyWith =>
      __$$IncomingRequestImplCopyWithImpl<_$IncomingRequestImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function(List<Peer> discoveredPeers) discovering,
    required TResult Function(Peer peer) connecting,
    required TResult Function(Peer peer) incomingRequest,
    required TResult Function(Peer peer, String dataChannelId) connected,
    required TResult Function(String message) error,
  }) {
    return incomingRequest(peer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function(List<Peer> discoveredPeers)? discovering,
    TResult? Function(Peer peer)? connecting,
    TResult? Function(Peer peer)? incomingRequest,
    TResult? Function(Peer peer, String dataChannelId)? connected,
    TResult? Function(String message)? error,
  }) {
    return incomingRequest?.call(peer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function(List<Peer> discoveredPeers)? discovering,
    TResult Function(Peer peer)? connecting,
    TResult Function(Peer peer)? incomingRequest,
    TResult Function(Peer peer, String dataChannelId)? connected,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (incomingRequest != null) {
      return incomingRequest(peer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Disconnected value) disconnected,
    required TResult Function(_Discovering value) discovering,
    required TResult Function(_Connecting value) connecting,
    required TResult Function(_IncomingRequest value) incomingRequest,
    required TResult Function(_Connected value) connected,
    required TResult Function(_ConnectionError value) error,
  }) {
    return incomingRequest(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Disconnected value)? disconnected,
    TResult? Function(_Discovering value)? discovering,
    TResult? Function(_Connecting value)? connecting,
    TResult? Function(_IncomingRequest value)? incomingRequest,
    TResult? Function(_Connected value)? connected,
    TResult? Function(_ConnectionError value)? error,
  }) {
    return incomingRequest?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Disconnected value)? disconnected,
    TResult Function(_Discovering value)? discovering,
    TResult Function(_Connecting value)? connecting,
    TResult Function(_IncomingRequest value)? incomingRequest,
    TResult Function(_Connected value)? connected,
    TResult Function(_ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (incomingRequest != null) {
      return incomingRequest(this);
    }
    return orElse();
  }
}

abstract class _IncomingRequest implements ConnectionState {
  const factory _IncomingRequest({required final Peer peer}) =
      _$IncomingRequestImpl;

  Peer get peer;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IncomingRequestImplCopyWith<_$IncomingRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectedImplCopyWith<$Res> {
  factory _$$ConnectedImplCopyWith(
    _$ConnectedImpl value,
    $Res Function(_$ConnectedImpl) then,
  ) = __$$ConnectedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Peer peer, String dataChannelId});

  $PeerCopyWith<$Res> get peer;
}

/// @nodoc
class __$$ConnectedImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$ConnectedImpl>
    implements _$$ConnectedImplCopyWith<$Res> {
  __$$ConnectedImplCopyWithImpl(
    _$ConnectedImpl _value,
    $Res Function(_$ConnectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? peer = null, Object? dataChannelId = null}) {
    return _then(
      _$ConnectedImpl(
        peer: null == peer
            ? _value.peer
            : peer // ignore: cast_nullable_to_non_nullable
                  as Peer,
        dataChannelId: null == dataChannelId
            ? _value.dataChannelId
            : dataChannelId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PeerCopyWith<$Res> get peer {
    return $PeerCopyWith<$Res>(_value.peer, (value) {
      return _then(_value.copyWith(peer: value));
    });
  }
}

/// @nodoc

class _$ConnectedImpl implements _Connected {
  const _$ConnectedImpl({required this.peer, required this.dataChannelId});

  @override
  final Peer peer;
  @override
  final String dataChannelId;

  @override
  String toString() {
    return 'ConnectionState.connected(peer: $peer, dataChannelId: $dataChannelId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectedImpl &&
            (identical(other.peer, peer) || other.peer == peer) &&
            (identical(other.dataChannelId, dataChannelId) ||
                other.dataChannelId == dataChannelId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, peer, dataChannelId);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectedImplCopyWith<_$ConnectedImpl> get copyWith =>
      __$$ConnectedImplCopyWithImpl<_$ConnectedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function(List<Peer> discoveredPeers) discovering,
    required TResult Function(Peer peer) connecting,
    required TResult Function(Peer peer) incomingRequest,
    required TResult Function(Peer peer, String dataChannelId) connected,
    required TResult Function(String message) error,
  }) {
    return connected(peer, dataChannelId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function(List<Peer> discoveredPeers)? discovering,
    TResult? Function(Peer peer)? connecting,
    TResult? Function(Peer peer)? incomingRequest,
    TResult? Function(Peer peer, String dataChannelId)? connected,
    TResult? Function(String message)? error,
  }) {
    return connected?.call(peer, dataChannelId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function(List<Peer> discoveredPeers)? discovering,
    TResult Function(Peer peer)? connecting,
    TResult Function(Peer peer)? incomingRequest,
    TResult Function(Peer peer, String dataChannelId)? connected,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (connected != null) {
      return connected(peer, dataChannelId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Disconnected value) disconnected,
    required TResult Function(_Discovering value) discovering,
    required TResult Function(_Connecting value) connecting,
    required TResult Function(_IncomingRequest value) incomingRequest,
    required TResult Function(_Connected value) connected,
    required TResult Function(_ConnectionError value) error,
  }) {
    return connected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Disconnected value)? disconnected,
    TResult? Function(_Discovering value)? discovering,
    TResult? Function(_Connecting value)? connecting,
    TResult? Function(_IncomingRequest value)? incomingRequest,
    TResult? Function(_Connected value)? connected,
    TResult? Function(_ConnectionError value)? error,
  }) {
    return connected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Disconnected value)? disconnected,
    TResult Function(_Discovering value)? discovering,
    TResult Function(_Connecting value)? connecting,
    TResult Function(_IncomingRequest value)? incomingRequest,
    TResult Function(_Connected value)? connected,
    TResult Function(_ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (connected != null) {
      return connected(this);
    }
    return orElse();
  }
}

abstract class _Connected implements ConnectionState {
  const factory _Connected({
    required final Peer peer,
    required final String dataChannelId,
  }) = _$ConnectedImpl;

  Peer get peer;
  String get dataChannelId;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectedImplCopyWith<_$ConnectedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectionErrorImplCopyWith<$Res> {
  factory _$$ConnectionErrorImplCopyWith(
    _$ConnectionErrorImpl value,
    $Res Function(_$ConnectionErrorImpl) then,
  ) = __$$ConnectionErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ConnectionErrorImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$ConnectionErrorImpl>
    implements _$$ConnectionErrorImplCopyWith<$Res> {
  __$$ConnectionErrorImplCopyWithImpl(
    _$ConnectionErrorImpl _value,
    $Res Function(_$ConnectionErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ConnectionErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ConnectionErrorImpl implements _ConnectionError {
  const _$ConnectionErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'ConnectionState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionErrorImplCopyWith<_$ConnectionErrorImpl> get copyWith =>
      __$$ConnectionErrorImplCopyWithImpl<_$ConnectionErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function(List<Peer> discoveredPeers) discovering,
    required TResult Function(Peer peer) connecting,
    required TResult Function(Peer peer) incomingRequest,
    required TResult Function(Peer peer, String dataChannelId) connected,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function(List<Peer> discoveredPeers)? discovering,
    TResult? Function(Peer peer)? connecting,
    TResult? Function(Peer peer)? incomingRequest,
    TResult? Function(Peer peer, String dataChannelId)? connected,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function(List<Peer> discoveredPeers)? discovering,
    TResult Function(Peer peer)? connecting,
    TResult Function(Peer peer)? incomingRequest,
    TResult Function(Peer peer, String dataChannelId)? connected,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Disconnected value) disconnected,
    required TResult Function(_Discovering value) discovering,
    required TResult Function(_Connecting value) connecting,
    required TResult Function(_IncomingRequest value) incomingRequest,
    required TResult Function(_Connected value) connected,
    required TResult Function(_ConnectionError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Disconnected value)? disconnected,
    TResult? Function(_Discovering value)? discovering,
    TResult? Function(_Connecting value)? connecting,
    TResult? Function(_IncomingRequest value)? incomingRequest,
    TResult? Function(_Connected value)? connected,
    TResult? Function(_ConnectionError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Disconnected value)? disconnected,
    TResult Function(_Discovering value)? discovering,
    TResult Function(_Connecting value)? connecting,
    TResult Function(_IncomingRequest value)? incomingRequest,
    TResult Function(_Connected value)? connected,
    TResult Function(_ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _ConnectionError implements ConnectionState {
  const factory _ConnectionError({required final String message}) =
      _$ConnectionErrorImpl;

  String get message;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionErrorImplCopyWith<_$ConnectionErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
