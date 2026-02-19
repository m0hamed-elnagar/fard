import 'package:equatable/equatable.dart';

class Reciter extends Equatable {
  final String identifier;      // e.g., 'ar.alafasy'
  final String name;            // e.g., 'Mishary Rashid Alafasy'
  final String englishName;     // e.g., 'Mishary Rashid Alafasy'
  final String language;        // 'ar'
  final String? style;          // e.g., 'Murattal'
  final String? imageUrl;       // Optional: local asset or network
  
  const Reciter({
    required this.identifier,
    required this.name,
    required this.englishName,
    required this.language,
    this.style,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [identifier, name, englishName, language, style, imageUrl];

  // Popular reciters to show first
  static const List<String> popularReciters = [
    'ar.alafasy',           // Mishary Rashid Alafasy
    'ar.husary',            // Mahmoud Khalil Al-Husary
    'ar.minshawi',          // Mohamed Siddiq Al-Minshawy
    'ar.abdulbasitmurattal',// Abdul Basit Abdul Samad
    'ar.ahmedajamy',        // Ahmed Ibn Ali Al-Ajamy
    'ar.abdurrahmaansudais',// Abdurrahmaan As-Sudais
  ];
}
