import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'l10n/generated/app_localizations.dart';

class FassengerApp extends ConsumerWidget {
  const FassengerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Fassenger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, supported) {
        // Fallback на ru, если системная локаль не ru и не en.
        final supportedCodes = supported.map((l) => l.languageCode).toSet();
        if (locales != null) {
          for (final l in locales) {
            if (supportedCodes.contains(l.languageCode)) {
              return Locale(l.languageCode);
            }
          }
        }
        return const Locale('ru');
      },
    );
  }
}
