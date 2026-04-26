import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:quran/quran.dart' as quran;

class SetWerdGoalDialog extends StatefulWidget {
  const SetWerdGoalDialog({super.key});

  @override
  State<SetWerdGoalDialog> createState() => _SetWerdGoalDialogState();
}

class _SetWerdGoalDialogState extends State<SetWerdGoalDialog> {
  WerdGoalType _type = WerdGoalType.fixedAmount;
  WerdUnit _unit = WerdUnit.ayah;
  int _startPointType = 0; // 0: Beginning, 1: Last Read, 2: Specific
  int _selectedSurah = 1;
  int _selectedAyah = 1;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    final currentGoal = context.read<WerdBloc>().state.goal;
    final werdBlocState = context.read<WerdBloc>().state;
    final progress = werdBlocState.progress;
    int initialValue = 10;

    if (currentGoal != null) {
      _type = currentGoal.type;
      _unit = currentGoal.unit;
      initialValue = currentGoal.value;
    }

    // If user has progress, pre-populate the specific place selector with current position
    if (progress?.lastReadAbsolute != null) {
      final currentPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(
        progress!.lastReadAbsolute!,
      );
      _selectedSurah = currentPos[0];
      _selectedAyah = currentPos[1];
    }

    // PRIORITY 1: If user has been reading, show "from where stopped"
    // Check both lastReadAbsolute and that they've actually read something (totalAmountReadToday > 0)
    if (progress?.lastReadAbsolute != null && progress!.totalAmountReadToday > 0) {
      _startPointType = 1; // "From last read" - shows current position
    }
    // PRIORITY 2: Check if there's a saved goal with specific start
    else if (currentGoal?.startAbsolute != null) {
      if (currentGoal!.startAbsolute == 1) {
        _startPointType = 0; // "From beginning"
      } else {
        _startPointType = 2; // "Specific place"
        final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(
          currentGoal.startAbsolute!,
        );
        _selectedSurah = pos[0];
        _selectedAyah = pos[1];
      }
    }
    // Default: No progress, no goal - start from beginning
    else {
      _startPointType = 0;
    }

    _valueController = TextEditingController(text: initialValue.toString());
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _onTypeChanged(WerdGoalType type) {
    setState(() {
      _type = type;
      if (_type == WerdGoalType.finishInDays) {
        _valueController.text = '30';
      } else {
        _valueController.text = (_unit == WerdUnit.ayah ? 10 : 1).toString();
      }
    });
  }

