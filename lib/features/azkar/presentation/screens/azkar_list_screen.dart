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
  @override
  void initState() {
    super.initState();
    context.read<AzkarBloc>().add(AzkarEvent.loadAzkar(widget.category));
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
          ),
          body: Column(
            children: [
              if (state.isLoading) 
                const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AzkarState state) {
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
                  const Text(
                    'No items found in this category',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<AzkarBloc>()
                  .add(AzkarEvent.loadAzkar(widget.category));
              await context.read<AzkarBloc>().stream.firstWhere((s) => !s.isLoading).timeout(const Duration(seconds: 15), onTimeout: () => state);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: azkar.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: state.isLoading 
                        ? null 
                        : () {
                            context.read<AzkarBloc>().add(AzkarEvent.resetCategory(widget.category));
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
                        foregroundColor: AppTheme.accent,
                        side: const BorderSide(color: AppTheme.accent, width: 1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.history_rounded),
                      label: Text(
                        'Reset All Progress',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  );
                }

                final itemIndex = index - 1;
                final item = azkar[itemIndex];

                return _ZekrCard(
                  item: item,
                  onReset: () {
                    context.read<AzkarBloc>().add(AzkarEvent.resetItem(itemIndex));
                  },
                  onTap: () async {
                    context
                        .read<AzkarBloc>()
                        .add(AzkarEvent.incrementCount(itemIndex));

                    // Tactile feedback
                    if (await Vibration.hasVibrator()) {
                      if (item.currentCount + 1 >= item.count) {
                        Vibration.vibrate(duration: 100, amplitude: 255);
                      } else {
                        Vibration.vibrate(duration: 30);
                      }
                    }
                  },
                );
              },
            ),
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
    final isCompleted = item.currentCount >= item.count;

    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: isCompleted ? AppTheme.saved.withValues(alpha: 0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isCompleted ? AppTheme.saved : AppTheme.cardBorder,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                item.zekr,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  height: 1.8,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              if (item.description.isNotEmpty) ...[
                Text(
                  item.description,
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.reference,
                      style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.currentCount > 0)
                    IconButton(
                      onPressed: onReset,
                      icon: const Icon(Icons.history_rounded, size: 20, color: AppTheme.textSecondary),
                      tooltip: 'Reset Item',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppTheme.saved : AppTheme.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${item.currentCount} / ${item.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
