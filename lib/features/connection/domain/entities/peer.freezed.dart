// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'peer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Peer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;
  String? get deviceType => throw _privateConstructorUsedError;
  int get port => throw _privateConstructorUsedError;

  /// Create a copy of Peer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeerCopyWith<Peer> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeerCopyWith<$Res> {
  factory $PeerCopyWith(Peer value, $Res Function(Peer) then) =
      _$PeerCopyWithImpl<$Res, Peer>;
  @useResult
  $Res call({
    String id,
    String name,
    String ipAddress,
    String? deviceType,
    int port,
  });
}

/// @nodoc
class _$PeerCopyWithImpl<$Res, $Val extends Peer>
    implements $PeerCopyWith<$Res> {
  _$PeerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Peer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ipAddress = null,
    Object? deviceType = freezed,
    Object? port = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceType: freezed == deviceType
                ? _value.deviceType
                : deviceType // ignore: cast_nullable_to_non_nullable
                      as String?,
            port: null == port
                ? _value.port
                : port // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PeerImplCopyWith<$Res> implements $PeerCopyWith<$Res> {
  factory _$$PeerImplCopyWith(
    _$PeerImpl value,
    $Res Function(_$PeerImpl) then,
  ) = __$$PeerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String ipAddress,
    String? deviceType,
    int port,
  });
}

/// @nodoc
class __$$PeerImplCopyWithImpl<$Res>
    extends _$PeerCopyWithImpl<$Res, _$PeerImpl>
    implements _$$PeerImplCopyWith<$Res> {
  __$$PeerImplCopyWithImpl(_$PeerImpl _value, $Res Function(_$PeerImpl) _then)
    : super(_value, _then);

  /// Create a copy of Peer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ipAddress = null,
    Object? deviceType = freezed,
    Object? port = null,
  }) {
    return _then(
      _$PeerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceType: freezed == deviceType
            ? _value.deviceType
            : deviceType // ignore: cast_nullable_to_non_nullable
                  as String?,
        port: null == port
            ? _value.port
            : port // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$PeerImpl implements _Peer {
  const _$PeerImpl({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.deviceType,
    this.port = 37021,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String ipAddress;
  @override
  final String? deviceType;
  @override
  @JsonKey()
  final int port;

  @override
  String toString() {
    return 'Peer(id: $id, name: $name, ipAddress: $ipAddress, deviceType: $deviceType, port: $port)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.port, port) || other.port == port));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, ipAddress, deviceType, port);

  /// Create a copy of Peer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerImplCopyWith<_$PeerImpl> get copyWith =>
      __$$PeerImplCopyWithImpl<_$PeerImpl>(this, _$identity);
}

abstract class _Peer implements Peer {
  const factory _Peer({
    required final String id,
    required final String name,
    required final String ipAddress,
    final String? deviceType,
    final int port,
  }) = _$PeerImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get ipAddress;
  @override
  String? get deviceType;
  @override
  int get port;

  /// Create a copy of Peer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeerImplCopyWith<_$PeerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
