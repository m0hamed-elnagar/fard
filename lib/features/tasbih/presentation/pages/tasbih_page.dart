import 'package:fard/core/di/injection.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/tasbih/presentation/bloc/tasbih_bloc.dart';
import 'package:fard/features/tasbih/presentation/widgets/tasbih_widgets.dart';
import 'package:fard/features/tasbih/presentation/widgets/tasbih_sheets.dart';
import 'package:fard/features/tasbih/presentation/widgets/completion_dua_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class TasbihPage extends StatelessWidget {
  const TasbihPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TasbihBloc>()..add(const TasbihEvent.loadData()),
      child: const TasbihView(),
    );
  }
}

class TasbihView extends StatefulWidget {
  const TasbihView({super.key});

  @override
  State<TasbihView> createState() => _TasbihViewState();
}

class _TasbihViewState extends State<TasbihView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocBuilder<TasbihBloc, TasbihState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null) {
          return _buildErrorView(context, state.error!, l10n);
        }

        final currentDhikr = state.currentCategory.items.isNotEmpty 
            ? state.currentCategory.items[state.currentCycleIndex.clamp(0, state.currentCategory.items.length - 1)]
            : null;

        final title = _getLocalizedCategoryName(state.currentCategory.id, l10n) ?? state.currentCategory.name;

        return Scaffold(
          appBar: AppBar(
            title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _showSettings(context),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;
              final counterSize = (maxHeight * 0.3).clamp(160.0, 280.0);
              final buttonSize = (maxHeight * 0.12).clamp(80.0, 120.0);
              
              return SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            _buildCategorySelector(context, state, l10n),
                            const SizedBox(height: 20),
                            if (state.currentCategory.sequenceMode == 'rotating') ...[
                              CycleProgressIndicator(
                                currentIndex: state.currentCycleIndex,
                                totalCycles: state.currentCategory.cycles,
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (state.showCompletionDua && state.currentCompletionDua != null)
                              CompletionDuaCard(state: state)
                            else if (currentDhikr != null)
                              GestureDetector(
                                onVerticalDragUpdate: (details) {
                                  _scrollController.position.jumpTo(
                                    (_scrollController.position.pixels - details.delta.dy)
                                        .clamp(0.0, _scrollController.position.maxScrollExtent),
                                  );
                                },
                                child: DhikrDisplayCard(
                                  arabic: currentDhikr.arabic,
                                  transliteration: currentDhikr.transliteration,
                                  translation: currentDhikr.translation,
                                  showTransliteration: state.data.settings.showTransliteration,
                                  showTranslation: state.data.settings.showTranslation,
                                ),
                              ),
                          ],
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CounterCircle(
                                count: state.currentCycleCount,
                                targetCount: state.customTasbihTarget ?? state.currentCategory.countsPerCycle,
                                size: counterSize,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Material(
                                  color: AppTheme.surfaceLight,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_note_rounded, color: AppTheme.accent),
                                    onPressed: () => _showCustomTargetDialog(context, state),
                                    tooltip: l10n.customTasbihTarget,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        _buildControlBar(context, state, buttonSize),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String error, AppLocalizations l10n) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.missed, size: 48),
              const SizedBox(height: 16),
              Text(l10n.errorLoadingTasbih, 
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(error, textAlign: TextAlign.center, 
                style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<TasbihBloc>().add(const TasbihEvent.loadData()),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, TasbihState state, double buttonSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 36),
            onPressed: () => _confirmReset(context),
            color: AppTheme.textSecondary,
          ),
          TasbihButton(
            size: buttonSize,
            onTap: () => context.read<TasbihBloc>().add(const TasbihEvent.increment()),
          ),
          IconButton(
            icon: Icon(
              state.data.settings.hapticFeedback 
                  ? Icons.vibration_rounded 
                  : Icons.phonelink_ring_rounded, 
              size: 32,
            ),
            onPressed: () => context.read<TasbihBloc>().add(const TasbihEvent.toggleVibration()),
            color: state.data.settings.hapticFeedback ? AppTheme.accent : AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  String? _getLocalizedCategoryName(String id, AppLocalizations l10n) {
    switch (id) {
      case 'tasbih_after_salah': return l10n.tasbih_after_salah_name;
      case 'tasbih_fatimah': return l10n.tasbih_fatimah_name;
      case 'four_foundations': return l10n.four_foundations_name;
      case 'yunus_dhikr': return l10n.yunus_dhikr_name;
      case 'morning_evening': return l10n.morning_evening_name;
      case 'istighfar': return l10n.istighfar_name;
      default: return null;
    }
  }

  String? _getLocalizedCategoryDesc(String id, AppLocalizations l10n) {
    switch (id) {
      case 'tasbih_after_salah': return l10n.tasbih_after_salah_desc;
      case 'tasbih_fatimah': return l10n.tasbih_fatimah_desc;
      case 'four_foundations': return l10n.four_foundations_desc;
      case 'yunus_dhikr': return l10n.yunus_dhikr_desc;
      case 'morning_evening': return l10n.morning_evening_desc;
      case 'istighfar': return l10n.istighfar_desc;
      default: return null;
    }
  }

  void _confirmReset(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.resetCounter),
        content: Text(l10n.resetProgressWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<TasbihBloc>().add(const TasbihEvent.reset());
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppTheme.missed)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, TasbihState state, AppLocalizations l10n) {
    return InkWell(
      onTap: () => _showCategorySheet(context, state),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.collections_bookmark_rounded, color: AppTheme.accent, size: 20),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                _getLocalizedCategoryName(state.currentCategory.id, l10n) ?? state.currentCategory.name,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.unfold_more_rounded, color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  void _showCustomTargetDialog(BuildContext context, TasbihState state) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: state.customTasbihTarget?.toString() ?? '',
    );
    final tasbihBloc = context.read<TasbihBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.customTasbihTarget),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.customTasbihTargetHint(state.currentCategory.countsPerCycle),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              tasbihBloc.add(const TasbihEvent.updateCustomTarget(null));
              Navigator.pop(context);
            },
            child: Text(l10n.resetItem, style: const TextStyle(color: AppTheme.missed)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final target = int.tryParse(controller.text);
              if (target != null && target > 0) {
                tasbihBloc.add(TasbihEvent.updateCustomTarget(target));
              }
              Navigator.pop(context);
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  void _showCategorySheet(BuildContext context, TasbihState state) {
    final tasbihBloc = context.read<TasbihBloc>();
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return BlocProvider.value(
              value: tasbihBloc,
              child: CategorySelectionSheet(
                state: state,
                scrollController: scrollController,
                getName: (id) => _getLocalizedCategoryName(id, l10n),
                getDesc: (id) => _getLocalizedCategoryDesc(id, l10n),
              ),
            );
          },
        );
      },
    );
  }

  void _showSettings(BuildContext context) {
    final tasbihBloc = context.read<TasbihBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: tasbihBloc,
          child: const TasbihSettingsSheet(),
        );
      },
    );
  }
}