  int _calculateStartAbsolute() {
    if (_startPointType == 0) return 1;
    if (_startPointType == 1) {
      final lastRead = context.read<QuranBloc>().state.lastReadPosition;
      if (lastRead != null) {
        final lastAbs = QuranHizbProvider.getAbsoluteAyahNumber(
          lastRead.ayahNumber.surahNumber,
          lastRead.ayahNumber.ayahNumberInSurah,
        );
        // FIX: Suggest the NEXT ayah, not the one already read
        return (lastAbs + 1 > 6236) ? 1 : lastAbs + 1;
      }
      return 1;
    }
    return QuranHizbProvider.getAbsoluteAyahNumber(
      _selectedSurah,
      _selectedAyah,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: context.backgroundColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isAr),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle(
                      isAr ? 'نوع الهدف' : 'Goal Type',
                      Icons.track_changes_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildGoalTypeToggle(isAr),
                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      isAr ? 'نقطة البداية' : 'Start Point',
                      Icons.place_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildStartPointSelector(isAr),
                    if (_startPointType == 2) ...[
                      const SizedBox(height: 12),
                      _buildSpecificPlaceSelector(isAr),
                    ],
                    const SizedBox(height: 24),

                    if (_type == WerdGoalType.fixedAmount) ...[
                      _buildSectionTitle(
                        isAr ? 'الوحدة' : 'Unit',
                        Icons.straighten_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildUnitSelector(isAr),
                      const SizedBox(height: 24),
                    ],

                    _buildSectionTitle(
                      _type == WerdGoalType.finishInDays
                          ? (isAr ? 'المدة الزمنية' : 'Duration')
                          : (isAr ? 'الكمية اليومية' : 'Daily Amount'),
                      _type == WerdGoalType.finishInDays
                          ? Icons.calendar_today_rounded
                          : Icons.numbers_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildValueInput(isAr),

                    if (_type == WerdGoalType.finishInDays) ...[
                      const SizedBox(height: 12),
                      Text(
                        isAr
                            ? 'سيتم تقسيم المتبقي من المصحف على عدد الأيام المختار.'
                            : 'Remaining Quran will be divided over the selected days.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.onSurfaceVariantColor.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildActions(context, isAr),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: context.secondaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            isAr ? 'تحديد هدف الورد' : 'Set Werd Goal',
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.onSurfaceColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              backgroundColor: context.outlineColor.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.secondaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.amiri(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.onSurfaceColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalTypeToggle(bool isAr) {
    return SegmentedButton<WerdGoalType>(
      style: SegmentedButton.styleFrom(
        backgroundColor: context.outlineColor.withValues(alpha: 0.1),
        selectedBackgroundColor: context.secondaryColor,
        selectedForegroundColor: context.theme.colorScheme.onSecondary,
        side: BorderSide(color: context.outlineColor.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      segments: [
        ButtonSegment(
          value: WerdGoalType.fixedAmount,
          label: Text(isAr ? 'كمية يومية' : 'Daily'),
          icon: const Icon(Icons.bolt_rounded, size: 18),
        ),
        ButtonSegment(
          value: WerdGoalType.finishInDays,
          label: Text(isAr ? 'ختم القرآن' : 'Finish'),
          icon: const Icon(Icons.auto_stories_rounded, size: 18),
        ),
      ],
      selected: {_type},
      onSelectionChanged: (v) => _onTypeChanged(v.first),
    );
  }

  Widget _buildStartPointSelector(bool isAr) {
    return Container(
      decoration: BoxDecoration(
        color: context.outlineColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.outlineColor.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          key: const ValueKey('start_point_dropdown'),
          value: _startPointType,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(isAr ? 'من البداية (الفاتحة)' : 'Start from Al-Fatihah (beginning)'),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text(isAr ? 'متابعة من حيث توقفت' : 'Continue where I stopped'),
            ),
            DropdownMenuItem(
              value: 2,
              child: Text(isAr ? 'اختيار سورة وآية محددة' : 'Choose specific surah/ayah'),
            ),
          ],
          onChanged: (v) => setState(() => _startPointType = v ?? 0),
        ),
      ),
    );
  }

  Widget _buildSpecificPlaceSelector(bool isAr) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: context.outlineColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.outlineColor.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                key: const ValueKey('surah_dropdown'),
                value: _selectedSurah,
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                items: List.generate(114, (i) => i + 1).map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(
                      isAr
                          ? quran.getSurahNameArabic(s)
                          : quran.getSurahName(s),
                      style: GoogleFonts.amiri(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() {
                  _selectedSurah = v ?? 1;
                  // Ensure selected ayah is still valid for the new surah
                  final maxAyahs = quran.getVerseCount(_selectedSurah);
                  if (_selectedAyah > maxAyahs) {
                    _selectedAyah = 1;
                  }
                }),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.outlineColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.outlineColor.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                key: const ValueKey('ayah_dropdown'),
                value: _selectedAyah,
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                items:
                    List.generate(
                      quran.getVerseCount(_selectedSurah),
                      (i) => i + 1,
                    ).map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Text(isAr ? a.toArabicIndic() : a.toString()),
                      );
                    }).toList(),
                onChanged: (v) => setState(() => _selectedAyah = v ?? 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitSelector(bool isAr) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [WerdUnit.ayah, WerdUnit.page, WerdUnit.juz].map((u) {
        final label = {
          WerdUnit.ayah: isAr ? 'آية' : 'Ayah',
          WerdUnit.page: isAr ? 'صفحة' : 'Page',
          WerdUnit.juz: isAr ? 'جزء' : 'Juz',
        }[u]!;
        final isSelected = _unit == u;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _unit = u);
          },
          selectedColor: context.secondaryColor,
          labelStyle: TextStyle(
            color: isSelected ? context.theme.colorScheme.onSecondary : context.onSurfaceColor,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildValueInput(bool isAr) {
    return Container(
      decoration: BoxDecoration(
        color: context.outlineColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.outlineColor.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _buildStepButton(Icons.remove_rounded, () {
            final val = int.tryParse(_valueController.text) ?? 1;
            if (val > 1) {
              _valueController.text = (val - 1).toString();
              setState(() {});
            }
          }, key: const ValueKey('decrement_button')),
          Expanded(
            child: TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                final val = int.tryParse(v);
                if (val != null) {
                  int max = 10000;
                  if (_type == WerdGoalType.finishInDays) {
                    max = 10000; // Allow many days if they want
                  } else {
                    if (_unit == WerdUnit.juz) max = 30;
                    if (_unit == WerdUnit.page) max = 604;
                  }

                  if (val > max) {
                    _valueController.text = max.toString();
                  } else if (val < 1) {
                    _valueController.text = '1';
                  }
                }
                setState(() {});
              },
            ),
          ),
          _buildStepButton(Icons.add_rounded, () {
            final val = int.tryParse(_valueController.text) ?? 1;
            int max = 10000;
            if (_type == WerdGoalType.finishInDays) {
              max = 10000;
            } else {
              if (_unit == WerdUnit.juz) max = 30;
              if (_unit == WerdUnit.page) max = 604;
            }

            if (val < max) {
              _valueController.text = (val + 1).toString();
              setState(() {});
            }
          }, key: const ValueKey('increment_button')),
        ],
      ),
    );
  }

  Widget _buildStepButton(IconData icon, VoidCallback onPressed, {Key? key}) {
    // ignore: avoid_print
    print('DEBUG: Building button with key: $key');
    return Material(
      key: key,
      color: context.secondaryColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: context.secondaryColor, size: 28),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isAr) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isAr ? 'إلغاء' : 'Cancel',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                final val = int.tryParse(_valueController.text) ?? 10;
                final startAbs = _calculateStartAbsolute();

                context.read<WerdBloc>().add(
                  WerdEvent.setGoal(
                    WerdGoal(
                      id: 'default',
                      type: _type,
                      value: val,
                      unit: _unit,
                      startDate: DateTime.now(),
                      startAbsolute: startAbs,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.secondaryColor,
                foregroundColor: context.theme.colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                isAr ? 'حفظ الهدف' : 'Save Goal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
