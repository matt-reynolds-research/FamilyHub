class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String assignee;
  final DateTime? dueDate;
  final String priority; // 'high', 'medium', 'low'
  final String? assignedTo;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.assignee = 'Unassigned',
    this.dueDate,
    this.priority = 'medium',
    this.assignedTo,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      assignee: (json['family_members'] as Map<String, dynamic>?)?['name']
              as String? ??
          'Unassigned',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      priority: 'medium', // Priority not in DB schema — default
      assignedTo: json['assigned_to'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'due_date': dueDate?.toIso8601String(),
      'assigned_to': assignedTo,
    };
  }

  Task copyWith({bool? isCompleted}) {
    return Task(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      assignee: assignee,
      dueDate: dueDate,
      priority: priority,
      assignedTo: assignedTo,
    );
  }
}
