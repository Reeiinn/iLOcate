/// A trip plan the user creates: a title, a date, some notes and the places
/// they want to visit. This is the entity the app does full CRUD on.
class Trip {
  final String id;
  final String title;
  final DateTime date;
  final String notes;
  final List<String> placeIds;

  const Trip({
    required this.id,
    required this.title,
    required this.date,
    this.notes = '',
    this.placeIds = const [],
  });

  Trip copyWith({
    String? title,
    DateTime? date,
    String? notes,
    List<String>? placeIds,
  }) {
    return Trip(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      placeIds: placeIds ?? this.placeIds,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String? ?? '',
      placeIds: List<String>.from(json['placeIds'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'notes': notes,
        'placeIds': placeIds,
      };
}
