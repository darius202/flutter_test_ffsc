import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/settings/settings_controller.dart';

class RecipesApp extends HookConsumerWidget {
  const RecipesApp({super.key, this.initialLocation = '/recipes'});

  final String initialLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Created once for the lifetime of the app, disposed with it.
    final router = useMemoized(() => createRouter(initialLocation: initialLocation));
    useEffect(() => router.dispose, [router]);

    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

