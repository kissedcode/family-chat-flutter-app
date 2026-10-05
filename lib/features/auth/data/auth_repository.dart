import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Web client ID (OAuth 2.0, тип "Web application") из Google Cloud Console.
/// Нужен google_sign_in 7.x для macOS/iOS/Android — резолвит идентификатор
/// клиента, под которым выдан idToken для Firebase.
const String _webClientId =
    '847260960210-uajtht6usumegae19qhceij7glun9hhi.apps.googleusercontent.com';

/// Обёртка над FirebaseAuth: Google + Email/Password.
///
/// В google_sign_in 7.x API двухшаговый: сначала `initialize()`, затем
/// `authenticate()`. Инициализация делается один раз; повторные вызовы —
/// no-op на уровне SDK, но мы дополнительно защищаемся флагом.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  bool _googleReady = false;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> _ensureGoogleInit() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
    _googleReady = true;
  }

  /// Вход через Google. Работает на Android/macOS; для web в v1 не
  /// поддерживается (`supportsAuthenticate() == false`).
  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleInit();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'На этой платформе Google Sign-In через authenticate() '
        'не поддерживается.',
      );
    }

    final GoogleSignInAccount account =
        await GoogleSignIn.instance.authenticate();
    final GoogleSignInAuthentication auth = account.authentication;

    final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final name = displayName.trim();
    if (name.isNotEmpty) {
      await cred.user?.updateDisplayName(name);
      await cred.user?.reload();
    }
    return cred;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Если Google не инициализирован — игнорируем.
    }
    await _auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository();

@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}
