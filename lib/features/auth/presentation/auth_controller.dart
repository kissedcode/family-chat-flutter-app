import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/logger.dart';
import '../data/auth_repository.dart';

part 'auth_controller.g.dart';

/// Контроллер экрана входа/регистрации. Держит loading/error поверх
/// AuthRepository. UI подписывается на state и запускает методы.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.signInWithEmail(email, password);
    });
    _logIfError('signInWithEmail');
  }

  Future<void> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.registerWithEmail(email, password, displayName);
    });
    _logIfError('registerWithEmail');
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.signInWithGoogle();
    });
    _logIfError('signInWithGoogle');
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.sendPasswordReset(email);
    });
    _logIfError('sendPasswordReset');
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.signOut);
    _logIfError('signOut');
  }

  void _logIfError(String op) {
    final error = state.error;
    if (error != null) {
      appLogger.w('$op failed', error: error);
    }
  }
}
