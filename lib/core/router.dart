import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/profile/presentation/settings_screen.dart';

part 'router.g.dart';

/// Роуты приложения. Просто перечислены — deep-links в v1 не используются.
class AppRoutes {
  const AppRoutes._();
  static const String auth = '/auth';
  static const String chat = '/';
  static const String settings = '/settings';
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.chat,
    debugLogDiagnostics: false,
    refreshListenable: _GoRouterProviderRefresh(ref),
    redirect: (context, state) {
      final asyncAuth = ref.read(authStateChangesProvider);
      // Пока стрим не отдал первое значение — не редиректим (splash сам ждёт).
      if (asyncAuth.isLoading) return null;
      final signedIn = asyncAuth.value != null;
      final atAuth = state.matchedLocation == AppRoutes.auth;

      if (!signedIn && !atAuth) return AppRoutes.auth;
      if (signedIn && atAuth) return AppRoutes.chat;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route error: ${state.error}')),
    ),
  );
}

/// Мостик между Riverpod-провайдером authStateChanges и GoRouter.refreshListenable.
class _GoRouterProviderRefresh extends ChangeNotifier {
  _GoRouterProviderRefresh(this._ref) {
    _subscription = _ref.listen(
      authStateChangesProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<User?>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
