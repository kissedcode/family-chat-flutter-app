import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Строка чата в списке: аватар, название, превью, время, счётчик.
class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.leading,
    required this.title,
    required this.preview,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String preview;
  final DateTime? time;
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasUnread = unread > 0;

    return ListTile(
      onTap: onTap,
      leading: leading,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: hasUnread ? const TextStyle(fontWeight: FontWeight.w600) : null,
      ),
      subtitle: Text(
        preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (time != null)
            Text(
              formatChatTime(time!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: hasUnread
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 4),
          if (hasUnread)
            Container(
              constraints: const BoxConstraints(minWidth: 22),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                unread > 99 ? l10n.unreadOverflow : '$unread',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox(height: 18),
        ],
      ),
    );
  }
}

/// Сегодня — `HH:mm`, иначе — `dd.MM`.
String formatChatTime(DateTime time) {
  final now = DateTime.now();
  final sameDay =
      now.year == time.year && now.month == time.month && now.day == time.day;
  return sameDay ? DateFormat.Hm().format(time) : DateFormat('dd.MM').format(time);
}
