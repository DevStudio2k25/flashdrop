// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simple_transfer_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SimpleTransferState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(List<FileMetadata> files) preparing,
    required TResult Function(
      TransferProgress progress,
      List<FileMetadata> files,
    )
    transferring,
    required TResult Function(List<FileMetadata> files, Duration duration)
    completed,
    required TResult Function(String error) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(List<FileMetadata> files)? preparing,
    TResult? Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult? Function(List<FileMetadata> files, Duration duration)? completed,
    TResult? Function(String error)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(List<FileMetadata> files)? preparing,
    TResult Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult Function(List<FileMetadata> files, Duration duration)? completed,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Preparing value) preparing,
    required TResult Function(_Transferring value) transferring,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Failed value) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Preparing value)? preparing,
    TResult? Function(_Transferring value)? transferring,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Failed value)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Preparing value)? preparing,
    TResult Function(_Transferring value)? transferring,
    TResult Function(_Completed value)? completed,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimpleTransferStateCopyWith<$Res> {
  factory $SimpleTransferStateCopyWith(
    SimpleTransferState value,
    $Res Function(SimpleTransferState) then,
  ) = _$SimpleTransferStateCopyWithImpl<$Res, SimpleTransferState>;
}

/// @nodoc
class _$SimpleTransferStateCopyWithImpl<$Res, $Val extends SimpleTransferState>
    implements $SimpleTransferStateCopyWith<$Res> {
  _$SimpleTransferStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
    _$IdleImpl value,
    $Res Function(_$IdleImpl) then,
  ) = __$$IdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$SimpleTransferStateCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
    : super(_value, _then);

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$IdleImpl implements _Idle {
  const _$IdleImpl();

  @override
  String toString() {
    return 'SimpleTransferState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(List<FileMetadata> files) preparing,
    required TResult Function(
      TransferProgress progress,
      List<FileMetadata> files,
    )
    transferring,
    required TResult Function(List<FileMetadata> files, Duration duration)
    completed,
    required TResult Function(String error) failed,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(List<FileMetadata> files)? preparing,
    TResult? Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult? Function(List<FileMetadata> files, Duration duration)? completed,
    TResult? Function(String error)? failed,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(List<FileMetadata> files)? preparing,
    TResult Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult Function(List<FileMetadata> files, Duration duration)? completed,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Preparing value) preparing,
    required TResult Function(_Transferring value) transferring,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Failed value) failed,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Preparing value)? preparing,
    TResult? Function(_Transferring value)? transferring,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Failed value)? failed,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Preparing value)? preparing,
    TResult Function(_Transferring value)? transferring,
    TResult Function(_Completed value)? completed,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _Idle implements SimpleTransferState {
  const factory _Idle() = _$IdleImpl;
}

/// @nodoc
abstract class _$$PreparingImplCopyWith<$Res> {
  factory _$$PreparingImplCopyWith(
    _$PreparingImpl value,
    $Res Function(_$PreparingImpl) then,
  ) = __$$PreparingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<FileMetadata> files});
}

/// @nodoc
class __$$PreparingImplCopyWithImpl<$Res>
    extends _$SimpleTransferStateCopyWithImpl<$Res, _$PreparingImpl>
    implements _$$PreparingImplCopyWith<$Res> {
  __$$PreparingImplCopyWithImpl(
    _$PreparingImpl _value,
    $Res Function(_$PreparingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? files = null}) {
    return _then(
      _$PreparingImpl(
        files: null == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<FileMetadata>,
      ),
    );
  }
}

/// @nodoc

class _$PreparingImpl implements _Preparing {
  const _$PreparingImpl({required final List<FileMetadata> files})
    : _files = files;

