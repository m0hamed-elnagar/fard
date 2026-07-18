import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/utils/time_utils.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_state.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/core/theme/app_colors.dart';
import '../blocs/azkar_bloc.dart';
import 'azkar_list_screen.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/widgets/custom_toggle.dart';
import 'package:fard/core/mixins/notification_permission_mixin.dart';

class AzkarCategoriesScreen extends StatefulWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  State<AzkarCategoriesScreen> createState() => _AzkarCategoriesScreenState();
}

class _AzkarCategoriesScreenState extends State<AzkarCategoriesScreen> with NotificationPermissionMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AzkarBloc>();
    if (bloc.state.categories.isEmpty) {
      bloc.add(const AzkarEvent.loadCategories());
    }
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : null,
        title: _isSearching
            ? TextField(
                key: const Key('azkar_search_field'),
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: context.onSurfaceColor),
                ),
                style: TextStyle(color: context.onSurfaceColor, fontSize: 18),
              )
            : Text(
                l10n.azkar,
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        centerTitle: false,
        actions: [
          BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
            builder: (context, settingsState) {
              final hasActive = settingsState.reminders.isNotEmpty;
              return Badge(
                isLabelVisible: hasActive,
                backgroundColor: context.secondaryColor,
                smallSize: 10,
                alignment: const Alignment(0.5, -0.5),
                child: IconButton(
                  key: const Key('azkar_reminders_badge_button'),
                  icon: Icon(
                    hasActive
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    color: hasActive ? context.secondaryColor : null,
                  ),
                  tooltip: l10n.activeReminders,
                  onPressed: () => _showAllRemindersBottomSheet(context, settingsState),
                ),
              );
            },
          ),
          IconButton(
            key: const Key('azkar_search_button'),
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    l10n.resetAllProgress,
                    style: GoogleFonts.amiri(),
                  ),
                  content: Text(l10n.resetAzkarProgressConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(color: context.onSurfaceVariantColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.errorColor,
                        foregroundColor: context.onSurfaceColor,
                      ),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                context.read<AzkarBloc>().add(const AzkarEvent.resetAll());
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.resetAllProgress,
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
                  Text(l10n.loadingAzkar, style: GoogleFonts.amiri()),
                ],
              ),
            );
          }

          if (state.error != null && state.categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingAzkar,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.errorColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.onSurfaceVariantColor),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AzkarBloc>().add(
                        const AzkarEvent.loadCategories(),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredCategories = state.categories.where((cat) {
            return cat.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredCategories.isEmpty && !state.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? l10n.noCategoriesFound
                        : l10n.noSearchResults,
                    style: GoogleFonts.amiri(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  if (_searchQuery.isEmpty)
                    ElevatedButton.icon(
                      onPressed: () => context.read<AzkarBloc>().add(
                        const AzkarEvent.loadCategories(),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.refreshData),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AzkarBloc>().add(const AzkarEvent.loadCategories());
              await context
                  .read<AzkarBloc>()
                  .stream
                  .firstWhere((s) => !s.isLoading)
                  .timeout(const Duration(seconds: 15), onTimeout: () => state);
            },
            child: BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
              builder: (context, settingsState) {
                final now = DateTime.now();

                DateTime morningTime;
                DateTime eveningTime;

                morningTime = _parseTime(settingsState.morningAzkarTime, now);
                eveningTime = _parseTime(settingsState.eveningAzkarTime, now);

                return ListView(
                  key: const Key('azkar_categories_list'),
                  padding: const EdgeInsets.all(16),
                  children: filteredCategories.map((category) {
                    final isRecommended = _checkIsRecommended(
                      category,
                      now,
                      morningTime,
                      eveningTime,
                    );

                    return _CategoryCard(
                      key: Key('category_$category'),
                      category: category,
                      isRecommended: isRecommended,
                      allReminders: settingsState.reminders,
                    );
                  }).toList(),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAllRemindersBottomSheet(
    BuildContext context,
    DailyRemindersState settingsState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DailyRemindersCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: context.surfaceContainerColor,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          height: MediaQuery.of(context).size.height * 0.6,
          child: BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
            builder: (context, state) {
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.outlineColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active_rounded,
                        color: context.secondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.activeReminders,
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Expanded(
                    child: state.reminders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  size: 64,
                                  color: context.onSurfaceVariantColor.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.localeName == 'ar'
                                      ? 'لا توجد تذكيرات نشطة'
                                      : 'No active reminders',
                                  style: TextStyle(
                                    color: context.onSurfaceVariantColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: state.reminders.length,
                            itemBuilder: (context, index) {
                              final reminder = state.reminders[index];
                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      reminder.title.isNotEmpty ? reminder.title : reminder.category,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: reminder.isEnabled
                                            ? context.onSurfaceColor
                                            : context.onSurfaceVariantColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      TimeUtils.formatTo12Hour(reminder.time),
                                      style: TextStyle(
                                        color: context.secondaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomToggle(
                                          value: reminder.isEnabled,
                                          onChanged: (val) async {
                                            cubit.toggleReminder(index);
                                            if (val) {
                                              final granted = await checkAndRequestNotificationPermissions(
                                                context,
                                              );
                                              if (!granted) {
                                                if (context.mounted) {
                                                  cubit.toggleReminder(index);
                                                }
                                              }
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                            color: context.onSurfaceVariantColor,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _showAddReminderDialog(
                                              context,
                                              reminder.category,
                                              index: index,
                                              reminder: reminder,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: context.errorColor,
                                          ),
                                          onPressed: () {
                                            cubit.removeReminder(index);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(l10n.alarmRemoved),
                                                backgroundColor: context.errorColor,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (index < state.reminders.length - 1)
                                    const Divider(),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  DateTime _parseTime(String timeStr, DateTime now) {
    try {
      final parts = timeStr.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (_) {
      return now;
    }
  }

  bool _checkIsRecommended(
    String category,
    DateTime now,
    DateTime morningTime,
    DateTime eveningTime,
  ) {
    if (category.contains('الصباح') || category.contains('Morning')) {
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

void _showAddReminderDialog(
  BuildContext context,
  String category, {
  int? index,
  AzkarReminder? reminder,
}) {
  final cubit = context.read<DailyRemindersCubit>();
  final l10n = AppLocalizations.of(context)!;

  String selectedTime = reminder?.time ?? '05:00';
  String customTitle = reminder?.title ?? category;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              index == null ? l10n.addAlarm : l10n.editReminder,
              style: GoogleFonts.amiri(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(l10n.category),
                    subtitle: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.title,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  initialValue: customTitle,
                  onChanged: (val) => customTitle = val,
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.time),
                    trailing: InkWell(
                      onTap: () async {
                        final time = await _selectTime(context, selectedTime);
                        if (time != null) {
                          setDialogState(() => selectedTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.secondaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          TimeUtils.formatTo12Hour(selectedTime),
                          style: TextStyle(
                            color: context.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              if (index != null)
                TextButton(
                  onPressed: () {
                    cubit.removeReminder(index);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.alarmRemoved),
                        backgroundColor: context.errorColor,
                      ),
                    );
                  },
                  child: Text(
                    l10n.delete,
                    style: TextStyle(color: context.errorColor),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: context.onSurfaceVariantColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final newReminder = AzkarReminder(
                    category: category,
                    time: selectedTime,
                    title: customTitle,
                    isEnabled: reminder?.isEnabled ?? true,
                  );
                  if (index == null) {
                    cubit.addReminder(newReminder);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.alarmAdded),
                        backgroundColor: context.secondaryColor,
                      ),
                    );
                  } else {
                    cubit.updateReminder(index, newReminder);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.alarmUpdated),
                        backgroundColor: context.secondaryColor,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(l10n.yes),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<String?> _selectTime(BuildContext context, String currentTime) async {
  final parts = currentTime.split(':');
  final initialTime = TimeOfDay(
    hour: int.parse(parts[0]),
    minute: int.parse(parts[1]),
  );

  final selectedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  if (selectedTime != null) {
    final String hour = selectedTime.hour.toString().padLeft(2, '0');
    final String minute = selectedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  return null;
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final bool isRecommended;
  final List<AzkarReminder> allReminders;

  const _CategoryCard({
    super.key,
    required this.category,
    this.isRecommended = false,
    required this.allReminders,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoryReminders = allReminders
        .where((r) => r.category == category)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isRecommended ? context.secondaryColor : context.outlineColor,
          width: isRecommended ? 1.5 : 1.0,
        ),
      ),
      color: isRecommended
          ? context.secondaryColor.withValues(alpha: 0.05)
          : null,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: categoryReminders.isEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: context.onSurfaceVariantColor.withValues(alpha: 0.5),
                  ),
                  onPressed: () => _showAddReminderDialog(context, category),
                  tooltip: l10n.addAlarm,
                )
              : Builder(
                  builder: (context) {
                    final primaryReminder = categoryReminders.first;
                    final extraCount = categoryReminders.length - 1;
                    final timeStr = TimeUtils.formatTo12Hour(primaryReminder.time);
                    final displayStr = extraCount > 0 ? '$timeStr (+$extraCount)' : timeStr;
                    final globalIndex = allReminders.indexWhere((r) =>
                        r.category == primaryReminder.category &&
                        r.time == primaryReminder.time &&
                        r.title == primaryReminder.title);

                    return InkWell(
                      onTap: () {
                        _showAddReminderDialog(
                          context,
                          category,
                          index: globalIndex,
                          reminder: primaryReminder,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryReminder.isEnabled
                              ? context.secondaryColor.withValues(alpha: 0.12)
                              : context.surfaceContainerHighestColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryReminder.isEnabled
                                ? context.secondaryColor.withValues(alpha: 0.3)
                                : context.outlineColor.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              primaryReminder.isEnabled
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_off_rounded,
                              size: 14,
                              color: primaryReminder.isEnabled
                                  ? context.secondaryColor
                                  : context.onSurfaceVariantColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              displayStr,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryReminder.isEnabled
                                      ? context.secondaryColor
                                      : context.onSurfaceVariantColor,
                                ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecommended) ...[
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.secondaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: context.secondaryColor,
                    size: 14,
                  ),
                ),
              ],
              Text(
                category,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: isRecommended ? FontWeight.bold : FontWeight.w600,
                  color: isRecommended ? context.secondaryColor : null,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isRecommended ? context.secondaryColor : context.onSurfaceVariantColor.withValues(alpha: 0.5),
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
      ),
    );
  }
}
