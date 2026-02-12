import 'package:fard/domain/models/salaah.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AddQadaDialog extends StatefulWidget {
  final void Function(Map<Salaah, int> counts) onAdd;

  const AddQadaDialog({super.key, required this.onAdd});

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
    _tabController = TabController(length: 2, vsync: this);
    for (final s in Salaah.values) {
      _controllers[s] = TextEditingController(text: '0');
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
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400.0, maxHeight: 500.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'إضافة قضاء',
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16.0),
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppTheme.primaryLight, width: 1.0),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppTheme.accent,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: [
                  Tab(
                    child: Text('بالعدد',
                        style: GoogleFonts.amiri(fontSize: 14.0)),
                  ),
                  Tab(
                    child: Text('بالوقت',
                        style: GoogleFonts.amiri(fontSize: 14.0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCountTab(),
                  _buildTimeTab(),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء',
                      style: GoogleFonts.amiri(color: AppTheme.textSecondary, fontSize: 15.0)),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  ),
                  child: Text('إضافة',
                      style: GoogleFonts.amiri(
                          fontWeight: FontWeight.w700, fontSize: 15.0)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountTab() {
    return SingleChildScrollView(
      child: Column(
        children: Salaah.values.map((salaah) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 60.0,
                  child: Text(
                    salaah.label,
                    style: GoogleFonts.amiri(
                      color: AppTheme.textPrimary,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final val =
                                int.tryParse(_controllers[salaah]!.text) ?? 0;
                            if (val > 0) {
                              _controllers[salaah]!.text = '${val - 1}';
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.remove_rounded, size: 18.0),
                          color: AppTheme.textSecondary,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controllers[salaah],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.outfit(
                              color: AppTheme.accent,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final val =
                                int.tryParse(_controllers[salaah]!.text) ?? 0;
                            _controllers[salaah]!.text = '${val + 1}';
                            setState(() {});
                          },
                          icon: const Icon(Icons.add_rounded, size: 18.0),
                          color: AppTheme.textSecondary,
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'حدد الفترة لحساب عدد الصلوات',
            style: GoogleFonts.amiri(
              color: AppTheme.textSecondary,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          // From date
          _DatePickerRow(
            label: 'من',
            date: _fromDate,
            onPick: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _fromDate ?? DateTime.now(),
                firstDate: DateTime(2000),
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
            label: 'إلى',
            date: _toDate,
            onPick: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _toDate ?? DateTime.now(),
                firstDate: DateTime(2000),
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
                color: AppTheme.accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12.0),
                border:
                    Border.all(color: AppTheme.accent.withOpacity(0.30), width: 1.0),
              ),
              child: Column(
                children: [
                  Text(
                    'عدد الأيام',
                    style: GoogleFonts.amiri(
                        color: AppTheme.textSecondary, fontSize: 13.0),
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
                    'صلاة لكل فرض',
                    style: GoogleFonts.amiri(
                        color: AppTheme.textSecondary, fontSize: 13.0),
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

    widget.onAdd(counts);
    Navigator.pop(context);
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
                  color: AppTheme.textSecondary, fontSize: 15.0),
            ),
            const Spacer(),
            Text(
              date != null
                  ? '${date!.year}/${date!.month}/${date!.day}'
                  : 'اختر تاريخ',
              style: GoogleFonts.outfit(
                color: date != null
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(width: 8.0),
            const Icon(Icons.calendar_today_rounded,
                color: AppTheme.textSecondary, size: 18.0),
          ],
        ),
      ),
    );
  }
}
