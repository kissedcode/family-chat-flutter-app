import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_repository.dart';
import '../domain/direct_chat.dart';
import '../domain/message.dart';

part 'chat_repository.g.dart';

/// Максимальная длина сообщения — как в Telegram.
const int kMaxMessageLength = 4096;

/// Сколько сообщений грузим в ленту и максимум для счётчика непрочитанных.
const int kMessagesPageSize = 100;

/// Доступ к чатам в Firestore:
/// - общий чат — коллекция `messages` (верхний уровень, без миграции с v0.2);
/// - личные чаты — `chats/{uidA_uidB}` + подколлекция `messages`;
/// - отметки прочтения — `users/{uid}/reads/{chatId}`.
class ChatRepository {
  ChatRepository({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
    UserRepository? userRepository,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepository();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  CollectionReference<Map<String, dynamic>> _messagesOf(String chatId) =>
      chatId == kGeneralChatId
          ? _db.collection('messages')
          : _chats.doc(chatId).collection('messages');

  DocumentReference<Map<String, dynamic>> _readsDoc(
    String uid,
    String chatId,
  ) =>
      _db.collection('users').doc(uid).collection('reads').doc(chatId);

  /// Лента последних сообщений чата (новые первыми).
  Stream<List<Message>> messagesStream(
    String chatId, {
    int limit = kMessagesPageSize,
  }) {
    return _messagesOf(chatId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(Message.fromDoc).toList());
  }

  /// Последнее сообщение общего чата — для превью в списке.
  Stream<Message?> generalLastMessageStream() {
    return _messagesOf(kGeneralChatId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.isEmpty ? null : Message.fromDoc(snap.docs.first));
  }

  /// Личные чаты пользователя, свежие первыми.
  Stream<List<DirectChat>> directChatsStream(String myUid) {
    return _chats
        .where('members', arrayContains: myUid)
        .orderBy('lastMessage.createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(DirectChat.fromDoc).toList());
  }

  /// Число чужих сообщений после отметки `lastReadAt` (не больше [kMessagesPageSize]).
  Stream<int> unreadCountStream(String chatId, String myUid) {
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? readsSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? messagesSub;
    late final StreamController<int> controller;

    void listenMessages(Timestamp? lastReadAt) {
      messagesSub?.cancel();
      Query<Map<String, dynamic>> q = _messagesOf(chatId);
      q = lastReadAt == null
          ? q.orderBy('createdAt', descending: true)
          : q.where('createdAt', isGreaterThan: lastReadAt).orderBy('createdAt');
      messagesSub = q.limit(kMessagesPageSize).snapshots().listen(
        (snap) {
          final count =
              snap.docs.where((d) => d.data()['senderId'] != myUid).length;
          if (!controller.isClosed) controller.add(count);
        },
        onError: (Object e, StackTrace st) {
          if (!controller.isClosed) controller.addError(e, st);
        },
      );
    }

    controller = StreamController<int>(
      onListen: () {
        readsSub = _readsDoc(myUid, chatId).snapshots().listen(
          (snap) {
            final raw = snap.data()?['lastReadAt'];
            Timestamp? lastReadAt;
            if (raw is Timestamp) {
              lastReadAt = raw;
            } else if (snap.exists) {
              // serverTimestamp ещё не подтверждён сервером — берём локальное время.
              lastReadAt = Timestamp.now();
            }
            listenMessages(lastReadAt);
          },
          onError: (Object e, StackTrace st) {
            if (!controller.isClosed) controller.addError(e, st);
          },
        );
      },
      onCancel: () async {
        await messagesSub?.cancel();
        await readsSub?.cancel();
      },
    );
    return controller.stream;
  }

  /// Отметить чат прочитанным «до текущего момента».
  Future<void> markRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _readsDoc(user.uid, chatId)
        .set({'lastReadAt': FieldValue.serverTimestamp()});
  }

  /// Отправка сообщения от текущего пользователя в чат [chatId].
  /// Бросает [ArgumentError] при нарушении правил длины,
  /// [StateError] если нет авторизованного пользователя.
  Future<void> sendMessage(String chatId, String rawText) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Нет авторизованного пользователя');
    }

    final text = rawText.trim();
    if (text.isEmpty) {
      throw ArgumentError('Пустое сообщение');
    }
    if (text.length > kMaxMessageLength) {
      throw ArgumentError('Сообщение длиннее $kMaxMessageLength символов');
    }

    final (name, avatarUrl) = await _senderSnapshot(user);
    final messageData = Message.toCreateData(
      text: text,
      senderId: user.uid,
      senderName: name,
      senderAvatarUrl: avatarUrl,
    );

    if (chatId == kGeneralChatId) {
      await _messagesOf(chatId).add(messageData);
      return;
    }

    final other = otherMemberOf(chatId, user.uid);
    if (other == null) {
      throw ArgumentError('Некорректный id чата: $chatId');
    }

    final chatRef = _chats.doc(chatId);
    final lastMessage = {
      'text': text.length > kLastMessagePreviewLength
          ? text.substring(0, kLastMessagePreviewLength)
          : text,
      'senderId': user.uid,
      'senderName': name,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final exists = await _chatExists(chatRef);
    final batch = _db.batch();
    batch.set(chatRef.collection('messages').doc(), messageData);
    if (exists) {
      batch.update(chatRef, {'lastMessage': lastMessage});
    } else {
      final members = [user.uid, other]..sort();
      batch.set(chatRef, {
        'members': members,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': lastMessage,
      });
    }
    await batch.commit();
  }

  Future<bool> _chatExists(DocumentReference<Map<String, dynamic>> ref) async {
    try {
      return (await ref.get()).exists;
    } catch (_) {
      try {
        return (await ref.get(const GetOptions(source: Source.cache))).exists;
      } catch (_) {
        return false;
      }
    }
  }

  /// Снапшот имени и аватара из users/{uid}; fallback — Firebase Auth.
  Future<(String, String?)> _senderSnapshot(User user) async {
    try {
      final profile = await _userRepository.fetchProfile(user.uid);
      if (profile != null && profile.displayName.isNotEmpty) {
        return (profile.displayName, profile.avatarUrl);
      }
    } catch (_) {
      // fallback ниже
    }
    return (_fallbackName(user), user.photoURL);
  }

  String _fallbackName(User user) {
    if (user.displayName?.trim().isNotEmpty ?? false) {
      return user.displayName!.trim();
    }
    return user.email ?? 'Без имени';
  }
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(userRepository: ref.watch(userRepositoryProvider));
}

/// uid текущего пользователя (null — не вошёл).
@Riverpod(keepAlive: true)
String? currentUid(Ref ref) {
  return ref.watch(authStateChangesProvider).value?.uid;
}

@riverpod
Stream<List<Message>> messagesStream(Ref ref, String chatId) {
  return ref.watch(chatRepositoryProvider).messagesStream(chatId);
}

@riverpod
Stream<Message?> generalLastMessage(Ref ref) {
  return ref.watch(chatRepositoryProvider).generalLastMessageStream();
}

@riverpod
Stream<List<DirectChat>> directChats(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(chatRepositoryProvider).directChatsStream(uid);
}

@riverpod
Stream<int> unreadCount(Ref ref, String chatId) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(0);
  return ref.watch(chatRepositoryProvider).unreadCountStream(chatId, uid);
}
