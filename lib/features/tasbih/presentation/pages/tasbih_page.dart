import 'dart:io';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/tasbih/presentation/bloc/tasbih_bloc.dart';
import 'package:fard/features/tasbih/presentation/widgets/tasbih_widgets.dart';
import 'package:fard/features/tasbih/presentation/widgets/tasbih_sheets.dart';
import 'package:fard/features/tasbih/presentation/widgets/completion_dua_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

class TasbihPage extends StatelessWidget {
  const TasbihPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<TasbihBloc>()..add(const TasbihEvent.loadData()),
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
  late PageController _pageController;
  final Set<int> _completedInSession = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<TasbihBloc, TasbihState>(
      listener: (context, state) {
        if (state.currentCycleCount == 0) {
          _completedInSession.remove(state.currentCycleIndex);
        }

        final isRotating = state.currentCategory.sequenceMode == 'rotating';
        final currentDhikr = state.currentCategory.items.isNotEmpty
            ? state.currentCategory.items[state.currentCycleIndex.clamp(
                0,
                state.currentCategory.items.length - 1,
              )]
            : null;
        final targetCount =
            state.customTasbihTarget ??
            (isRotating
                ? state.currentCategory.countsPerCycle
                : (currentDhikr?.targetCount ?? 33));

        final isCompleted = state.currentCycleCount >= targetCount;
        final currentIndex = state.currentCycleIndex;

        if (isCompleted && !_completedInSession.contains(currentIndex)) {
          _completedInSession.add(currentIndex);

          // Vibration on completion (heavy)
          if (state.data.settings.hapticFeedback && !Platform.isWindows) {
            Vibration.vibrate(duration: 100, amplitude: 255);
          }

          // Auto-scroll to next if available
          if (currentIndex < state.currentCategory.items.length - 1) {
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted && _pageController.hasClients) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }
            });
          }
        }

        if (_pageController.hasClients &&
            _pageController.page?.round() != state.currentCycleIndex) {
          _pageController.animateToPage(
            state.currentCycleIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      child: BlocBuilder<TasbihBloc, TasbihState>(
        buildWhen: (prev, curr) =>
            prev.isLoading != curr.isLoading ||
            prev.error != curr.error ||
            prev.currentCategory.id != curr.currentCategory.id,
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.error != null) {
            return _buildErrorView(context, state.error!, l10n);
          }

          final title =
              _getLocalizedCategoryName(state.currentCategory.id, l10n) ??
              state.currentCategory.name;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                title,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
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

                // Responsive sizes
                final screenHeight = MediaQuery.of(context).size.height;
                final isSmallScreen = screenHeight < 700;
                final counterSize = isSmallScreen ? 180.0 : 240.0;
                final buttonSize = isSmallScreen ? 80.0 : 100.0;

                return Stack(
                  children: [
                    BlocBuilder<TasbihBloc, TasbihState>(
                      buildWhen: (prev, curr) =>
                          prev.showCompletionDua != curr.showCompletionDua ||
                          prev.currentCategory.items.length !=
                              curr.currentCategory.items.length,
                      builder: (context, state) {
                        return PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            final bloc = context.read<TasbihBloc>();
                            if (index != bloc.state.currentCycleIndex) {
                              bloc.add(TasbihEvent.changeItem(index));
                            }
                          },
                          itemCount: state.showCompletionDua
                              ? 1
                              : state.currentCategory.items.length,
                          itemBuilder: (context, index) {
                            return _TasbihPageItem(
                              index: index,
                              maxHeight: maxHeight,
                              counterSize: counterSize,
                              buttonSize: buttonSize,
                              getName: (id) =>
                                  _getLocalizedCategoryName(id, l10n),
                              getDesc: (id) =>
                                  _getLocalizedCategoryDesc(id, l10n),
                            );
                          },
                        );
                      },
                    ),
                    // Navigation arrows
                    BlocBuilder<TasbihBloc, TasbihState>(
                      buildWhen: (prev, curr) =>
                          prev.showCompletionDua != curr.showCompletionDua ||
                          prev.currentCycleIndex != curr.currentCycleIndex ||
                          prev.currentCategory.items.length !=
                              curr.currentCategory.items.length,
                      builder: (context, state) {
                        if (state.showCompletionDua ||
                            state.currentCategory.items.length <= 1) {
                          return const SizedBox.shrink();
                        }
                        return Stack(
                          children: [
                            if (state.currentCycleIndex > 0)
                              PositionedDirectional(
                                start: 4,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: context.secondaryColor
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.arrow_back_ios_rounded,
                                          size: 20),
                                      color: context.secondaryColor,
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            if (state.currentCycleIndex <
                                state.currentCategory.items.length - 1)
                              PositionedDirectional(
                                end: 4,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: context.secondaryColor
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 20),
                                      color: context.secondaryColor,
                                      onPressed: () {
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String error,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: context.errorColor, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingTasbih,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: context.onSurfaceVariantColor),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<TasbihBloc>().add(
                  const TasbihEvent.loadData(),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getLocalizedCategoryName(String id, AppLocalizations l10n) {
    switch (id) {
      case 'tasbih_after_salah':
        return l10n.tasbih_after_salah_name;
      case 'tasbih_fatimah':
        return l10n.tasbih_fatimah_name;
      case 'four_foundations':
        return l10n.four_foundations_name;
      case 'yunus_dhikr':
        return l10n.yunus_dhikr_name;
      case 'morning_evening':
        return l10n.morning_evening_name;
      case 'istighfar':
        return l10n.istighfar_name;
      case 'salat_ala_nabi':
        return 'الصلاة على النبي';
      default:
        return null;
    }
  }

  String? _getLocalizedCategoryDesc(String id, AppLocalizations l10n) {
    switch (id) {
      case 'tasbih_after_salah':
        return l10n.tasbih_after_salah_desc;
      case 'tasbih_fatimah':
        return l10n.tasbih_fatimah_desc;
      case 'four_foundations':
        return l10n.four_foundations_desc;
      case 'yunus_dhikr':
        return l10n.yunus_dhikr_desc;
      case 'morning_evening':
        return l10n.morning_evening_desc;
      case 'istighfar':
        return l10n.istighfar_desc;
      case 'salat_ala_nabi':
        return 'الصلاة والسلام على نبينا محمد صلى الله عليه وسلم';
      default:
        return null;
    }
  }

  void _showSettings(BuildContext context) {
    final tasbihBloc = context.read<TasbihBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceContainerColor,
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

class _TasbihPageItem extends StatelessWidget {
  final int index;
  final double maxHeight;
  final double counterSize;
  final double buttonSize;
  final String? Function(String) getName;
  final String? Function(String) getDesc;

  const _TasbihPageItem({
    required this.index,
    required this.maxHeight,
    required this.counterSize,
    required this.buttonSize,
    required this.getName,
    required this.getDesc,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TasbihBloc, TasbihState>(
      buildWhen: (prev, curr) =>
          prev.showCompletionDua != curr.showCompletionDua ||
          prev.currentCategory.id != curr.currentCategory.id ||
          prev.currentCycleIndex != curr.currentCycleIndex ||
          prev.itemProgress != curr.itemProgress ||
          prev.data.settings != curr.data.settings ||
          prev.customTasbihTarget != curr.customTasbihTarget,
      builder: (context, state) {
        final currentDhikr = state.currentCategory.items.isNotEmpty
            ? state.currentCategory.items[index.clamp(
                0,
                state.currentCategory.items.length - 1,
              )]
            : null;

        final itemCount =
            currentDhikr != null ? (state.itemProgress[currentDhikr.id] ?? 0) : 0;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section: Category & Text
                  Column(
                    children: [
                      _buildCategorySelector(context, state, l10n),
                      const SizedBox(height: 20),
                      if (state.currentCategory.sequenceMode == 'rotating' &&
                          !state.showCompletionDua) ...[
                        CycleProgressIndicator(
                          currentIndex: index,
                          totalCycles: state.currentCategory.cycles,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (state.showCompletionDua &&
                          state.currentCompletionDua != null)
                        CompletionDuaCard(state: state)
                      else if (currentDhikr != null)
                        DhikrDisplayCard(
                          arabic: currentDhikr.arabic,
                          transliteration: currentDhikr.transliteration,
                          translation: currentDhikr.translation,
                          showTransliteration:
                              state.data.settings.showTransliteration,
                          showTranslation: state.data.settings.showTranslation,
                        ),
                    ],
                  ),

                  // Bottom Section: Counter & Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CounterCircle(
                              count: itemCount,
                              targetCount: state.customTasbihTarget ??
                                  (state.currentCategory.sequenceMode ==
                                          'rotating'
                                      ? state.currentCategory.countsPerCycle
                                      : (currentDhikr?.targetCount ?? 33)),
                              size: counterSize,
                            ),
                            if (!state.showCompletionDua)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Material(
                                  color: context.surfaceContainerHighestColor,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit_note_rounded,
                                    ),
                                    onPressed: () => _showCustomTargetDialog(
                                      context,
                                      state,
                                    ),
                                    tooltip: l10n.customTasbihTarget,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildControlBar(context, state, buttonSize),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    TasbihState state,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () => _showCategorySheet(context, state),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.surfaceContainerHighestColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.outlineColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.collections_bookmark_rounded,
              size: 20,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                getName(state.currentCategory.id) ?? state.currentCategory.name,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: context.onSurfaceColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.unfold_more_rounded,
              color: context.onSurfaceVariantColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet(BuildContext context, TasbihState state) {
    final tasbihBloc = context.read<TasbihBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceContainerColor,
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
                getName: getName,
                getDesc: getDesc,
              ),
            );
          },
        );
      },
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
            hintText: l10n.customTasbihTargetHint(
              state.currentCategory.countsPerCycle,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              tasbihBloc.add(const TasbihEvent.updateCustomTarget(null));
              Navigator.pop(context);
            },
            child: Text(
              l10n.resetItem,
              style: TextStyle(color: context.errorColor),
            ),
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

  Widget _buildControlBar(
    BuildContext context,
    TasbihState state,
    double buttonSize,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 36),
          onPressed: () => _confirmReset(context, state),
          color: context.onSurfaceVariantColor,
        ),
        TasbihButton(
          size: buttonSize,
          onTap: () =>
              context.read<TasbihBloc>().add(const TasbihEvent.increment()),
        ),
        IconButton(
          icon: Icon(
            state.data.settings.hapticFeedback
                ? Icons.vibration_rounded
                : Icons.phonelink_ring_rounded,
            size: 32,
          ),
          onPressed: () => context.read<TasbihBloc>().add(
            const TasbihEvent.toggleVibration(),
          ),
          color: state.data.settings.hapticFeedback
              ? context.secondaryColor
              : context.onSurfaceVariantColor,
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, TasbihState state) {
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
            child: Text(
              l10n.delete,
              style: TextStyle(color: context.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
