import 'dart:async';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_list_screen.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';

class AzkarDialogManager extends StatefulWidget {
  final Widget child;
  const AzkarDialogManager({super.key, required this.child});

  @override
  State<AzkarDialogManager> createState() => _AzkarDialogManagerState();
}

class _AzkarDialogManagerState extends State<AzkarDialogManager> {
  Timer? _azkarTimer;
  DateTime? _lastShownDate;

  @override
  void initState() {
    super.initState();
    // Check every minute
    _azkarTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAzkarTime();
    });
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAzkarTime();
    });
  }

  @override
  void dispose() {
    _azkarTimer?.cancel();
    super.dispose();
  }

  void _checkAzkarTime() {
    if (!mounted) return;

    final settings = context.read<SettingsCubit>().state;
    final azkarState = context.read<AzkarBloc>().state;
    if (azkarState.categories.isEmpty) return;

    final now = DateTime.now();
    
    // Prevent showing multiple times for the exact same minute
    if (_lastShownDate != null && 
        _lastShownDate!.year == now.year && 
        _lastShownDate!.month == now.month && 
        _lastShownDate!.day == now.day &&
        _lastShownDate!.hour == now.hour &&
        _lastShownDate!.minute == now.minute) {
      return;
    }

    for (final reminder in settings.reminders) {
      if (!reminder.isEnabled) continue;
      
      final reminderTime = _parseTime(reminder.time, now);
      if (now.hour == reminderTime.hour && now.minute == reminderTime.minute) {
        final category = azkarState.categories.firstWhere(
          (c) => c == reminder.category || c.contains(reminder.category),
          orElse: () => '',
        );
        if (category.isNotEmpty) {
           _lastShownDate = now;
           _showAzkarDialog(category, reminder.title.isNotEmpty ? reminder.title : category);
           break;
        }
      }
    }
  }

  DateTime _parseTime(String timeStr, DateTime now) {
    try {
      final parts = timeStr.split(':');
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return now;
    }
  }

  void _showAzkarDialog(String category, String title) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppTheme.accent),
            const SizedBox(width: 12),
            Text(l10n.timeFor, style: GoogleFonts.amiri(fontSize: 18)),
          ],
        ),
        content: Text(
          '${l10n.localeName == 'ar' ? 'حان وقت' : 'It is time for'} $title. ${l10n.localeName == 'ar' ? 'هل تريد قراءتها الآن؟' : 'Would you like to read it now?'}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AzkarListScreen(category: category),
                ),
              );
            },
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