  final List<FileMetadata> _files;
  @override
  List<FileMetadata> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  @override
  String toString() {
    return 'SimpleTransferState.preparing(files: $files)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreparingImpl &&
            const DeepCollectionEquality().equals(other._files, _files));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_files));

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreparingImplCopyWith<_$PreparingImpl> get copyWith =>
      __$$PreparingImplCopyWithImpl<_$PreparingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(List<FileMetadata> files) preparing,
    required TResult Function(
      TransferProgress progress,
      List<FileMetadata> files,
    )
    transferring,
    required TResult Function(List<FileMetadata> files, Duration duration)
    completed,
    required TResult Function(String error) failed,
  }) {
    return preparing(files);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(List<FileMetadata> files)? preparing,
    TResult? Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult? Function(List<FileMetadata> files, Duration duration)? completed,
    TResult? Function(String error)? failed,
  }) {
    return preparing?.call(files);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(List<FileMetadata> files)? preparing,
    TResult Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult Function(List<FileMetadata> files, Duration duration)? completed,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (preparing != null) {
      return preparing(files);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Preparing value) preparing,
    required TResult Function(_Transferring value) transferring,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Failed value) failed,
  }) {
    return preparing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Preparing value)? preparing,
    TResult? Function(_Transferring value)? transferring,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Failed value)? failed,
  }) {
    return preparing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Preparing value)? preparing,
    TResult Function(_Transferring value)? transferring,
    TResult Function(_Completed value)? completed,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (preparing != null) {
      return preparing(this);
    }
    return orElse();
  }
}

abstract class _Preparing implements SimpleTransferState {
  const factory _Preparing({required final List<FileMetadata> files}) =
      _$PreparingImpl;

  List<FileMetadata> get files;

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreparingImplCopyWith<_$PreparingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TransferringImplCopyWith<$Res> {
  factory _$$TransferringImplCopyWith(
    _$TransferringImpl value,
    $Res Function(_$TransferringImpl) then,
  ) = __$$TransferringImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TransferProgress progress, List<FileMetadata> files});
}

/// @nodoc
class __$$TransferringImplCopyWithImpl<$Res>
    extends _$SimpleTransferStateCopyWithImpl<$Res, _$TransferringImpl>
    implements _$$TransferringImplCopyWith<$Res> {
  __$$TransferringImplCopyWithImpl(
    _$TransferringImpl _value,
    $Res Function(_$TransferringImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? progress = null, Object? files = null}) {
    return _then(
      _$TransferringImpl(
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as TransferProgress,
        files: null == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<FileMetadata>,
      ),
    );
  }
}

/// @nodoc

class _$TransferringImpl implements _Transferring {
  const _$TransferringImpl({
    required this.progress,
    required final List<FileMetadata> files,
  }) : _files = files;

  @override
  final TransferProgress progress;
  final List<FileMetadata> _files;
  @override
  List<FileMetadata> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  @override
  String toString() {
    return 'SimpleTransferState.transferring(progress: $progress, files: $files)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferringImpl &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            const DeepCollectionEquality().equals(other._files, _files));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    progress,
    const DeepCollectionEquality().hash(_files),
  );

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferringImplCopyWith<_$TransferringImpl> get copyWith =>
      __$$TransferringImplCopyWithImpl<_$TransferringImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(List<FileMetadata> files) preparing,
    required TResult Function(
      TransferProgress progress,
      List<FileMetadata> files,
    )
    transferring,
    required TResult Function(List<FileMetadata> files, Duration duration)
    completed,
    required TResult Function(String error) failed,
  }) {
    return transferring(progress, files);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(List<FileMetadata> files)? preparing,
    TResult? Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult? Function(List<FileMetadata> files, Duration duration)? completed,
    TResult? Function(String error)? failed,
  }) {
    return transferring?.call(progress, files);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(List<FileMetadata> files)? preparing,
    TResult Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult Function(List<FileMetadata> files, Duration duration)? completed,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (transferring != null) {
      return transferring(progress, files);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Preparing value) preparing,
    required TResult Function(_Transferring value) transferring,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Failed value) failed,
  }) {
    return transferring(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Preparing value)? preparing,
    TResult? Function(_Transferring value)? transferring,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Failed value)? failed,
  }) {
    return transferring?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Preparing value)? preparing,
    TResult Function(_Transferring value)? transferring,
    TResult Function(_Completed value)? completed,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (transferring != null) {
      return transferring(this);
    }
    return orElse();
  }
}

abstract class _Transferring implements SimpleTransferState {
  const factory _Transferring({
    required final TransferProgress progress,
    required final List<FileMetadata> files,
  }) = _$TransferringImpl;

  TransferProgress get progress;
  List<FileMetadata> get files;

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransferringImplCopyWith<_$TransferringImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CompletedImplCopyWith<$Res> {
  factory _$$CompletedImplCopyWith(
    _$CompletedImpl value,
    $Res Function(_$CompletedImpl) then,
  ) = __$$CompletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<FileMetadata> files, Duration duration});
}

