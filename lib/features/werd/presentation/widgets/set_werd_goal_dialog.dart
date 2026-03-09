import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:fard/core/extensions/number_extension.dart';
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
    int initialValue = 10;
    if (currentGoal != null) {
      _type = currentGoal.type;
      _unit = currentGoal.unit;
      initialValue = currentGoal.value;
      
      // Restore start point if possible
      if (currentGoal.startAbsolute != null) {
        if (currentGoal.startAbsolute == 1) {
          _startPointType = 0;
        } else {
          _startPointType = 2; // Default to specific if not 1
          final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(currentGoal.startAbsolute!);
          _selectedSurah = pos[0];
          _selectedAyah = pos[1];
        }
      }
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
        return QuranHizbProvider.getAbsoluteAyahNumber(
          lastRead.ayahNumber.surahNumber,
          lastRead.ayahNumber.ayahNumberInSurah,
        );
      }
      return 1;
    }
    return QuranHizbProvider.getAbsoluteAyahNumber(_selectedSurah, _selectedAyah);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    return AlertDialog(
      title: Text(
        isAr ? 'تحديد هدف الورد' : 'Set Werd Goal',
        style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<WerdGoalType>(
              segments: [
                ButtonSegment(
                  value: WerdGoalType.fixedAmount, 
                  label: Text(isAr ? 'كمية يومية' : 'Daily Amount'), 
                  icon: const Icon(Icons.straighten)
                ),
                ButtonSegment(
                  value: WerdGoalType.finishInDays, 
                  label: Text(isAr ? 'ختم القرآن' : 'Finish Quran'), 
                  icon: const Icon(Icons.event_available)
                ),
              ],
              selected: {_type},
              onSelectionChanged: (v) => _onTypeChanged(v.first),
            ),
            const SizedBox(height: 20),
            
            if (_type == WerdGoalType.fixedAmount) ...[
              Text(
                isAr ? 'أين تريد البدء؟' : 'Where to start?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _startPointType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  DropdownMenuItem(value: 0, child: Text(isAr ? 'من البداية' : 'From beginning')),
                  DropdownMenuItem(value: 1, child: Text(isAr ? 'من حيث توقفت' : 'From last read')),
                  DropdownMenuItem(value: 2, child: Text(isAr ? 'مكان محدد' : 'Specific place')),
                ],
                onChanged: (v) => setState(() => _startPointType = v ?? 0),
              ),
              if (_startPointType == 2) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedSurah,
                        decoration: InputDecoration(
                          labelText: isAr ? 'السورة' : 'Surah',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: List.generate(114, (i) => i + 1).map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              isAr ? quran.getSurahNameArabic(s) : quran.getSurahName(s),
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() {
                          _selectedSurah = v ?? 1;
                          _selectedAyah = 1;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedAyah,
                        decoration: InputDecoration(
                          labelText: isAr ? 'الآية' : 'Ayah',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: List.generate(
                          quran.getVerseCount(_selectedSurah), 
                          (i) => i + 1
                        ).map((a) {
                          return DropdownMenuItem(
                            value: a,
                            child: Text(isAr ? a.toArabicIndic() : a.toString()),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedAyah = v ?? 1),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text(
                isAr ? 'حدد الكمية والوحدة:' : 'Set amount and unit:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  WerdUnit.ayah,
                  WerdUnit.page,
                  WerdUnit.juz,
                ].map((u) {
                  final label = {
                    WerdUnit.ayah: isAr ? 'آية' : 'Ayah',
                    WerdUnit.page: isAr ? 'صفحة' : 'Page',
                    WerdUnit.juz: isAr ? 'جزء' : 'Juz',
                  }[u]!;
                  return ChoiceChip(
                    label: Text(label),
                    selected: _unit == u,
                    onSelected: (selected) {
                      if (selected) setState(() => _unit = u);
                    },
                  );
                }).toList(),
              ),
            ] else ...[
              Text(
                isAr ? 'سيتم تقسيم المتبقي من المصحف على عدد الأيام:' : 'Remaining Quran will be divided over days:',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 20),
            Text(
              _type == WerdGoalType.finishInDays 
                ? (isAr ? 'عدد الأيام للختم:' : 'Days to finish:')
                : (isAr ? 'الكمية اليومية:' : 'Daily amount:'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    final val = int.tryParse(_valueController.text) ?? 1;
                    if (val > 1) _valueController.text = (val - 1).toString();
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final val = int.tryParse(_valueController.text) ?? 1;
                    _valueController.text = (val + 1).toString();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isAr ? 'إلغاء' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = int.tryParse(_valueController.text) ?? 10;
            final startAbs = _type == WerdGoalType.fixedAmount 
                ? _calculateStartAbsolute() 
                : _calculateDefaultFinishStart();
            
            context.read<WerdBloc>().add(WerdEvent.setGoal(WerdGoal(
              id: 'default',
              type: _type,
              value: val,
              unit: _unit,
              startDate: DateTime.now(),
              startAbsolute: startAbs,
            )));
            Navigator.pop(context);
          },
          child: Text(isAr ? 'حفظ' : 'Save'),
        ),
      ],
    );
  }

  int _calculateDefaultFinishStart() {
    final lastRead = context.read<QuranBloc>().state.lastReadPosition;
    if (lastRead != null) {
      return QuranHizbProvider.getAbsoluteAyahNumber(
        lastRead.ayahNumber.surahNumber,
        lastRead.ayahNumber.ayahNumberInSurah,
      );
    }
    return 1;
  }
}
