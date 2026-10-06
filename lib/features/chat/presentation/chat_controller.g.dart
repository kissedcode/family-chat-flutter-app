// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatControllerHash() => r'9a785ea1d3983adff203e76f49debdd4216d9e02';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChatController
    extends BuildlessAutoDisposeAsyncNotifier<void> {
  late final String chatId;

  FutureOr<void> build(
    String chatId,
  );
}

/// Контроллер отправки сообщения в чат [chatId] (loading/error для UI).
///
/// Copied from [ChatController].
@ProviderFor(ChatController)
const chatControllerProvider = ChatControllerFamily();

/// Контроллер отправки сообщения в чат [chatId] (loading/error для UI).
///
/// Copied from [ChatController].
class ChatControllerFamily extends Family<AsyncValue<void>> {
  /// Контроллер отправки сообщения в чат [chatId] (loading/error для UI).
  ///
  /// Copied from [ChatController].
  const ChatControllerFamily();

  /// Контроллер отправки сообщения в чат [chatId] (loading/error для UI).
  ///
  /// Copied from [ChatController].
  ChatControllerProvider call(
    String chatId,
  ) {
    return ChatControllerProvider(
      chatId,
    );
  }

  @override
  ChatControllerProvider getProviderOverride(
    covariant ChatControllerProvider provider,
  ) {
    return call(
      provider.chatId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatControllerProvider';
}

/// Контроллер отправки сообщения в чат [chatId] (loading/error для UI).
///
/// Copied from [ChatController].
class ChatControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChatController, void> {
  /// Контроллер отправки сообщения в чат [chatId] (loading/error для UI).
  ///
  /// Copied from [ChatController].
  ChatControllerProvider(
    String chatId,
  ) : this._internal(
          () => ChatController()..chatId = chatId,
          from: chatControllerProvider,
          name: r'chatControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatControllerHash,
          dependencies: ChatControllerFamily._dependencies,
          allTransitiveDependencies:
              ChatControllerFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  ChatControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  FutureOr<void> runNotifierBuild(
    covariant ChatController notifier,
  ) {
    return notifier.build(
      chatId,
    );
  }

  @override
  Override overrideWith(ChatController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatControllerProvider._internal(
        () => create()..chatId = chatId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChatController, void>
      createElement() {
    return _ChatControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatControllerProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatControllerRef on AutoDisposeAsyncNotifierProviderRef<void> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ChatControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChatController, void>
    with ChatControllerRef {
  _ChatControllerProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatControllerProvider).chatId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
