import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_categories_screen.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/home_screen.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/qibla_screen.dart';
import 'package:fard/features/quran/presentation/pages/quran_page.dart';
import 'package:fard/features/tasbih/presentation/pages/tasbih_page.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool showAddQadaOnStart;
  const MainNavigationScreen({super.key, this.showAddQadaOnStart = false});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  List<Widget>? _screens;
  int _selectedIndex = 0;
  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
    // Initial widget update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<WidgetUpdateService>().updateWidget();
    });
  }

  void _initScreens() {
    _screens = [
      HomeScreen(showAddQadaOnStart: widget.showAddQadaOnStart),
      const QuranPage(),
      const AzkarCategoriesScreen(),
      const TasbihPage(),
      const QiblaScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    // Re-initialize screens if locale changed to ensure they pick up new translations
    if (_screens == null || _lastLocale != currentLocale) {
      _initScreens();
      _lastLocale = currentLocale;
    }

    return BlocListener<PrayerTrackerBloc, PrayerTrackerState>(
      listenWhen: (previous, current) =>
          current.maybeMap(loaded: (_) => true, orElse: () => false),
      listener: (context, state) {
        getIt<WidgetUpdateService>().updateWidget();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _screens!),
            ),
            const AudioPlayerBar(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.mosque_outlined),
              selectedIcon: const Icon(Icons.mosque_rounded),
              label: l10n.prayerTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book_rounded),
              label: l10n.quranTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_stories_outlined),
              selectedIcon: const Icon(Icons.auto_stories_rounded),
              label: l10n.azkarTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.touch_app_outlined),
              selectedIcon: const Icon(Icons.touch_app_rounded),
              label: l10n.tasbihTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore_rounded),
              label: l10n.qibla,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
