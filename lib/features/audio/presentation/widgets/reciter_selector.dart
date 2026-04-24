import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';

class ReciterSelector extends StatefulWidget {
  const ReciterSelector({super.key});

  @override
  State<ReciterSelector> createState() => _ReciterSelectorState();
}

class _ReciterSelectorState extends State<ReciterSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToReciter(int index) {
    if (_scrollController.hasClients) {
      final offset = index * 72.0;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ReciterManagerBloc, ReciterManagerState>(
      builder: (context, managerState) {
        return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, playerState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.surfaceContainerHighestColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.audioSettings,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Quality Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.audioQuality,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<AudioQuality>(
                          segments: [
                            ButtonSegment(
                              value: AudioQuality.low64,
                              label: Text(l10n.lowBitrate),
                            ),
                            ButtonSegment(
                              value: AudioQuality.medium128,
                              label: Text(l10n.medBitrate),
                            ),
                            ButtonSegment(
                              value: AudioQuality.high192,
                              label: Text(l10n.highBitrate),
                            ),
                          ],
                          selected: {playerState.quality},
                          onSelectionChanged: (Set<AudioQuality> selection) {
                            context.read<AudioPlayerBloc>().add(
                              ChangeQuality(selection.first),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      l10n.selectReciter,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),

                  // Quick select: Popular reciters
                  if (managerState.availableReciters.isNotEmpty)
                    SizedBox(
                      height: 120, // Increased height for better visibility
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: Reciter.popularReciters.map((id) {
                          final reciter = managerState.availableReciters
                              .firstWhere(
                                (r) => r.identifier == id,
                                orElse: () => managerState.availableReciters.first,
                              );
                          // Only show if it matches the id
                          if (reciter.identifier != id) {
                            return const SizedBox.shrink();
                          }

                          final isSelected =
                              managerState.currentReciter?.identifier == id;
                          return _PopularReciterCard(
                            reciter: reciter,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<ReciterManagerBloc>().add(
                                SelectReciter(reciter),
                              );
                              context.read<AudioPlayerBloc>().add(
                                ChangeReciter(reciter),
                              );
                              final index = managerState.availableReciters
                                  .indexWhere(
                                    (r) => r.identifier == reciter.identifier,
                                  );
                              if (index != -1) {
                                _scrollToReciter(index);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  const Divider(),

                  // Full list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: managerState.availableReciters.length,
                      itemBuilder: (context, index) {
                        final reciter = managerState.availableReciters[index];
                        final isSelected =
                            managerState.currentReciter?.identifier ==
                            reciter.identifier;

                        final isArabic = l10n.localeName == 'ar';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : context.outlineVariantColor,
                            child: Text(
                              reciter.name.isNotEmpty
                                  ? reciter.name.substring(0, 1)
                                  : 'A',
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : context.onSurfaceVariantColor,
                              ),
                            ),
                          ),
                          title: Text(
                            isArabic ? reciter.name : reciter.englishName,
                          ),
                          subtitle: Text(
                            isArabic ? reciter.englishName : reciter.name,
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            context.read<ReciterManagerBloc>().add(
                              SelectReciter(reciter),
                            );
                            context.read<AudioPlayerBloc>().add(
                              ChangeReciter(reciter),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PopularReciterCard extends StatelessWidget {
  final Reciter reciter;
  final bool isSelected;
  final VoidCallback onTap;

  const _PopularReciterCard({
    required this.reciter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Text(
                reciter.name.isNotEmpty ? reciter.name.substring(0, 1) : 'A',
                style: TextStyle(
                  color: isSelected ? context.onSurfaceColor : context.onSurfaceVariantColor,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isArabic
                  ? reciter.name.split(' ').last
                  : reciter.englishName.split(' ').last,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
