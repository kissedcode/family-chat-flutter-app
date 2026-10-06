import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../profile/data/user_repository.dart';
import '../../profile/presentation/avatar.dart';
import '../data/chat_repository.dart';
import '../domain/direct_chat.dart';
import '../domain/message.dart';
import 'chat_controller.dart';

/// Экран `/chat/:chatId`: общий (`general`) или личный чат.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textCtrl = TextEditingController();
  late final ChatRepository _repo;
  Timer? _readTimer;
  DateTime _lastReadMark = DateTime.fromMillisecondsSinceEpoch(0);

  static const _readThrottle = Duration(seconds: 2);

  bool get _isGeneral => widget.chatId == kGeneralChatId;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(chatRepositoryProvider);
    _textCtrl.addListener(() => setState(() {}));
    _markReadNow();
  }

  @override
  void dispose() {
    _readTimer?.cancel();
    _markReadNow();
    _textCtrl.dispose();
    super.dispose();
  }

  void _markReadNow() {
    _lastReadMark = DateTime.now();
    _repo.markRead(widget.chatId).catchError((_) {});
  }

  /// Отметка прочтения не чаще раза в [_readThrottle] (trailing).
  void _scheduleMarkRead() {
    final since = DateTime.now().difference(_lastReadMark);
    if (since >= _readThrottle) {
      _markReadNow();
      return;
    }
    _readTimer?.cancel();
    _readTimer = Timer(_readThrottle - since, _markReadNow);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messagesAsync = ref.watch(messagesStreamProvider(widget.chatId));
    final sendState = ref.watch(chatControllerProvider(widget.chatId));
    final me = FirebaseAuth.instance.currentUser?.uid;

    ref.listen(messagesStreamProvider(widget.chatId), (previous, next) {
      if (next.hasValue) _scheduleMarkRead();
    });

    ref.listen(chatControllerProvider(widget.chatId), (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(l10n.chatSendError)),
          );
      }
    });

    final currentLen = _textCtrl.text.characters.length;
    final overLimit = currentLen > kMaxMessageLength;

    return Scaffold(
      appBar: AppBar(
        title: _isGeneral
            ? Text(l10n.chatGeneralTitle)
            : _DirectChatTitle(chatId: widget.chatId, myUid: me ?? ''),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(child: Text(l10n.chatEmpty));
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    return _MessageRow(
                      message: msg,
                      isMine: me != null && msg.senderId == me,
                      showSenderName: _isGeneral,
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(
                child: Text('Error: $err'),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _textCtrl,
                          minLines: 1,
                          maxLines: 6,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: l10n.chatMessageHint,
                            border: const OutlineInputBorder(),
                            isDense: true,
                            errorText: overLimit
                                ? l10n.chatLengthCounter(
                                    currentLen,
                                    kMaxMessageLength,
                                  )
                                : null,
                          ),
                        ),
                        if (currentLen > kMaxMessageLength * 0.8 && !overLimit)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              l10n.chatLengthCounter(
                                currentLen,
                                kMaxMessageLength,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: (sendState.isLoading ||
                            _textCtrl.text.trim().isEmpty ||
                            overLimit)
                        ? null
                        : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _textCtrl.text;
    _textCtrl.clear();
    await ref
        .read(chatControllerProvider(widget.chatId).notifier)
        .sendMessage(text);
  }
}

/// Заголовок личного чата: аватар и имя собеседника.
class _DirectChatTitle extends ConsumerWidget {
  const _DirectChatTitle({required this.chatId, required this.myUid});

  final String chatId;
  final String myUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUid = otherMemberOf(chatId, myUid);
    if (otherUid == null) return const SizedBox.shrink();
    final other = ref.watch(userProfileProvider(otherUid)).value;
    final name = other?.displayName ?? '…';
    return Row(
      children: [
        UserAvatar(avatarUrl: other?.avatarUrl, name: name, radius: 16),
        const SizedBox(width: 10),
        Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

/// Строка чата: аватар + bubble. Аватар слева для чужих сообщений,
/// справа для своих.
class _MessageRow extends ConsumerWidget {
  const _MessageRow({
    required this.message,
    required this.isMine,
    required this.showSenderName,
  });

  final Message message;
  final bool isMine;
  final bool showSenderName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Аватар: сначала пробуем снапшот из сообщения, иначе — тянем из users.
    Widget avatar;
    if (message.senderAvatarUrl != null && message.senderAvatarUrl!.isNotEmpty) {
      avatar = UserAvatar(
        avatarUrl: message.senderAvatarUrl,
        name: message.senderName,
        radius: 16,
      );
    } else {
      final fetched = ref.watch(userProfileProvider(message.senderId));
      final fetchedUrl = fetched.asData?.value?.avatarUrl;
      avatar = UserAvatar(
        avatarUrl: fetchedUrl,
        name: message.senderName,
        radius: 16,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            avatar,
            const SizedBox(width: 6),
          ],
          Flexible(
            child: _MessageBubble(
              message: message,
              isMine: isMine,
              showSenderName: showSenderName,
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 6),
            avatar,
          ],
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.showSenderName,
  });

  final Message message;
  final bool isMine;
  final bool showSenderName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bg = isMine
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: Radius.circular(isMine ? 14 : 2),
      bottomRight: Radius.circular(isMine ? 2 : 14),
    );

    final time = message.createdAt;
    final timeLabel = time == null
        ? l10n.chatMessageSending
        : DateFormat.Hm().format(time);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine && showSenderName)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.senderName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            Text(message.text),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                timeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
