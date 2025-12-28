// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chunk.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Chunk {
  int get index => throw _privateConstructorUsedError;
  Uint8List get data => throw _privateConstructorUsedError;
  String get checksum => throw _privateConstructorUsedError;
  int get totalChunks => throw _privateConstructorUsedError;

  /// Create a copy of Chunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChunkCopyWith<Chunk> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChunkCopyWith<$Res> {
  factory $ChunkCopyWith(Chunk value, $Res Function(Chunk) then) =
      _$ChunkCopyWithImpl<$Res, Chunk>;
  @useResult
  $Res call({int index, Uint8List data, String checksum, int totalChunks});
}

/// @nodoc
class _$ChunkCopyWithImpl<$Res, $Val extends Chunk>
    implements $ChunkCopyWith<$Res> {
  _$ChunkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Chunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? data = null,
    Object? checksum = null,
    Object? totalChunks = null,
  }) {
    return _then(
      _value.copyWith(
            index: null == index
                ? _value.index
                : index // ignore: cast_nullable_to_non_nullable
                      as int,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
            checksum: null == checksum
                ? _value.checksum
                : checksum // ignore: cast_nullable_to_non_nullable
                      as String,
            totalChunks: null == totalChunks
                ? _value.totalChunks
                : totalChunks // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChunkImplCopyWith<$Res> implements $ChunkCopyWith<$Res> {
  factory _$$ChunkImplCopyWith(
    _$ChunkImpl value,
    $Res Function(_$ChunkImpl) then,
  ) = __$$ChunkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int index, Uint8List data, String checksum, int totalChunks});
}

/// @nodoc
class __$$ChunkImplCopyWithImpl<$Res>
    extends _$ChunkCopyWithImpl<$Res, _$ChunkImpl>
    implements _$$ChunkImplCopyWith<$Res> {
  __$$ChunkImplCopyWithImpl(
    _$ChunkImpl _value,
    $Res Function(_$ChunkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Chunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? data = null,
    Object? checksum = null,
    Object? totalChunks = null,
  }) {
    return _then(
      _$ChunkImpl(
        index: null == index
            ? _value.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int,
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
        checksum: null == checksum
            ? _value.checksum
            : checksum // ignore: cast_nullable_to_non_nullable
                  as String,
        totalChunks: null == totalChunks
            ? _value.totalChunks
            : totalChunks // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ChunkImpl implements _Chunk {
  const _$ChunkImpl({
    required this.index,
    required this.data,
    required this.checksum,
    required this.totalChunks,
  });

  @override
  final int index;
  @override
  final Uint8List data;
  @override
  final String checksum;
  @override
  final int totalChunks;

  @override
  String toString() {
    return 'Chunk(index: $index, data: $data, checksum: $checksum, totalChunks: $totalChunks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChunkImpl &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.checksum, checksum) ||
                other.checksum == checksum) &&
            (identical(other.totalChunks, totalChunks) ||
                other.totalChunks == totalChunks));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    index,
    const DeepCollectionEquality().hash(data),
    checksum,
    totalChunks,
  );

  /// Create a copy of Chunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChunkImplCopyWith<_$ChunkImpl> get copyWith =>
      __$$ChunkImplCopyWithImpl<_$ChunkImpl>(this, _$identity);
}

abstract class _Chunk implements Chunk {
  const factory _Chunk({
    required final int index,
    required final Uint8List data,
    required final String checksum,
    required final int totalChunks,
  }) = _$ChunkImpl;

  @override
  int get index;
  @override
  Uint8List get data;
  @override
  String get checksum;
  @override
  int get totalChunks;

  /// Create a copy of Chunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChunkImplCopyWith<_$ChunkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
