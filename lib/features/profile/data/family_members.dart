import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../chat/data/chat_repository.dart';
import '../domain/user_profile.dart';

part 'family_members.g.dart';

/// Все члены семьи с профилем в `users`, кроме текущего пользователя,
/// отсортированные по имени.
@riverpod
Stream<List<UserProfile>> familyMembers(Ref ref) {
  final me = ref.watch(currentUidProvider);
  if (me == null) return Stream.value(const []);
  return FirebaseFirestore.instance.collection('users').snapshots().map((snap) {
    final list = snap.docs
        .where((d) => d.id != me)
        .map(UserProfile.fromDoc)
        .where((p) => p.displayName.trim().isNotEmpty)
        .toList()
      ..sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );
    return list;
  });
}
