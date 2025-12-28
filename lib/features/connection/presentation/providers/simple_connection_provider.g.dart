// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$simpleConnectionHash() => r'81dc88200009fdad29db6f65556d16a46e4429c3';

/// Simple HTTP-based connection provider (no WebRTC!)
///
/// Copied from [SimpleConnection].
@ProviderFor(SimpleConnection)
final simpleConnectionProvider =
    AutoDisposeNotifierProvider<SimpleConnection, ConnectionState>.internal(
      SimpleConnection.new,
      name: r'simpleConnectionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$simpleConnectionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SimpleConnection = AutoDisposeNotifier<ConnectionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
