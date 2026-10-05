import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

/// Профиль пользователя из `users/{uid}`.
@freezed
sealed class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String displayName,
    String? avatarUrl,
    required String email,
    DateTime? updatedAt,
  }) = _UserProfile;

  const UserProfile._();

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final ts = data['updatedAt'];
    return UserProfile(
      uid: doc.id,
      displayName: (data['displayName'] ?? '') as String,
      avatarUrl: data['avatarUrl'] as String?,
      email: (data['email'] ?? '') as String,
      updatedAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
