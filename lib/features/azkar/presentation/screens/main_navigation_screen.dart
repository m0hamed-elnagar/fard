import 'package:fard/core/di/injection.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_categories_screen.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/home_screen.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AzkarCategoriesScreen(),
    const SettingsScreen(),
  ];

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
              label: l10n.azkarTab,
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

// Extension for localized tabs
extension TabL10n on AppLocalizations {
  String get prayerTab => localeName == 'ar' ? 'الصلاة' : 'Prayer';
  String get azkarTab => localeName == 'ar' ? 'الأذكار' : 'Azkar';
}
