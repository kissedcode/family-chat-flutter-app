import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/data/user_repository.dart';
import '../../profile/presentation/avatar.dart';
import '../data/chat_repository.dart';
import '../domain/direct_chat.dart';
import 'chat_tile.dart';

/// Экран `/`: список чатов. Общий чат закреплён первым, ниже — личные.
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // При входе — гарантируем, что документ users/{uid} создан.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userRepositoryProvider).ensureMyProfile().catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final directAsync = ref.watch(directChatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatListTitle),
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
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.chatListNewChat,
        onPressed: () => context.push(AppRoutes.newChat),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          const _GeneralChatTile(),
          const Divider(height: 1),
          ...directAsync.when(
            data: (chats) => chats.map((c) => _DirectChatTile(chat: c)),
            loading: () => const [
              Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (err, st) => [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GeneralChatTile extends ConsumerWidget {
  const _GeneralChatTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final me = ref.watch(currentUidProvider);
    final last = ref.watch(generalLastMessageProvider).value;
    final unread = ref.watch(unreadCountProvider(kGeneralChatId)).value ?? 0;

    String preview;
    if (last == null) {
      preview = l10n.chatListNoMessages;
    } else if (last.senderId == me) {
      preview = '${l10n.chatListYouPrefix}${last.text}';
    } else {
      preview = '${last.senderName}: ${last.text}';
    }

    return ChatTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.groups),
      ),
      title: l10n.chatGeneralTitle,
      preview: preview.replaceAll('\n', ' '),
      time: last?.createdAt,
      unread: unread,
      onTap: () => context.push(AppRoutes.chatPath(kGeneralChatId)),
    );
  }
}

class _DirectChatTile extends ConsumerWidget {
  const _DirectChatTile({required this.chat});

  final DirectChat chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(currentUidProvider) ?? '';
    final otherUid = chat.otherMember(me);
    final other = ref.watch(userProfileProvider(otherUid)).value;
    final unread = ref.watch(unreadCountProvider(chat.id)).value ?? 0;
    final last = chat.lastMessage;

    final name = other?.displayName ??
        (last != null && last.senderId == otherUid ? last.senderName : '…');

    String preview;
    if (last == null) {
      preview = l10n.chatListNoMessages;
    } else if (last.senderId == me) {
      preview = '${l10n.chatListYouPrefix}${last.text}';
    } else {
      preview = last.text;
    }

    return ChatTile(
      leading: UserAvatar(avatarUrl: other?.avatarUrl, name: name, radius: 20),
      title: name,
      preview: preview.replaceAll('\n', ' '),
      time: last?.createdAt,
      unread: unread,
      onTap: () => context.push(AppRoutes.chatPath(chat.id)),
    );
  }
}
