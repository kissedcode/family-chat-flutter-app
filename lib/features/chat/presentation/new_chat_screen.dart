import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../profile/data/family_members.dart';
import '../../profile/presentation/avatar.dart';
import '../data/chat_repository.dart';
import '../domain/direct_chat.dart';

/// Экран `/new-chat`: выбор собеседника для личного чата.
class NewChatScreen extends ConsumerWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(currentUidProvider);
    final membersAsync = ref.watch(familyMembersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newChatTitle)),
      body: membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.newChatEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, i) {
              final p = members[i];
              return ListTile(
                leading: UserAvatar(
                  avatarUrl: p.avatarUrl,
                  name: p.displayName,
                  radius: 20,
                ),
                title: Text(p.displayName),
                onTap: me == null
                    ? null
                    : () => context.pushReplacement(
                          AppRoutes.chatPath(directChatId(me, p.uid)),
                        ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
