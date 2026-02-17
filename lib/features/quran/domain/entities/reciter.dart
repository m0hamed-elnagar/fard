import 'package:equatable/equatable.dart';

class Reciter extends Equatable {
  final String id;
  final String name;
  final String? style;

  const Reciter({
    required this.id,
    required this.name,
    this.style,
  });

  @override
  List<Object?> get props => [id, name, style];
}
