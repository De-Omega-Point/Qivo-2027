import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/state/qivo_providers.dart';
import 'core/theme/qivo_theme.dart';
import 'features/shell/qivo_app_shell.dart';

class QivoApp extends ConsumerWidget {
  const QivoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Qivo',
      debugShowCheckedModeBanner: false,
      theme: QivoTheme.light(settings: settings),
      darkTheme: QivoTheme.dark(settings: settings),
      themeMode: settings.resolvedThemeMode,
      home: const QivoAppShell(),
    );
  }
}
