import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_list_screen.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

class SuggestedAzkarSection extends StatelessWidget {
  final SettingsState settings;

  const SuggestedAzkarSection({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarBloc, AzkarState>(
      builder: (context, azkarState) {
        if (azkarState.categories.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        final now = DateTime.now();
        AzkarReminder? activeReminder;
        
        // Find the first enabled reminder that is within the suggested window
        for (final reminder in settings.reminders) {
          if (!reminder.isEnabled) continue;
          final reminderTime = _parseTime(reminder.time, now);
          
          // Show if within 30 mins before or 4 hours after
          if (now.isAfter(reminderTime.subtract(const Duration(minutes: 30))) && 
              now.isBefore(reminderTime.add(const Duration(hours: 4)))) {
            activeReminder = reminder;
            break;
          }
        }

        if (activeReminder == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
        
        final reminder = activeReminder;

        final categoryToOpen = azkarState.categories.firstWhere(
          (c) => c == reminder.category || c.contains(reminder.category),
          orElse: () => '',
        );

        if (categoryToOpen.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        final l10n = AppLocalizations.of(context)!;
        final displayTitle = reminder.title.isNotEmpty ? reminder.title : categoryToOpen;
        
        final isEvening = displayTitle.contains('المساء') || 
                          displayTitle.contains('Evening') || 
                          (now.hour >= 16 || now.hour < 3);
        
        final isMorning = displayTitle.contains('الصباح') || 
                          displayTitle.contains('Morning');

        // Prioritize title for icon/color selection
        final effectiveIsEvening = isEvening && !isMorning;

        IconData icon = Icons.wb_sunny_rounded;
        List<Color> gradientColors = [
          const Color(0xFFFFD54F), // Amber
          const Color(0xFFF9A825), // Orange/Gold
        ];
        Color mainColor = const Color(0xFFF9A825);
        
        if (effectiveIsEvening) {
          icon = Icons.nightlight_round;
          gradientColors = [
            const Color(0xFF7986CB), // Indigo Light
            const Color(0xFF303F9F), // Indigo Dark
          ];
          mainColor = const Color(0xFF7986CB);
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AzkarListScreen(category: categoryToOpen),
                  ),
                );
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: mainColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: mainColor.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative background element
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        icon,
                        size: 100,
                        color: mainColor.withValues(alpha: 0.05),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColors.first.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.timeFor.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    color: mainColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayTitle,
                                  style: GoogleFonts.amiri(
                                    color: AppTheme.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: mainColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: mainColor,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
}
