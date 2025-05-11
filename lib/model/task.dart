class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.priority = 'Medium',
    this.dueDate,
    this.isCompleted = false,
  });
}
