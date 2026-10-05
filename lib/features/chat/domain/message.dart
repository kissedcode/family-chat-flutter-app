import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

/// Одно сообщение в общем семейном чате.
///
/// `createdAt` может быть null, пока запись ещё не подтверждена сервером
/// (Firestore возвращает документ раньше, чем `serverTimestamp()` резолвится).
///
/// `senderAvatarUrl` — снапшот аватара на момент отправки (может быть null).
@freezed
sealed class Message with _$Message {
  const factory Message({
    required String id,
    required String text,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
    DateTime? createdAt,
    @Default(false) bool hasPendingWrites,
  }) = _Message;

  const Message._();

  factory Message.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final ts = data['createdAt'];
    // Совместимость со старыми сообщениями, где было поле senderPhotoUrl.
    final avatar = (data['senderAvatarUrl'] as String?) ??
        (data['senderPhotoUrl'] as String?);
    return Message(
      id: doc.id,
      text: (data['text'] ?? '') as String,
      senderId: (data['senderId'] ?? '') as String,
      senderName: (data['senderName'] ?? '') as String,
      senderAvatarUrl: avatar,
      createdAt: ts is Timestamp ? ts.toDate() : null,
      hasPendingWrites: doc.metadata.hasPendingWrites,
    );
  }

  /// Данные для записи в Firestore. Время ставит сервер.
  static Map<String, dynamic> toCreateData({
    required String text,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
  }) {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
