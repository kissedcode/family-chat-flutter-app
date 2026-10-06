import 'package:cloud_firestore/cloud_firestore.dart';

/// Id общего семейного чата (сообщения лежат в коллекции `messages`).
const String kGeneralChatId = 'general';

/// Максимальная длина текста в `lastMessage` (превью в списке чатов).
const int kLastMessagePreviewLength = 200;

/// Детерминированный id личного чата: `<uidA>_<uidB>`, uidA < uidB.
String directChatId(String uid1, String uid2) {
  final pair = [uid1, uid2]..sort();
  return '${pair[0]}_${pair[1]}';
}

/// uid собеседника в личном чате (или null для общего / некорректного id).
String? otherMemberOf(String chatId, String myUid) {
  if (chatId == kGeneralChatId) return null;
  final parts = chatId.split('_');
  if (parts.length != 2 || !parts.contains(myUid)) return null;
  return parts[0] == myUid ? parts[1] : parts[0];
}

/// Копия последнего сообщения чата для превью.
class LastMessage {
  const LastMessage({
    required this.text,
    required this.senderId,
    required this.senderName,
    this.createdAt,
  });

  final String text;
  final String senderId;
  final String senderName;
  final DateTime? createdAt;

  static LastMessage? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final ts = raw['createdAt'];
    return LastMessage(
      text: (raw['text'] ?? '') as String,
      senderId: (raw['senderId'] ?? '') as String,
      senderName: (raw['senderName'] ?? '') as String,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}

/// Личный чат из `chats/{chatId}`.
class DirectChat {
  const DirectChat({
    required this.id,
    required this.members,
    this.lastMessage,
  });

  final String id;
  final List<String> members;
  final LastMessage? lastMessage;

  String otherMember(String myUid) =>
      members.firstWhere((m) => m != myUid, orElse: () => myUid);

  factory DirectChat.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return DirectChat(
      id: doc.id,
      members: List<String>.from((data['members'] as List?) ?? const []),
      lastMessage: LastMessage.fromMap(data['lastMessage']),
    );
  }
}
