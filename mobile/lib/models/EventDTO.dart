class EventDto {
  final String name;
  final String type;
  final DateTime date;
  final String description;

  EventDto({
    required this.name,
    required this.type,
    required this.date,
    required this.description,
  });

  /// Tworzy EventDto z mapy JSON
  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      name: json['name'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
    );
  }

  /// Zamienia EventDto na mapę JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      // Wysyłamy datę w formacie ISO 8601 w UTC
      'date': date.toUtc().toIso8601String(),
      'description': description,
    };
  }
}