/// @nodoc
class __$$CompletedImplCopyWithImpl<$Res>
    extends _$SimpleTransferStateCopyWithImpl<$Res, _$CompletedImpl>
    implements _$$CompletedImplCopyWith<$Res> {
  __$$CompletedImplCopyWithImpl(
    _$CompletedImpl _value,
    $Res Function(_$CompletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? files = null, Object? duration = null}) {
    return _then(
      _$CompletedImpl(
        files: null == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<FileMetadata>,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as Duration,
      ),
    );
  }
}

/// @nodoc

class _$CompletedImpl implements _Completed {
  const _$CompletedImpl({
    required final List<FileMetadata> files,
    required this.duration,
  }) : _files = files;

  final List<FileMetadata> _files;
  @override
  List<FileMetadata> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  @override
  final Duration duration;

  @override
  String toString() {
    return 'SimpleTransferState.completed(files: $files, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletedImpl &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_files),
    duration,
  );

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletedImplCopyWith<_$CompletedImpl> get copyWith =>
      __$$CompletedImplCopyWithImpl<_$CompletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(List<FileMetadata> files) preparing,
    required TResult Function(
      TransferProgress progress,
      List<FileMetadata> files,
    )
    transferring,
    required TResult Function(List<FileMetadata> files, Duration duration)
    completed,
    required TResult Function(String error) failed,
  }) {
    return completed(files, duration);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(List<FileMetadata> files)? preparing,
    TResult? Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult? Function(List<FileMetadata> files, Duration duration)? completed,
    TResult? Function(String error)? failed,
  }) {
    return completed?.call(files, duration);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(List<FileMetadata> files)? preparing,
    TResult Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult Function(List<FileMetadata> files, Duration duration)? completed,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(files, duration);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Preparing value) preparing,
    required TResult Function(_Transferring value) transferring,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Failed value) failed,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Preparing value)? preparing,
    TResult? Function(_Transferring value)? transferring,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Failed value)? failed,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Preparing value)? preparing,
    TResult Function(_Transferring value)? transferring,
    TResult Function(_Completed value)? completed,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class _Completed implements SimpleTransferState {
  const factory _Completed({
    required final List<FileMetadata> files,
    required final Duration duration,
  }) = _$CompletedImpl;

  List<FileMetadata> get files;
  Duration get duration;

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompletedImplCopyWith<_$CompletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailedImplCopyWith<$Res> {
  factory _$$FailedImplCopyWith(
    _$FailedImpl value,
    $Res Function(_$FailedImpl) then,
  ) = __$$FailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$FailedImplCopyWithImpl<$Res>
    extends _$SimpleTransferStateCopyWithImpl<$Res, _$FailedImpl>
    implements _$$FailedImplCopyWith<$Res> {
  __$$FailedImplCopyWithImpl(
    _$FailedImpl _value,
    $Res Function(_$FailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? error = null}) {
    return _then(
      _$FailedImpl(
        error: null == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FailedImpl implements _Failed {
  const _$FailedImpl({required this.error});

  @override
  final String error;

  @override
  String toString() {
    return 'SimpleTransferState.failed(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailedImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FailedImplCopyWith<_$FailedImpl> get copyWith =>
      __$$FailedImplCopyWithImpl<_$FailedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(List<FileMetadata> files) preparing,
    required TResult Function(
      TransferProgress progress,
      List<FileMetadata> files,
    )
    transferring,
    required TResult Function(List<FileMetadata> files, Duration duration)
    completed,
    required TResult Function(String error) failed,
  }) {
    return failed(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(List<FileMetadata> files)? preparing,
    TResult? Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult? Function(List<FileMetadata> files, Duration duration)? completed,
    TResult? Function(String error)? failed,
  }) {
    return failed?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(List<FileMetadata> files)? preparing,
    TResult Function(TransferProgress progress, List<FileMetadata> files)?
    transferring,
    TResult Function(List<FileMetadata> files, Duration duration)? completed,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Preparing value) preparing,
    required TResult Function(_Transferring value) transferring,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Failed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Preparing value)? preparing,
    TResult? Function(_Transferring value)? transferring,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Failed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Preparing value)? preparing,
    TResult Function(_Transferring value)? transferring,
    TResult Function(_Completed value)? completed,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class _Failed implements SimpleTransferState {
  const factory _Failed({required final String error}) = _$FailedImpl;

  String get error;

  /// Create a copy of SimpleTransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FailedImplCopyWith<_$FailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
