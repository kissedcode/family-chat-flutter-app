import 'package:flutter/material.dart';

/// Круглый аватар пользователя. Если [url] пустой — рисует круг с первой
/// буквой имени. Не делает никаких сетевых запросов сам по себе, кроме
/// [Image.network].
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.radius = 18,
  });

  final String? avatarUrl;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = _initial(name);
    final bg = theme.colorScheme.primaryContainer;
    final fg = theme.colorScheme.onPrimaryContainer;

    final url = avatarUrl;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: Text(
          initial,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: radius * 0.9,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      foregroundImage: NetworkImage(url),
      child: Text(
        initial,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }

  static String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final char = trimmed.characters.first;
    return char.toUpperCase();
  }
}
