import 'dart:io';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import '../../../../core/utils/quran_text_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../blocs/azkar_bloc.dart';
import '../../domain/azkar_item.dart';

class AzkarListScreen extends StatefulWidget {
  final String category;
  const AzkarListScreen({super.key, required this.category});

  @override
  State<AzkarListScreen> createState() => _AzkarListScreenState();
}

class _AzkarListScreenState extends State<AzkarListScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  int _fontSizeLevel = 1; // 0=Small, 1=Medium, 2=Large
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<AzkarBloc>().add(AzkarEvent.loadAzkar(widget.category));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get _fontSize {
    switch (_fontSizeLevel) {
      case 0:
        return 18;
      case 1:
        return 22;
      case 2:
        return 28;
      default:
        return 22;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarBloc, AzkarState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.category,
              style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
            ),
            actions: [
              _buildFontSizeButton(),
              if (state.azkar.isNotEmpty)
                IconButton(
                  onPressed: _showResetDialog,
                  icon: const Icon(Icons.history_rounded),
                  tooltip: AppLocalizations.of(context)!.resetAllProgress,
                ),
            ],
          ),
          body: Column(
            children: [
              if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
              if (state.azkar.isNotEmpty) _buildProgressBar(state.azkar),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(List<AzkarItem> azkar) {
    final completedCount = azkar.where((item) => item.currentCount >= item.count).length;
    final progressValue = azkar.isNotEmpty ? completedCount.toDouble() / azkar.length : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: context.surfaceContainerHighestColor,
                valueColor: AlwaysStoppedAnimation<Color>(context.secondaryColor),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$completedCount / ${azkar.length}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetAllProgress, style: GoogleFonts.amiri()),
        content: Text(
          l10n.localeName == 'ar'
              ? 'هل أنت متأكد من إعادة تعيين جميع تقدم هذه الفئة؟'
              : 'Are you sure you want to reset all progress for this category?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel, style: TextStyle(color: context.onSurfaceVariantColor)),
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

    if (confirmed == true && mounted) {
      context.read<AzkarBloc>().add(AzkarEvent.resetCategory(widget.category));
    }
  }

  Widget _buildBody(BuildContext context, AzkarState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isLoading && state.azkar.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.azkar.isEmpty) {
      return Center(child: Text(state.error!));
    }

    final azkar = state.azkar;
    if (azkar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 48),
            const SizedBox(height: 16),
            Text(l10n.noItemsFound, style: TextStyle(color: context.onSurfaceVariantColor)),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemCount: azkar.length,
      itemBuilder: (context, index) {
        final item = azkar[index];
        final isCompleted = item.currentCount >= item.count;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmallScreen = screenHeight < 700;
            final counterSize = isSmallScreen ? 180.0 : 240.0;
            final buttonSize = isSmallScreen ? 80.0 : 100.0;

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top: Dhikr Text
                          Column(
                            children: [
                              _buildAzkarCounterBadge(azkar),
                              const SizedBox(height: 20),
                              _buildDhikrCard(item, isCompleted),
                            ],
                          ),

                          // Bottom: Counter + Tap Button
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    _buildAzkarCounterCircle(
                                      count: item.currentCount,
                                      target: item.count,
                                      isCompleted: isCompleted,
                                      size: counterSize,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                _buildControlBar(context, item, isCompleted, buttonSize),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Page navigation arrows
                if (index > 0)
                  PositionedDirectional(
                    start: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.secondaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: context.secondaryColor,
                            size: 20,
                          ),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                if (index < azkar.length - 1)
                  PositionedDirectional(
                    end: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.secondaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: context.secondaryColor,
                            size: 20,
                          ),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
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
        );
      },
    );
  }

  Widget _buildAzkarCounterBadge(List<AzkarItem> azkar) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceContainerHighestColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.outlineColor),
      ),
      child: Text(
        '${_currentPage + 1} / ${azkar.length}',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: context.onSurfaceColor,
        ),
      ),
    );
  }

  Widget _buildFontSizeButton() {
    final labels = ['A', 'A', 'A'];
    final sizes = [12.0, 16.0, 20.0];

    return PopupMenuButton<int>(
      icon: const Icon(Icons.text_fields_rounded),
      tooltip: 'Font Size',
      itemBuilder: (context) => [
        for (int i = 0; i < labels.length; i++)
          CheckedPopupMenuItem<int>(
            value: i,
            checked: _fontSizeLevel == i,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  labels[i],
                  style: GoogleFonts.amiri(fontSize: sizes[i]),
                ),
                const SizedBox(width: 8),
                Text(
                  ['Small', 'Medium', 'Large'][i],
                  style: GoogleFonts.outfit(fontSize: 14),
                ),
              ],
            ),
          ),
      ],
      onSelected: (level) => setState(() => _fontSizeLevel = level),
    );
  }

  Widget _buildDhikrCard(AzkarItem item, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? context.primaryColor.withValues(alpha: 0.1)
            : context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? context.primaryColor : context.outlineColor,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            QuranTextUtils.isQuranicText(item.reference)
                ? QuranTextUtils.formatWithQuranSymbols(item.zekr)
                : item.zekr,
            style: GoogleFonts.amiri(
              fontSize: _fontSize,
              height: 1.8,
              color: context.onSurfaceColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              item.description,
              style: GoogleFonts.amiri(
                fontSize: 15,
                color: context.onSurfaceVariantColor,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAzkarCounterCircle({
    required int count,
    required int target,
    required bool isCompleted,
    required double size,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: target > 0 ? count / target : 0,
            strokeWidth: size * 0.05,
            backgroundColor: context.surfaceContainerHighestColor,
            color: isCompleted ? context.primaryColor : context.secondaryColor,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: GoogleFonts.outfit(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: context.onSurfaceColor,
              ),
            ),
            Text(
              '/ $target',
              style: GoogleFonts.outfit(
                fontSize: size * 0.075,
                color: context.onSurfaceVariantColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlBar(
    BuildContext context,
    AzkarItem item,
    bool isCompleted,
    double buttonSize,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 36),
          onPressed: () {
            context.read<AzkarBloc>().add(AzkarEvent.resetItem(_currentPage));
          },
          color: context.onSurfaceVariantColor,
        ),
        GestureDetector(
          onTap: isCompleted ? null : () => _incrementCounter(context, item),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: context.primaryContainerColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.primaryContainerColor.withValues(alpha: 0.3),
                  blurRadius: buttonSize * 0.15,
                  spreadRadius: buttonSize * 0.05,
                ),
              ],
            ),
            child: Icon(
              Icons.touch_app_rounded,
              size: buttonSize * 0.5,
              color: context.theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            _vibrationEnabled
                ? Icons.vibration_rounded
                : Icons.phonelink_ring_rounded,
            size: 32,
          ),
          onPressed: () => setState(() => _vibrationEnabled = !_vibrationEnabled),
          color: _vibrationEnabled
              ? context.secondaryColor
              : context.onSurfaceVariantColor,
        ),
      ],
    );
  }

  Future<void> _incrementCounter(BuildContext context, AzkarItem item) async {
    final index = _currentPage;
    final azkarBloc = context.read<AzkarBloc>();
    azkarBloc.add(AzkarEvent.incrementCount(index));

    final state = azkarBloc.state;
    final azkar = state.azkar;
    if (index >= azkar.length) return;
    final updatedItem = azkar[index];

    if (_vibrationEnabled && !Platform.isWindows && await Vibration.hasVibrator() == true) {
      if (updatedItem.currentCount >= updatedItem.count) {
        Vibration.vibrate(duration: 100, amplitude: 255);
        if (index < azkar.length - 1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      } else {
        Vibration.vibrate(duration: 30);
      }
    } else if (updatedItem.currentCount >= updatedItem.count) {
      if (index < azkar.length - 1) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }
}
