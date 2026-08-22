import 'task_model.dart';

class TaskParser {
  const TaskParser();

  static final _heading = RegExp(r'^(#{1,6})\s+(.*)$');
  static final _bullet = RegExp(r'^\s*[-*]\s');
  static final _active = RegExp(r'^- \[ \] \*\*(.+?)\*\*(?: — (.*))?$');
  static final _done =
      RegExp(r'^- \[[xX]\] ~~(.+)~~ \((\d{4})-(\d{2})-(\d{2})\)$');
  static final _provenance = RegExp(
    r'^(.*?)(?: — )?added via text from (.+) on (\d{4})-(\d{2})-(\d{2})$',
  );

  TaskDocument parse(String source) {
    final endsWithNewline = source.endsWith('\n');
    final body =
        endsWithNewline ? source.substring(0, source.length - 1) : source;
    final lines = body.isEmpty ? <String>[] : body.split('\n');
    final preamble = <TaskNode>[];
    final sections = <TaskSection>[];
    String? headingRaw;
    String? title;
    TaskSectionKind? kind;
    var nodes = <TaskNode>[];

    void closeSection() {
      if (headingRaw == null) return;
      sections.add(TaskSection(
        headingRaw: headingRaw,
        title: title!,
        kind: kind!,
        nodes: nodes,
      ));
      nodes = <TaskNode>[];
    }

    var inComment = false;
    for (var index = 0; index < lines.length; index++) {
      final raw = lines[index];
      final probe = raw.endsWith('\r') ? raw.substring(0, raw.length - 1) : raw;
      if (inComment) {
        (headingRaw == null ? preamble : nodes).add(TaskRawNode(raw));
        if (probe.contains('-->')) inComment = false;
        continue;
      }
      if (probe.contains('<!--') &&
          !probe.contains('-->', probe.indexOf('<!--'))) {
        inComment = true;
        (headingRaw == null ? preamble : nodes).add(TaskRawNode(raw));
        continue;
      }
      final match = _heading.firstMatch(probe);
      if (match != null && match.group(1)!.length == 2) {
        closeSection();
        headingRaw = raw;
        title = match.group(2)!.trim();
        kind = _kindOf(title);
        continue;
      }
      if (headingRaw == null) {
        preamble.add(TaskRawNode(raw));
      } else if (kind == TaskSectionKind.other) {
        nodes.add(TaskRawNode(raw));
      } else {
        nodes.add(_parseLine(probe, raw: raw, lineNumber: index + 1));
      }
    }
    closeSection();
    return TaskDocument(
      preamble: preamble,
      sections: sections,
      endsWithNewline: endsWithNewline,
    );
  }

  String serialize(TaskDocument document) {
    final lines = <String>[
      for (final node in document.preamble) node.render(),
      for (final section in document.sections) ...[
        section.headingRaw,
        for (final node in section.nodes) node.render(),
      ],
    ];
    final body = lines.join('\n');
    return document.endsWithNewline ? '$body\n' : body;
  }

  TaskNode _parseLine(String probe,
      {required String raw, required int lineNumber}) {
    final done = _done.firstMatch(probe);
    if (done != null) {
      return DoneTask(
        title: done.group(1)!,
        date: DateTime(
          int.parse(done.group(2)!),
          int.parse(done.group(3)!),
          int.parse(done.group(4)!),
        ),
        raw: raw,
      );
    }
    final active = _active.firstMatch(probe);
    if (active != null) {
      var context = active.group(2)?.trim();
      String? addedBy;
      DateTime? addedDate;
      if (context != null) {
        final provenance = _provenance.firstMatch(context);
        if (provenance != null) {
          context = provenance.group(1)!.trim();
          if (context.isEmpty) context = null;
          addedBy = provenance.group(2)!.trim();
          addedDate = DateTime(
            int.parse(provenance.group(3)!),
            int.parse(provenance.group(4)!),
            int.parse(provenance.group(5)!),
          );
        }
      }
      return ActiveTask(
        title: active.group(1)!,
        context: context,
        addedBy: addedBy,
        addedDate: addedDate,
        raw: raw,
      );
    }
    if (_bullet.hasMatch(probe)) {
      throw TaskParseException(
        'Bullet in a task section matches no known active/done form',
        lineNumber: lineNumber,
        line: raw,
      );
    }
    return TaskRawNode(raw);
  }

  static TaskSectionKind _kindOf(String title) => switch (title.toLowerCase()) {
        'family tasks' => TaskSectionKind.family,
        'open tasks' => TaskSectionKind.open,
        'waiting on' => TaskSectionKind.waiting,
        'someday / maybe' => TaskSectionKind.someday,
        'done' => TaskSectionKind.done,
        _ => TaskSectionKind.other,
      };
}
