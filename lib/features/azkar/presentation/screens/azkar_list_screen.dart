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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AzkarBloc>().add(AzkarEvent.resetCategory(widget.category));
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Category',
          ),
        ],
      ),
      body: BlocBuilder<AzkarBloc, AzkarState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Center(child: CircularProgressIndicator()),
            azkarLoaded: (category, azkar) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: azkar.length,
              itemBuilder: (context, index) {
                return _ZekrCard(
                  item: azkar[index],
                  onTap: () async {
                    context.read<AzkarBloc>().add(AzkarEvent.incrementCount(index));
                    
                    // Tactile feedback
                    if (await Vibration.hasVibrator()) {
                      if (azkar[index].currentCount + 1 >= azkar[index].count) {
                        Vibration.vibrate(duration: 100, amplitude: 255);
                      } else {
                        Vibration.vibrate(duration: 30);
                      }
                    }
                  },
                );
              },
            ),
            error: (message) => Center(child: Text(message)),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _ZekrCard extends StatelessWidget {
  final AzkarItem item;
  final VoidCallback onTap;

  const _ZekrCard({required this.item, required this.onTap});

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
