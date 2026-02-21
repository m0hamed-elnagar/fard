import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';

import 'package:fard/features/audio/domain/repositories/audio_repository.dart';

class ReciterSelector extends StatelessWidget {
  const ReciterSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Audio Settings',
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
                      'Audio Quality',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<AudioQuality>(
                      segments: const [
                        ButtonSegment(
                          value: AudioQuality.low64,
                          label: Text('Low (64k)'),
                        ),
                        ButtonSegment(
                          value: AudioQuality.medium128,
                          label: Text('Med (128k)'),
                        ),
                        ButtonSegment(
                          value: AudioQuality.high192,
                          label: Text('High (192k)'),
                        ),
                      ],
                      selected: {state.quality},
                      onSelectionChanged: (Set<AudioQuality> selection) {
                        context.read<AudioBloc>().add(
                          AudioEvent.changeQuality(selection.first),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Select Reciter',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              
              // Quick select: Popular reciters
              if (state.availableReciters.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: Reciter.popularReciters.map((id) {
                      final reciter = state.availableReciters.firstWhere(
                        (r) => r.identifier == id,
                        orElse: () => state.availableReciters.first,
                      );
                      // Only show if it matches the id
                      if (reciter.identifier != id) return const SizedBox.shrink();
                      
                      final isSelected = state.currentReciter?.identifier == id;
                      return _PopularReciterCard(
                        reciter: reciter,
                        isSelected: isSelected,
                        onTap: () {
                          context.read<AudioBloc>().add(AudioEvent.selectReciter(reciter));
                        },
                      );
                    }).toList(),
                  ),
                ),
              
              const Divider(),
              
              // Full list
              Expanded(
                child: ListView.builder(
                  itemCount: state.availableReciters.length,
                  itemBuilder: (context, index) {
                    final reciter = state.availableReciters[index];
                    final isSelected = state.currentReciter?.identifier == 
                                       reciter.identifier;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected 
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.grey[200],
                        child: Text(
                          reciter.name.isNotEmpty ? reciter.name.substring(0, 1) : 'A',
                          style: TextStyle(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      title: Text(reciter.name),
                      subtitle: Text(reciter.englishName),
                      trailing: isSelected 
                          ? Icon(Icons.check_circle, 
                                color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        context.read<AudioBloc>().add(AudioEvent.selectReciter(reciter));
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
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reciter.englishName.split(' ').last,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
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
