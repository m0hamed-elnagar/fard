import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/core/theme/app_theme.dart';
import '../blocs/azkar_bloc.dart';
import 'azkar_list_screen.dart';
import 'package:fard/core/l10n/app_localizations.dart';

class AzkarCategoriesScreen extends StatefulWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  State<AzkarCategoriesScreen> createState() => _AzkarCategoriesScreenState();
}

class _AzkarCategoriesScreenState extends State<AzkarCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AzkarBloc>().add(const AzkarEvent.loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الأذكار',
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AzkarBloc>().add(const AzkarEvent.resetAll());
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset All Progress',
          ),
        ],
      ),
      body: BlocBuilder<AzkarBloc, AzkarState>(
        builder: (context, state) {
          if (state.isLoading && state.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Loading Azkar...', style: GoogleFonts.amiri()),
                ],
              ),
            );
          }

          if (state.error != null && state.categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Azkar',
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<AzkarBloc>()
                          .add(const AzkarEvent.loadCategories()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.categories.isEmpty && !state.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No categories found',
                    style: GoogleFonts.amiri(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<AzkarBloc>()
                        .add(const AzkarEvent.loadCategories()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Data'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AzkarBloc>().add(const AzkarEvent.loadCategories());
              // Wait for state to not be loading or a timeout
              await context.read<AzkarBloc>().stream.firstWhere((s) => !s.isLoading).timeout(const Duration(seconds: 15), onTimeout: () => state);
            },
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                final now = DateTime.now();
                final morningTime = _parseTime(settingsState.morningAzkarTime, now);
                final eveningTime = _parseTime(settingsState.eveningAzkarTime, now);

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final isRecommended = _checkIsRecommended(category, now, morningTime, eveningTime);

                    return _CategoryCard(
                      category: category,
                      isRecommended: isRecommended,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  DateTime _parseTime(String timeStr, DateTime now) {
    try {
      final parts = timeStr.split(':');
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return now;
    }
  }

  bool _checkIsRecommended(String category, DateTime now, DateTime morningTime, DateTime eveningTime) {
    if (category.contains('الصباح') || category.contains('Morning')) {
      // Show within 4 hours of set time
      return now.isAfter(morningTime.subtract(const Duration(minutes: 30))) && 
             now.isBefore(morningTime.add(const Duration(hours: 4)));
    }
    if (category.contains('المساء') || category.contains('Evening')) {
      return now.isAfter(eveningTime.subtract(const Duration(minutes: 30))) && 
             now.isBefore(eveningTime.add(const Duration(hours: 4)));
    }
    return false;
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final bool isRecommended;

  const _CategoryCard({
    required this.category,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRecommended ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended 
          ? const BorderSide(color: AppTheme.accent, width: 2)
          : BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      color: isRecommended ? AppTheme.accent.withValues(alpha: 0.05) : null,
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              category,
              style: GoogleFonts.amiri(
                fontSize: 18, 
                fontWeight: isRecommended ? FontWeight.bold : FontWeight.w600,
                color: isRecommended ? AppTheme.accent : null,
              ),
              textAlign: TextAlign.right,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16,
              color: isRecommended ? AppTheme.accent : null,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AzkarListScreen(category: category),
                ),
              );
            },
          ),
          if (isRecommended)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('★', style: TextStyle(color: Colors.white, fontSize: 10)),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.recommended,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
