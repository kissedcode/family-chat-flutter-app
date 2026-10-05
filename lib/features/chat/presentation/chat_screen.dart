import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/data/user_repository.dart';
import '../../profile/presentation/avatar.dart';
import '../data/chat_repository.dart';
import '../domain/message.dart';
import 'chat_controller.dart';

/// Экран `/`: общий семейный чат.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(() => setState(() {}));
    // При открытии чата — гарантируем, что документ users/{uid} создан.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userRepositoryProvider).ensureMyProfile().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messagesAsync = ref.watch(messagesStreamProvider);
    final sendState = ref.watch(chatControllerProvider);
    final me = FirebaseAuth.instance.currentUser?.uid;

    ref.listen(chatControllerProvider, (previous, next) {
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
        title: Text(l10n.chatTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          IconButton(
            tooltip: l10n.chatLogOut,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
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
    await ref.read(chatControllerProvider.notifier).sendMessage(text);
  }
}

/// Строка чата: аватар + bubble. Аватар слева для чужих сообщений,
/// справа для своих.
class _MessageRow extends ConsumerWidget {
  const _MessageRow({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

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
          Flexible(child: _MessageBubble(message: message, isMine: isMine)),
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
  const _MessageBubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

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
            if (!isMine)
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
