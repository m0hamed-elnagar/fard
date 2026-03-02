import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/features/quran/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/quran/domain/entities/werd_goal.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/extensions/number_extension.dart';

class WerdProgressBar extends StatelessWidget {
  const WerdProgressBar({super.key});

  void _showSetGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<WerdBloc>(),
        child: const _SetWerdGoalDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WerdBloc, WerdState>(
      builder: (context, state) {
        if (state.goal == null) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.track_changes_rounded, color: AppTheme.primaryLight),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حدد وردك اليومي',
                        style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'تابع تقدمك في قراءة القرآن',
                        style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showSetGoalDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('بدء'),
                ),
              ],
            ),
          );
        }

        final progress = state.progress;
        final goal = state.goal!;
        
        int current = progress?.totalAyahsReadToday ?? 0;
        int total = goal.valueInAyahs;
        
        final percent = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
        final isCompleted = current >= total;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: InkWell(
            onTap: () => _showSetGoalDialog(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.stars_rounded : Icons.menu_book_rounded,
                            color: isCompleted ? Colors.amber : AppTheme.primaryLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ورد اليوم',
                            style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (progress?.lastReadAyah != null)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              QuranReaderPage.route(
                                surahNumber: progress!.lastReadAyah!.surahNumber,
                                ayahNumber: progress.lastReadAyah!.ayahNumberInSurah,
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const Text('متابعة'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            foregroundColor: AppTheme.primaryLight,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                      backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.amber : AppTheme.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تم إكمال ${current.toArabicIndic()} من ${total.toArabicIndic()} آية',
                        style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if ((progress?.streak ?? 0) > 0)
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${progress!.streak.toArabicIndic()} يوم',
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SetWerdGoalDialog extends StatefulWidget {
  const _SetWerdGoalDialog();

  @override
  State<_SetWerdGoalDialog> createState() => _SetWerdGoalDialogState();
}

class _SetWerdGoalDialogState extends State<_SetWerdGoalDialog> {
  WerdGoalType _type = WerdGoalType.fixedAmount;
  WerdUnit _unit = WerdUnit.ayah;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentGoal = context.read<WerdBloc>().state.goal;
    int initialValue = 10;
    if (currentGoal != null) {
      _type = currentGoal.type;
      _unit = currentGoal.unit;
      initialValue = currentGoal.value;
    }
    _controller = TextEditingController(text: initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(int newValue) {
    final clamped = newValue.clamp(1, 1000);
    setState(() {
      _controller.text = clamped.toString();
    });
  }

  void _onUnitChanged(WerdUnit unit) {
    setState(() {
      _unit = unit;
      // Default for ayah is 10, for others is 1
      _controller.text = (unit == WerdUnit.ayah ? 10 : 1).toString();
    });
  }

  void _onTypeChanged(WerdGoalType type) {
    setState(() {
      _type = type;
      if (_type == WerdGoalType.finishInDays) {
        _controller.text = '30';
      } else {
        // Reset to unit defaults
        _controller.text = (_unit == WerdUnit.ayah ? 10 : 1).toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'تحديد هدف الورد',
        style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<WerdGoalType>(
              segments: const [
                ButtonSegment(value: WerdGoalType.fixedAmount, label: Text('كمية'), icon: Icon(Icons.straighten)),
                ButtonSegment(value: WerdGoalType.finishInDays, label: Text('ختم'), icon: Icon(Icons.event_available)),
              ],
              selected: {_type},
              onSelectionChanged: (v) => _onTypeChanged(v.first),
            ),
            const SizedBox(height: 20),
            if (_type == WerdGoalType.fixedAmount) ...[
              Wrap(
                spacing: 8,
                children: WerdUnit.values.map((u) {
                  final label = {
                    WerdUnit.ayah: 'آية',
                    WerdUnit.page: 'صفحة',
                    WerdUnit.quarter: 'ربع',
                    WerdUnit.hizb: 'حزب',
                    WerdUnit.juz: 'جزء',
                  }[u]!;
                  return ChoiceChip(
                    label: Text(label),
                    selected: _unit == u,
                    onSelected: (selected) {
                      if (selected) _onUnitChanged(u);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final val = int.tryParse(_controller.text) ?? 0;
                    _updateValue(val - 1);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final val = int.tryParse(_controller.text) ?? 0;
                    _updateValue(val + 1);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _type == WerdGoalType.finishInDays ? 'يوماً للختم' : 'يومياً',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = int.tryParse(_controller.text) ?? 10;
            context.read<WerdBloc>().add(WerdEvent.setGoal(WerdGoal(
              type: _type,
              value: val,
              unit: _unit,
              startDate: DateTime.now(),
            )));
            Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
