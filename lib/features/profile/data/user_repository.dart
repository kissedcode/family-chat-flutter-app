import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/user_profile.dart';

part 'user_repository.g.dart';

/// Максимальный размер аватара в Storage (5 МБ — совпадает со Storage rule).
const int kMaxAvatarBytes = 5 * 1024 * 1024;

/// Размер стороны при сжатии (квадрат).
const int kAvatarSize = 512;

/// JPEG quality после сжатия.
const int kAvatarJpegQuality = 85;

/// Максимальная длина displayName (совпадает с Firestore rule).
const int kMaxDisplayNameLen = 64;

/// Доступ к `users/{uid}` в Firestore и `avatars/{uid}/...` в Storage.
class UserRepository {
  UserRepository({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Stream<UserProfile?> watchMyProfile() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _users
        .doc(user.uid)
        .snapshots(includeMetadataChanges: true)
        .map((doc) => doc.exists ? UserProfile.fromDoc(doc) : null);
  }

  Future<UserProfile?> fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? UserProfile.fromDoc(doc) : null;
  }

  /// Создать документ users/{uid}, если его ещё нет. Идемпотентно.
  /// Ставит displayName из Firebase Auth (или email до `@`).
  Future<void> ensureMyProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Нет авторизованного пользователя');
    }
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;
    final baseName = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? 'user');
    final email = user.email;
    if (email == null) {
      throw StateError('Нет email у пользователя');
    }
    await ref.set({
      'displayName': _clampName(baseName),
      'avatarUrl': user.photoURL,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Обновить имя. Пишет и в Firestore (users/{uid}), и в Firebase Auth.
  Future<void> updateDisplayName(String rawName) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Нет авторизованного пользователя');
    }
    final email = user.email;
    if (email == null) {
      throw StateError('Нет email у пользователя');
    }
    final name = _clampName(rawName);
    if (name.isEmpty) {
      throw ArgumentError('Пустое имя');
    }
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    final currentAvatar = snap.exists ? (snap.data()?['avatarUrl'] as String?) : null;
    // Явно перечисляем все поля, чтобы Firestore rule прошёл валидацию.
    await ref.set({
      'displayName': name,
      'avatarUrl': currentAvatar,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await user.updateDisplayName(name);
  }

  /// Загрузить и сохранить новый аватар из сырых байт (например, из image_picker).
  /// Возвращает публичный download URL.
  Future<String> uploadAvatar(Uint8List sourceBytes) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Нет авторизованного пользователя');
    }
    final email = user.email;
    if (email == null) {
      throw StateError('Нет email у пользователя');
    }

    // 1) Декодируем + ресайзим + жмём JPEG.
    final decoded = img.decodeImage(sourceBytes);
    if (decoded == null) {
      throw ArgumentError('Не удалось прочитать изображение');
    }
    final resized = img.copyResizeCropSquare(decoded, size: kAvatarSize);
    final jpg = Uint8List.fromList(
      img.encodeJpg(resized, quality: kAvatarJpegQuality),
    );
    if (jpg.length >= kMaxAvatarBytes) {
      throw ArgumentError('Аватар слишком большой даже после сжатия');
    }

    // 2) Заливаем в Storage. Каждый раз новое имя — сбить CDN-кэш.
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = 'avatars/${user.uid}/avatar_$ts.jpg';
    final ref = _storage.ref().child(path);
    await ref.putData(
      jpg,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();

    // 3) Читаем старый avatarUrl из profile, чтобы удалить best-effort.
    final userDocRef = _users.doc(user.uid);
    final snap = await userDocRef.get();
    final oldUrl = snap.exists ? (snap.data()?['avatarUrl'] as String?) : null;

    // 4) Пишем новый URL в users/{uid}.
    final currentName = snap.exists
        ? (snap.data()?['displayName'] as String? ?? '')
        : '';
    await userDocRef.set({
      'displayName':
          currentName.isEmpty ? _clampName(email.split('@').first) : currentName,
      'avatarUrl': url,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await user.updatePhotoURL(url);

    // 5) Best-effort удаление старого файла.
    if (oldUrl != null && oldUrl != url) {
      try {
        await _storage.refFromURL(oldUrl).delete();
      } catch (_) {
        // Игнорим — не критично.
      }
    }

    return url;
  }

  /// Убрать аватар: пишет avatarUrl=null в users/{uid} и best-effort удаляет
  /// файл из Storage.
  Future<void> deleteAvatar() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Нет авторизованного пользователя');
    }
    final email = user.email;
    if (email == null) {
      throw StateError('Нет email у пользователя');
    }
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) return;
    final oldUrl = snap.data()?['avatarUrl'] as String?;
    final currentName = snap.data()?['displayName'] as String? ?? '';
    await ref.set({
      'displayName':
          currentName.isEmpty ? _clampName(email.split('@').first) : currentName,
      'avatarUrl': null,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await user.updatePhotoURL(null);
    if (oldUrl != null) {
      try {
        await _storage.refFromURL(oldUrl).delete();
      } catch (_) {}
    }
  }

  String _clampName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length <= kMaxDisplayNameLen) return trimmed;
    return trimmed.substring(0, kMaxDisplayNameLen);
  }
}

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) => UserRepository();

/// Текущий профиль пользователя (real-time из Firestore).
@Riverpod(keepAlive: true)
Stream<UserProfile?> myProfile(Ref ref) {
  return ref.watch(userRepositoryProvider).watchMyProfile();
}

/// Профиль произвольного пользователя (кэшируется, для fallback в чате).
@riverpod
Future<UserProfile?> userProfile(Ref ref, String uid) {
  return ref.watch(userRepositoryProvider).fetchProfile(uid);
}
