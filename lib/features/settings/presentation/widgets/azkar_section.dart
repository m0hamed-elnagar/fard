import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/mixins/notification_permission_mixin.dart';
import '../../domain/azkar_reminder.dart';
import '../blocs/daily_reminders_cubit.dart';
import '../blocs/daily_reminders_state.dart';
import '../../../azkar/presentation/blocs/azkar_bloc.dart';

class AzkarSection extends StatefulWidget {
  final bool initiallyExpanded;
  const AzkarSection({super.key, this.initiallyExpanded = false});

  @override
  State<AzkarSection> createState() => _AzkarSectionState();
}

class _AzkarSectionState extends State<AzkarSection>
    with NotificationPermissionMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
      builder: (context, state) {
        return _buildExpandableSection(
          context,
          title: l10n.azkarSection,
          icon: Icons.auto_stories_rounded,
          accentColor: Colors.deepPurpleAccent,
          isExpanded: _isExpanded,
          onToggle: () => setState(() => _isExpanded = !_isExpanded),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.azkarSettingsDesc,
                    style: TextStyle(
                        color: context.onSurfaceVariantColor, fontSize: 13),
                  ),
                ),
                TextButton.icon(
                  key: const Key('add_reminder_button'),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showAddReminderDialog(context);
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(l10n.add),
                  style: TextButton.styleFrom(
                      foregroundColor: context.secondaryColor),
                ),
              ],
            ),
            const Divider(height: 12),
            if (state.reminders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color:
                            context.onSurfaceVariantColor.withValues(alpha: 0.3),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.noRemindersSet,
                          style: TextStyle(
                              color: context.onSurfaceVariantColor)),
                    ],
                  ),
                ),
              )
            else
              ...state.reminders.asMap().entries.map((entry) {
                final index = entry.key;
                final reminder = entry.value;
                return Column(
                  children: [
                    _buildReminderItem(
                      context: context,
                      index: index,
                      reminder: reminder,
                    ),
                    if (index < state.reminders.length - 1)
                      const Divider(height: 1),
                  ],
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
    Color? accentColor,
  }) {
    final effectiveAccentColor = accentColor ?? context.primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.outlineColor.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: effectiveAccentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: effectiveAccentColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.amiri(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: context.onSurfaceColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ],
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem({
    required BuildContext context,
    required int index,
    required AzkarReminder reminder,
  }) {
    final cubit = context.read<DailyRemindersCubit>();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        reminder.title.isNotEmpty ? reminder.title : reminder.category,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: reminder.isEnabled
              ? context.onSurfaceColor
              : context.onSurfaceVariantColor,
        ),
      ),
      subtitle: Text(
        reminder.time,
        style: TextStyle(
            color: context.secondaryColor, fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomToggle(
            value: reminder.isEnabled,
            onChanged: (val) async {
              if (val) {
                final granted =
                    await checkAndRequestNotificationPermissions(context);
                if (!granted) return;
              }
              cubit.toggleReminder(index);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 20, color: context.onSurfaceVariantColor),
            onPressed: () =>
                _showAddReminderDialog(context, index: index, reminder: reminder),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 20, color: context.errorColor),
            onPressed: () => cubit.removeReminder(index),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context,
      {int? index, AzkarReminder? reminder}) {
    final cubit = context.read<DailyRemindersCubit>();
    final azkarBloc = context.read<AzkarBloc>();
    final l10n = AppLocalizations.of(context)!;

    String selectedCategory = reminder?.category ?? '';
    String selectedTime = reminder?.time ?? '05:00';
    String customTitle = reminder?.title ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => BlocBuilder<AzkarBloc, AzkarState>(
          bloc: azkarBloc,
          builder: (context, azkarState) {
            if (selectedCategory.isEmpty && azkarState.categories.isNotEmpty) {
              selectedCategory = azkarState.categories.first;
            }
            return AlertDialog(
              title: Text(index == null ? l10n.addReminder : l10n.editReminder,
                  style: GoogleFonts.amiri(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _showSearchableCategoryPicker(
                          context,
                          azkarState.categories,
                          (val) => setDialogState(() => selectedCategory = val)),
                      child: InputDecorator(
                        decoration: InputDecoration(
                            labelText: l10n.category,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            suffixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: context.surfaceContainerHighestColor),
                        child: Text(selectedCategory.isEmpty
                            ? l10n.selectCategory
                            : selectedCategory),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: l10n.customTitleOptional,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: context.surfaceContainerHighestColor),
                      initialValue: customTitle,
                      onChanged: (val) => customTitle = val,
                    ),
                    const SizedBox(height: 16),
                    _buildTimePickerItem(context, l10n.time, selectedTime,
                        (time) => setDialogState(() => selectedTime = time)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel)),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategory.isEmpty) {
                      return;
                    }
                    final newReminder = AzkarReminder(
                      category: selectedCategory,
                      time: selectedTime,
                      title:
                          customTitle.isNotEmpty ? customTitle : selectedCategory,
                      isEnabled: reminder?.isEnabled ?? true,
                    );
                    if (index == null) {
                      cubit.addReminder(newReminder);
                    } else {
                      cubit.updateReminder(index, newReminder);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(l10n.yes),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSearchableCategoryPicker(
      BuildContext context, List<String> categories, Function(String) onSelected) {
    final l10n = AppLocalizations.of(context)!;
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final filtered = categories
              .where(
                  (cat) => query.isEmpty || cat.toLowerCase().contains(query))
              .toList();
          return Container(
            padding: EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                      hintText: l10n.searchCategory,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16))),
                  onChanged: (val) =>
                      setSheetState(() => query = val.toLowerCase()),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => ListTile(
                      title: Text(filtered[i],
                          textAlign: l10n.localeName == 'ar'
                              ? TextAlign.right
                              : TextAlign.left),
                      onTap: () {
                        onSelected(filtered[i]);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePickerItem(
      BuildContext context, String title, String time, Function(String) onTimeSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: InkWell(
        onTap: () async {
          final parts = time.split(':');
          final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                  hour: int.parse(parts[0]), minute: int.parse(parts[1])));
          if (picked != null) {
            onTimeSelected(
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: context.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Text(time,
              style: TextStyle(
                  color: context.secondaryColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
