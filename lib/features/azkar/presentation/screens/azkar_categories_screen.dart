import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
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
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              )
            : Text(
                l10n.azkar,
                style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24),
              ),
        centerTitle: false,
        actions: [
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
                    title: Text(l10n.resetAllProgress, style: GoogleFonts.amiri()),
                    content: Text(
                      l10n.localeName == 'ar' 
                        ? 'هل أنت متأكد من إعادة تعيين جميع تقدم الأذكار؟'
                        : 'Are you sure you want to reset all azkar progress?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.missed,
                          foregroundColor: Colors.white,
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
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingAzkar,
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
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty ? l10n.noCategoriesFound : l10n.noSearchResults,
                    style: GoogleFonts.amiri(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  if (_searchQuery.isEmpty)
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<AzkarBloc>()
                          .add(const AzkarEvent.loadCategories()),
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
              await context.read<AzkarBloc>().stream.firstWhere((s) => !s.isLoading).timeout(const Duration(seconds: 15), onTimeout: () => state);
            },
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                final now = DateTime.now();
                
                DateTime morningTime;
                DateTime eveningTime;

                morningTime = _parseTime(settingsState.morningAzkarTime, now);
                eveningTime = _parseTime(settingsState.eveningAzkarTime, now);

                return ListView.builder(
                  key: const Key('azkar_categories_list'),
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final isRecommended = _checkIsRecommended(category, now, morningTime, eveningTime);

                    return _CategoryCard(
                      key: Key('category_$category'),
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

void _showAddReminderDialog(BuildContext context, String category) {
  final cubit = context.read<SettingsCubit>();
  final l10n = AppLocalizations.of(context)!;

  String selectedTime = '05:00';
  String customTitle = category;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              l10n.localeName == 'ar' ? 'إضافة تنبيه' : 'Add Alarm',
              style: GoogleFonts.amiri(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(l10n.localeName == 'ar' ? 'الفئة' : 'Category'),
                  subtitle: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.localeName == 'ar' ? 'العنوان' : 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  initialValue: customTitle,
                  onChanged: (val) => customTitle = val,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.localeName == 'ar' ? 'الوقت' : 'Time'),
                  trailing: InkWell(
                    onTap: () async {
                      final time = await _selectTime(context, selectedTime);
                      if (time != null) {
                        setDialogState(() => selectedTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedTime,
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  cubit.addReminder(AzkarReminder(
                    category: category,
                    time: selectedTime,
                    title: customTitle,
                    isEnabled: true,
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.localeName == 'ar' ? 'تمت إضافة التنبيه' : 'Alarm added'),
                      backgroundColor: AppTheme.accent,
                    ),
                  );
                },
                child: Text(l10n.yes),
              ),
            ],
          );
        }
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

  const _CategoryCard({
    super.key,
    required this.category,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddReminderDialog(context, category),
                  icon: const Icon(Icons.alarm_add_rounded, size: 16, color: AppTheme.accent),
                  label: Text(
                    l10n.localeName == 'ar' ? 'إضافة تنبيه' : 'Add Alarm',
                    style: const TextStyle(fontSize: 12, color: AppTheme.accent),
                  ),
                ),
              ],
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
                      const Text('★', style: TextStyle(color: AppTheme.onAccent, fontSize: 10)),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.recommended,
                        style: const TextStyle(
                          color: AppTheme.onAccent, 
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
