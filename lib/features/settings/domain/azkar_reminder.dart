class AzkarReminder {
  final String category;
  final String time; // Format: HH:mm
  final bool isEnabled;
  final String title; // Display title, e.g., "Morning Azkar"

  const AzkarReminder({
    required this.category,
    required this.time,
    this.isEnabled = true,
    this.title = '',
  });

  AzkarReminder copyWith({
    String? category,
    String? time,
    bool? isEnabled,
    String? title,
  }) {
    return AzkarReminder(
      category: category ?? this.category,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'time': time,
        'isEnabled': isEnabled,
        'title': title,
      };

  factory AzkarReminder.fromJson(Map<String, dynamic> json) => AzkarReminder(
        category: json['category'] as String,
        time: json['time'] as String,
        isEnabled: json['isEnabled'] as bool? ?? true,
        title: json['title'] as String? ?? '',
      );
}
