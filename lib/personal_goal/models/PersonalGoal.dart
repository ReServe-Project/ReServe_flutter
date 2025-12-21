class PersonalGoal {
  final int id;
  final String title;
  final DateTime date;
  final bool isCompleted;

  const PersonalGoal({
    required this.id,
    required this.title,
    required this.date,
    required this.isCompleted,
  });

  factory PersonalGoal.fromJson(Map<String, dynamic> json) {
    return PersonalGoal(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      date: DateTime.parse(json['date'] as String),
      isCompleted: (json['is_completed'] ?? false) as bool,
    );
  }

  factory PersonalGoal.fromCalendarItem(
    Map<String, dynamic> json,
    String dateStr,
  ) {
    return PersonalGoal(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      date: DateTime.parse(dateStr),
      isCompleted: (json['is_completed'] ?? false) as bool,
    );
  }

  PersonalGoal copyWith({bool? isCompleted}) {
    return PersonalGoal(
      id: id,
      title: title,
      date: date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
