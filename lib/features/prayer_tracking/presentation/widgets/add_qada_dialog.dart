import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

class AddQadaDialog extends StatefulWidget {
  final void Function(Map<Salaah, int> counts) onConfirm;
  final Map<Salaah, int>? initialCounts;
  final String? title;

  const AddQadaDialog({
    super.key,
    required this.onConfirm,
    this.initialCounts,
    this.title,
  });

  @override
  State<AddQadaDialog> createState() => _AddQadaDialogState();
}

class _AddQadaDialogState extends State<AddQadaDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<Salaah, TextEditingController> _controllers = {};
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _tabController = TabController(
      length: widget.initialCounts == null ? 2 : 1,
      vsync: this,
    );
    for (final s in Salaah.values) {
      final initialValue = widget.initialCounts?[s] ?? 0;
      _controllers[s] = TextEditingController(text: '$initialValue');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400.0,
          maxHeight: (screenHeight * 0.8).clamp(300.0, 600.0),
        ),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.title ?? l10n.addQada,
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16.0),
            // Tabs
            if (widget.initialCounts == null)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: AppTheme.cardBorder.withValues(alpha: 0.5),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.accent,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle: GoogleFonts.amiri(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                  unselectedLabelStyle: GoogleFonts.amiri(fontSize: 14.0),
                  tabs: [
                    Tab(text: l10n.byCount),
                    Tab(text: l10n.byTime),
                  ],
                ),
              ),
            if (widget.initialCounts == null) const SizedBox(height: 16.0),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: widget.initialCounts == null
                    ? null
                    : const NeverScrollableScrollPhysics(),
                children: [
                  _buildCountTab(screenWidth < 360),
                  if (widget.initialCounts == null) _buildTimeTab(),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.amiri(
                      color: AppTheme.textSecondary,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.onAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 10.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.initialCounts == null ? l10n.add : l10n.update,
                    style: GoogleFonts.amiri(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountTab(bool isNarrow) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: Salaah.values.map((salaah) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: isNarrow ? 50.0 : 60.0,
                  child: Text(
                    salaah.localizedName(l10n),
                    style: GoogleFonts.amiri(
                      color: AppTheme.textPrimary,
                      fontSize: isNarrow ? 14.0 : 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        _AdjustButton(
                          icon: Icons.remove_rounded,
                          onPressed: () {
                            final val =
                                int.tryParse(_controllers[salaah]!.text) ?? 0;
                            if (val > 0) {
                              _controllers[salaah]!.text = '${val - 1}';
                              setState(() {});
                            }
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controllers[salaah],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.outfit(
                              color: AppTheme.accent,
                              fontSize: isNarrow ? 16.0 : 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        _AdjustButton(
                          icon: Icons.add_rounded,
                          onPressed: () {
                            final val =
                                int.tryParse(_controllers[salaah]!.text) ?? 0;
                            _controllers[salaah]!.text = '${val + 1}';
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            l10n.selectPeriod,
            style: GoogleFonts.amiri(
              color: AppTheme.textSecondary,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          // From date
          _DatePickerRow(
            label: l10n.from,
            date: _fromDate,
            onPick: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _fromDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppTheme.primaryLight,
                      surface: AppTheme.surface,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _fromDate = picked);
            },
          ),
          const SizedBox(height: 12.0),
          // To date
          _DatePickerRow(
            label: l10n.to,
            date: _toDate,
            onPick: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _toDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppTheme.primaryLight,
                      surface: AppTheme.surface,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _toDate = picked);
            },
          ),
          const SizedBox(height: 20.0),
          if (_fromDate != null && _toDate != null) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.30),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.daysCount,
                    style: GoogleFonts.amiri(
                      color: AppTheme.textSecondary,
                      fontSize: 13.0,
                    ),
                  ),
                  Text(
                    '${_toDate!.difference(_fromDate!).inDays.abs() + 1}',
                    style: GoogleFonts.outfit(
                      color: AppTheme.accent,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.prayersPerFard,
                    style: GoogleFonts.amiri(
                      color: AppTheme.textSecondary,
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onConfirm() {
    final counts = <Salaah, int>{};

    if (_tabController.index == 0) {
      // By count
      for (final s in Salaah.values) {
        counts[s] = int.tryParse(_controllers[s]!.text) ?? 0;
      }
    } else {
      // By time — same count for all prayers
      if (_fromDate != null && _toDate != null) {
        final days = _toDate!.difference(_fromDate!).inDays.abs() + 1;
        for (final s in Salaah.values) {
          counts[s] = days;
        }
      }
    }

    widget.onConfirm(counts);
    Navigator.pop(context);
  }
}

class _AdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AdjustButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20.0),
      color: AppTheme.textSecondary,
      splashRadius: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPick;

  const _DatePickerRow({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppTheme.cardBorder, width: 1.0),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.amiri(
                color: AppTheme.textSecondary,
                fontSize: 15.0,
              ),
            ),
            const Spacer(),
            Text(
              date != null
                  ? '${date!.year}/${date!.month}/${date!.day}'
                  : l10n.selectDate,
              style: GoogleFonts.outfit(
                color: date != null
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(width: 8.0),
            const Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.textSecondary,
              size: 18.0,
            ),
          ],
        ),
      ),
    );
  }
}
