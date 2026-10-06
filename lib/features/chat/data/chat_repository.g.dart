// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'81feebad4d4f3356e6c12e98c9b94ac8b326d86e';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = Provider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatRepositoryRef = ProviderRef<ChatRepository>;
String _$currentUidHash() => r'3eee979bb8b38b7e019d3a39dfcac690ba67d8fd';

/// uid текущего пользователя (null — не вошёл).
///
/// Copied from [currentUid].
@ProviderFor(currentUid)
final currentUidProvider = Provider<String?>.internal(
  currentUid,
  name: r'currentUidProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUidHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUidRef = ProviderRef<String?>;
String _$messagesStreamHash() => r'9108baec3304a491135456055ee3c36f3efcacb3';

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

/// See also [messagesStream].
@ProviderFor(messagesStream)
const messagesStreamProvider = MessagesStreamFamily();

/// See also [messagesStream].
class MessagesStreamFamily extends Family<AsyncValue<List<Message>>> {
  /// See also [messagesStream].
  const MessagesStreamFamily();

  /// See also [messagesStream].
  MessagesStreamProvider call(
    String chatId,
  ) {
    return MessagesStreamProvider(
      chatId,
    );
  }

  @override
  MessagesStreamProvider getProviderOverride(
    covariant MessagesStreamProvider provider,
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
  String? get name => r'messagesStreamProvider';
}

/// See also [messagesStream].
class MessagesStreamProvider extends AutoDisposeStreamProvider<List<Message>> {
  /// See also [messagesStream].
  MessagesStreamProvider(
    String chatId,
  ) : this._internal(
          (ref) => messagesStream(
            ref as MessagesStreamRef,
            chatId,
          ),
          from: messagesStreamProvider,
          name: r'messagesStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messagesStreamHash,
          dependencies: MessagesStreamFamily._dependencies,
          allTransitiveDependencies:
              MessagesStreamFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  MessagesStreamProvider._internal(
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
  Override overrideWith(
    Stream<List<Message>> Function(MessagesStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesStreamProvider._internal(
        (ref) => create(ref as MessagesStreamRef),
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
  AutoDisposeStreamProviderElement<List<Message>> createElement() {
    return _MessagesStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesStreamProvider && other.chatId == chatId;
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
mixin MessagesStreamRef on AutoDisposeStreamProviderRef<List<Message>> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _MessagesStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Message>>
    with MessagesStreamRef {
  _MessagesStreamProviderElement(super.provider);

  @override
  String get chatId => (origin as MessagesStreamProvider).chatId;
}

String _$generalLastMessageHash() =>
    r'60d9e7fdcae36d45ffe4905b81563b79da93c855';

/// See also [generalLastMessage].
@ProviderFor(generalLastMessage)
final generalLastMessageProvider = AutoDisposeStreamProvider<Message?>.internal(
  generalLastMessage,
  name: r'generalLastMessageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$generalLastMessageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeneralLastMessageRef = AutoDisposeStreamProviderRef<Message?>;
String _$directChatsHash() => r'8a370cccdf33c4a3445982a58eb6be426e5fa074';

/// See also [directChats].
@ProviderFor(directChats)
final directChatsProvider =
    AutoDisposeStreamProvider<List<DirectChat>>.internal(
  directChats,
  name: r'directChatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$directChatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DirectChatsRef = AutoDisposeStreamProviderRef<List<DirectChat>>;
String _$unreadCountHash() => r'05d5ec83524ab1522db0d1d5d2039ea4730a5163';

/// See also [unreadCount].
@ProviderFor(unreadCount)
const unreadCountProvider = UnreadCountFamily();

/// See also [unreadCount].
class UnreadCountFamily extends Family<AsyncValue<int>> {
  /// See also [unreadCount].
  const UnreadCountFamily();

  /// See also [unreadCount].
  UnreadCountProvider call(
    String chatId,
  ) {
    return UnreadCountProvider(
      chatId,
    );
  }

  @override
  UnreadCountProvider getProviderOverride(
    covariant UnreadCountProvider provider,
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
  String? get name => r'unreadCountProvider';
}

/// See also [unreadCount].
class UnreadCountProvider extends AutoDisposeStreamProvider<int> {
  /// See also [unreadCount].
  UnreadCountProvider(
    String chatId,
  ) : this._internal(
          (ref) => unreadCount(
            ref as UnreadCountRef,
            chatId,
          ),
          from: unreadCountProvider,
          name: r'unreadCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unreadCountHash,
          dependencies: UnreadCountFamily._dependencies,
          allTransitiveDependencies:
              UnreadCountFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  UnreadCountProvider._internal(
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
  Override overrideWith(
    Stream<int> Function(UnreadCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnreadCountProvider._internal(
        (ref) => create(ref as UnreadCountRef),
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
  AutoDisposeStreamProviderElement<int> createElement() {
    return _UnreadCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadCountProvider && other.chatId == chatId;
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
mixin UnreadCountRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _UnreadCountProviderElement extends AutoDisposeStreamProviderElement<int>
    with UnreadCountRef {
  _UnreadCountProviderElement(super.provider);

  @override
  String get chatId => (origin as UnreadCountProvider).chatId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
