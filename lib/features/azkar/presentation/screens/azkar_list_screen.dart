import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import '../../../../core/theme/app_theme.dart';
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
              if (state.azkar.isNotEmpty)
                IconButton(
                  onPressed: () => _showResetDialog(),
                  icon: const Icon(Icons.history_rounded),
                  tooltip: AppLocalizations.of(context)!.resetAllProgress,
                ),
            ],
          ),
          body: Column(
            children: [
              if (state.isLoading) 
                const LinearProgressIndicator(minHeight: 2),
              if (state.azkar.isNotEmpty)
                _buildProgressBar(state.azkar),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(List<AzkarItem> azkar) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (azkar.isNotEmpty) ? (_currentPage + 1) / azkar.length : 0,
                backgroundColor: AppTheme.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_currentPage + 1} / ${azkar.length}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
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
            const Icon(Icons.info_outline,
                size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              l10n.noItemsFound,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemCount: azkar.length,
          itemBuilder: (context, index) {
            final item = azkar[index];
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              child: _ZekrCard(
                item: item,
                onReset: () {
                  context.read<AzkarBloc>().add(AzkarEvent.resetItem(index));
                },
                onTap: () async {
                  context.read<AzkarBloc>().add(AzkarEvent.incrementCount(index));

                  // Tactile feedback
                  if (await Vibration.hasVibrator()) {
                    if (item.currentCount + 1 >= item.count) {
                      Vibration.vibrate(duration: 100, amplitude: 255);
                      // Auto-advance to next page if completed
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
                  }
                },
              ),
            );
          },
        ),
        if (_currentPage > 0)
          PositionedDirectional(
            start: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.accent, size: 20),
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
        if (_currentPage < azkar.length - 1)
          PositionedDirectional(
            end: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.accent, size: 20),
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
  }
}

class _ZekrCard extends StatelessWidget {
  final AzkarItem item;
  final VoidCallback onTap;
  final VoidCallback onReset;

  const _ZekrCard({
    required this.item, 
    required this.onTap, 
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = item.currentCount >= item.count;

    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.saved.withValues(alpha: 0.1) : AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompleted ? AppTheme.saved : AppTheme.cardBorder,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.zekr,
              style: GoogleFonts.amiri(
                fontSize: 24,
                height: 1.8,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            if (item.description.isNotEmpty) ...[
              Text(
                item.description,
                style: GoogleFonts.amiri(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            const Divider(height: 1),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.reference,
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (item.currentCount > 0)
                  IconButton(
                    onPressed: onReset,
                    icon: const Icon(Icons.history_rounded, size: 24, color: AppTheme.textSecondary),
                    tooltip: l10n.resetItem,
                  ),
              ],
            ),
            const SizedBox(height: 32),
            // Large Counter Button
            GestureDetector(
              onTap: isCompleted ? null : onTap,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.saved : AppTheme.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isCompleted ? AppTheme.saved : AppTheme.accent).withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${item.currentCount}',
                        style: GoogleFonts.outfit(
                          color: isCompleted ? AppTheme.onSaved : AppTheme.onAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 2,
                        color: (isCompleted ? AppTheme.onSaved : AppTheme.onAccent).withValues(alpha: 0.5),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      Text(
                        '${item.count}',
                        style: GoogleFonts.outfit(
                          color: (isCompleted ? AppTheme.onSaved : AppTheme.onAccent).withValues(alpha: 0.8),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.saved),
                  const SizedBox(width: 8),
                  Text(
                    l10n.localeName == 'ar' ? 'تم بنجاح' : 'Completed',
                    style: GoogleFonts.outfit(
                      color: AppTheme.saved,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
