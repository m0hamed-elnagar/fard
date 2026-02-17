import 'package:equatable/equatable.dart';

class Word extends Equatable {
  final int id;
  final String text;
  final String transliteration;
  final String translation;
  final String? root;
  final String? grammar;
  final int position;

  const Word({
    required this.id,
    required this.text,
    required this.transliteration,
    required this.translation,
    this.root,
    this.grammar,
    required this.position,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        transliteration,
        translation,
        root,
        grammar,
        position,
      ];
}
