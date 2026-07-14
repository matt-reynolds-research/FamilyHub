class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final String assignee;
  final DateTime? dueDate;
  final String priority; // 'high', 'medium', 'low'

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.assignee,
    this.dueDate,
    required this.priority,
  });
}
