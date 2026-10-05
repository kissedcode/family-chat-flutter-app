import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profile/data/user_repository.dart';
import '../domain/message.dart';

part 'chat_repository.g.dart';

/// Максимальная длина сообщения — как в Telegram.
const int kMaxMessageLength = 4096;

/// Доступ к общему семейному чату в Firestore.
///
/// В v1 — одна коллекция `messages/{messageId}`.
/// Настраивает офлайн-persistence Firestore при первом обращении.
class ChatRepository {
  ChatRepository({
    FirebaseFirestore? db,
    UserRepository? userRepository,
  })  : _db = db ?? FirebaseFirestore.instance,
        _userRepository = userRepository ?? UserRepository();

  final FirebaseFirestore _db;
  final UserRepository _userRepository;

  CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('messages');

  Stream<List<Message>> messagesStream({int limit = 100}) {
    return _messages
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(Message.fromDoc).toList());
  }

  /// Отправка сообщения от текущего пользователя.
  /// Бросает [ArgumentError] при нарушении правил длины,
  /// [StateError] если нет авторизованного пользователя.
  Future<void> sendMessage(String rawText) async {
    final user = FirebaseAuth.instance.currentUser;
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

    // Пробуем взять снапшот имени и аватара из users/{uid}.
    // Если документа ещё нет — падаем на Firebase Auth.
    String name;
    String? avatarUrl;
    try {
      final profile = await _userRepository.fetchProfile(user.uid);
      if (profile != null && profile.displayName.isNotEmpty) {
        name = profile.displayName;
        avatarUrl = profile.avatarUrl;
      } else {
        name = _fallbackName(user);
        avatarUrl = user.photoURL;
      }
    } catch (_) {
      name = _fallbackName(user);
      avatarUrl = user.photoURL;
    }

    await _messages.add(
      Message.toCreateData(
        text: text,
        senderId: user.uid,
        senderName: name,
        senderAvatarUrl: avatarUrl,
      ),
    );
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

@Riverpod(keepAlive: true)
Stream<List<Message>> messagesStream(Ref ref) {
  return ref.watch(chatRepositoryProvider).messagesStream();
}
