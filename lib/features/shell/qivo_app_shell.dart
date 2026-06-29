import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../../core/utils/responsive.dart';
import '../admin/admin_screen.dart';
import '../analytics/analytics_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../live_assist/live_assist_screen.dart';
import '../prep/prep_screen.dart';
import '../review/review_screen.dart';
import '../settings/settings_screen.dart';
import 'qivo_bottom_nav.dart';
import 'qivo_sidebar.dart';
import 'qivo_top_bar.dart';

class QivoAppShell extends ConsumerWidget {
  const QivoAppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);
    final selected = ref.watch(selectedNavProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [QivoColours.background, Color(0xFF0A1425)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (!isMobile) const QivoSidebar(),
              Expanded(
                child: Column(
                  children: [
                    const QivoTopBar(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: Responsive.maxContentWidth(context),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 16 : 24),
                            child: _screenFor(selected),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isMobile ? const QivoBottomNav() : null,
    );
  }

  Widget _screenFor(QivoNavItem item) {
    return switch (item) {
      QivoNavItem.home => const HomeScreen(),
      QivoNavItem.liveAssist => const LiveAssistScreen(),
      QivoNavItem.prep => const PrepScreen(),
      QivoNavItem.review => const ReviewScreen(),
      QivoNavItem.history => const HistoryScreen(),
      QivoNavItem.analytics => const AnalyticsScreen(),
      QivoNavItem.settings => const SettingsScreen(),
      QivoNavItem.admin => const AdminScreen(),
    };
  }
}
