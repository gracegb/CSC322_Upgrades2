import 'priority.dart';

class Task {
  final String title;
  final DateTime date;
  bool completed;
  final Priority priority;

  Task({
    required this.title,
    required this.date,
    this.completed = false,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'completed': completed,
      'priority': priority.index,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      date: DateTime.parse(map['date']),
      completed: map['completed'],
      priority: Priority.values[map['priority']],
    );
  }
}
