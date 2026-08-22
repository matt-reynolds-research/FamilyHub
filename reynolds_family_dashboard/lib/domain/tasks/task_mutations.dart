import 'task_model.dart';

class TaskMutations {
  const TaskMutations();

  TaskMutationOutcome add(
    TaskDocument document, {
    required TaskSectionKind sectionKind,
    required String title,
    String? context,
    String? addedBy,
    DateTime? addedDate,
  }) {
    if (sectionKind != TaskSectionKind.open &&
        sectionKind != TaskSectionKind.family) {
      return TaskMutationOutcome.rejected(
          'Tasks can only be added to Open or Family Tasks.', document);
    }
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return TaskMutationOutcome.rejected('Nothing to add.', document);
    }
    if (document.allActive
        .any((task) => task.dedupKey == normalizeTaskKey(trimmed))) {
      return TaskMutationOutcome.rejected(
          'Already on your list: $trimmed', document);
    }
    final section = _requireSection(document, sectionKind);
    final task = ActiveTask(
      title: trimmed,
      context: context?.trim().isEmpty ?? true ? null : context!.trim(),
      addedBy: addedBy,
      addedDate: addedDate,
    );
    final nodes = [...section.nodes]..insert(_appendIndex(section.nodes), task);
    final label =
        sectionKind == TaskSectionKind.family ? 'Family Tasks' : 'Open Tasks';
    return TaskMutationOutcome.applied(
      'Added to $label: $trimmed',
      _replaceSection(document, section.copyWith(nodes: nodes)),
    );
  }

  TaskMutationOutcome complete(
    TaskDocument document, {
    required String title,
    DateTime? today,
  }) {
    final key = normalizeTaskKey(title);
    final matches = <(TaskSection, ActiveTask)>[
      for (final section in document.sections)
        if (section.kind != TaskSectionKind.done &&
            section.kind != TaskSectionKind.other)
          for (final task in section.activeTasks)
            if (task.dedupKey == key) (section, task),
    ];
    if (matches.isEmpty) {
      return TaskMutationOutcome.rejected(
        'Couldn\'t find an open task matching "$title".',
        document,
      );
    }
    if (matches.length > 1) {
      return TaskMutationOutcome.rejected(
          'Found multiple matching tasks. Be more specific.', document);
    }
    final match = matches.single;
    final sourceNodes = [...match.$1.nodes]..remove(match.$2);
    var next = _replaceSection(document, match.$1.copyWith(nodes: sourceNodes));
    final doneSection = _requireSection(next, TaskSectionKind.done);
    final now = today ?? DateTime.now();
    final doneNodes = [...doneSection.nodes]..insert(
        _appendIndex(doneSection.nodes),
        DoneTask(
            title: match.$2.title,
            date: DateTime(now.year, now.month, now.day)),
      );
    next = _replaceSection(next, doneSection.copyWith(nodes: doneNodes));
    return TaskMutationOutcome.applied('Checked off: ${match.$2.title}', next);
  }

  static int _appendIndex(List<TaskNode> nodes) {
    for (var index = nodes.length - 1; index >= 0; index--) {
      if (nodes[index] is ActiveTask || nodes[index] is DoneTask) {
        return index + 1;
      }
    }
    for (var index = nodes.length - 1; index >= 0; index--) {
      if (nodes[index].render().trim().isNotEmpty) return index + 1;
    }
    return nodes.length;
  }

  static TaskSection _requireSection(
      TaskDocument document, TaskSectionKind kind) {
    final section = document.sectionOf(kind);
    if (section == null) throw StateError('TASKS.md has no "$kind" section.');
    return section;
  }

  static TaskDocument _replaceSection(
          TaskDocument document, TaskSection replacement) =>
      document.copyWith(sections: [
        for (final section in document.sections)
          if (section.kind == replacement.kind) replacement else section,
      ]);
}

class TaskMutationOutcome {
  const TaskMutationOutcome._(this.applied, this.message, this.document);
  factory TaskMutationOutcome.applied(String message, TaskDocument document) =>
      TaskMutationOutcome._(true, message, document);
  factory TaskMutationOutcome.rejected(String message, TaskDocument document) =>
      TaskMutationOutcome._(false, message, document);
  final bool applied;
  final String message;
  final TaskDocument document;
}
