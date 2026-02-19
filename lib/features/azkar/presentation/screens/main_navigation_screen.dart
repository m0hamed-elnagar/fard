import 'package:fard/core/di/injection.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_categories_screen.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/home_screen.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/qibla_screen.dart';
import 'package:fard/features/quran/presentation/pages/quran_page.dart';
import 'package:fard/features/quran_library_wrapper/presentation/pages/quran_library_page.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool showAddQadaOnStart;
  const MainNavigationScreen({super.key, this.showAddQadaOnStart = false});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late final List<Widget> _screens;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(showAddQadaOnStart: widget.showAddQadaOnStart),
      const QuranPage(),
      const QuranLibraryPage(),
      const AzkarCategoriesScreen(),
      const QiblaScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = getIt<PrayerTrackerBloc>();
            bloc.add(const PrayerTrackerEvent.checkMissedDays());
            bloc.add(PrayerTrackerEvent.load(DateTime.now()));
            return bloc;
          },
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
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
              icon: const Icon(Icons.library_books_outlined),
              selectedIcon: const Icon(Icons.library_books_rounded),
              label: 'المصحف',
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_stories_outlined),
              selectedIcon: const Icon(Icons.auto_stories_rounded),
              label: l10n.azkarTab,
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
