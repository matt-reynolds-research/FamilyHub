enum TaskSectionKind { family, open, waiting, someday, done, other }

class TaskParseException implements Exception {
  TaskParseException(this.message,
      {required this.lineNumber, required this.line});
  final String message;
  final int lineNumber;
  final String line;

  @override
  String toString() =>
      'TaskParseException: $message (line $lineNumber): "$line"';
}

sealed class TaskNode {
  const TaskNode();
  String render();
}

final class TaskRawNode extends TaskNode {
  const TaskRawNode(this.text);
  final String text;
  @override
  String render() => text;
}

final class ActiveTask extends TaskNode {
  const ActiveTask({
    required this.title,
    this.context,
    this.addedBy,
    this.addedDate,
    this.raw,
  });

  final String title;
  final String? context;
  final String? addedBy;
  final DateTime? addedDate;
  final String? raw;

  String get dedupKey => normalizeTaskKey(title);

  @override
  String render() {
    if (raw != null) return raw!;
    final parts = <String>['- [ ] **$title**'];
    if (context != null && context!.isNotEmpty) parts.add(context!);
    if (addedBy != null && addedDate != null) {
      parts.add('added via text from $addedBy on ${taskDateStamp(addedDate!)}');
    }
    return parts.join(' — ');
  }
}

final class DoneTask extends TaskNode {
  const DoneTask({required this.title, required this.date, this.raw});
  final String title;
  final DateTime date;
  final String? raw;
  @override
  String render() => raw ?? '- [x] ~~$title~~ (${taskDateStamp(date)})';
}

final class TaskSection {
  const TaskSection({
    required this.headingRaw,
    required this.title,
    required this.kind,
    required this.nodes,
  });
  final String headingRaw;
  final String title;
  final TaskSectionKind kind;
  final List<TaskNode> nodes;
  Iterable<ActiveTask> get activeTasks => nodes.whereType<ActiveTask>();
  Iterable<DoneTask> get doneTasks => nodes.whereType<DoneTask>();
  TaskSection copyWith({List<TaskNode>? nodes}) => TaskSection(
        headingRaw: headingRaw,
        title: title,
        kind: kind,
        nodes: nodes ?? this.nodes,
      );
}

final class TaskDocument {
  const TaskDocument({
    required this.preamble,
    required this.sections,
    required this.endsWithNewline,
  });
  final List<TaskNode> preamble;
  final List<TaskSection> sections;
  final bool endsWithNewline;

  TaskSection? sectionOf(TaskSectionKind kind) {
    for (final section in sections) {
      if (section.kind == kind) return section;
    }
    return null;
  }

  List<ActiveTask> activeTasks(TaskSectionKind kind) =>
      sectionOf(kind)?.activeTasks.toList() ?? const [];

  List<ActiveTask> get allActive => [
        for (final section in sections)
          if (section.kind != TaskSectionKind.done &&
              section.kind != TaskSectionKind.other)
            ...section.activeTasks,
      ];

  int get totalRemaining => allActive.length;
  List<DoneTask> get done =>
      sectionOf(TaskSectionKind.done)?.doneTasks.toList() ?? const [];

  TaskDocument copyWith({List<TaskSection>? sections}) => TaskDocument(
        preamble: preamble,
        sections: sections ?? this.sections,
        endsWithNewline: endsWithNewline,
      );
}

String normalizeTaskKey(String text) => text
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
    .replaceAll(RegExp(r'\s+'), ' ');

String taskDateStamp(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
