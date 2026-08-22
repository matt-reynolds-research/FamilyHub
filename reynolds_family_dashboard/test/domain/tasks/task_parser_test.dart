import 'package:flutter_test/flutter_test.dart';
import 'package:reynolds_family_dashboard/domain/tasks/task_model.dart';
import 'package:reynolds_family_dashboard/domain/tasks/task_parser.dart';

const source = '''# Tasks

<!-- inert
- [ ] **Example** — context
-->

## Family Tasks

- [ ] **Plan dinner** — choose tacos — added via text from Sara on 2026-08-20

## Open Tasks

- [ ] **Return books** — added via text from Matt on 2026-08-21

## Waiting On

- [ ] **School list** — teacher email

## Someday / Maybe

- [ ] **Paint room**

## Done

- [x] ~~Replace bulb~~ (2026-08-20)
''';

void main() {
  const parser = TaskParser();

  test('round-trips the whole task file byte-exactly', () {
    expect(parser.serialize(parser.parse(source)), source);
  });

  test('parses title, context, author, date, sections, and Done', () {
    final document = parser.parse(source);
    final task = document.activeTasks(TaskSectionKind.family).single;
    expect(task.title, 'Plan dinner');
    expect(task.context, 'choose tacos');
    expect(task.addedBy, 'Sara');
    expect(task.addedDate, DateTime(2026, 8, 20));
    expect(document.totalRemaining, 4);
    expect(document.done.single.title, 'Replace bulb');
  });

  test('comment example bullets are inert', () {
    expect(parser.parse(source).allActive.map((task) => task.title),
        isNot(contains('Example')));
  });

  test('fails loud on an unknown bullet in a known section', () {
    final malformed = source.replaceFirst(
      '- [ ] **Return books** — added via text from Matt on 2026-08-21',
      '- Return books',
    );
    expect(() => parser.parse(malformed), throwsA(isA<TaskParseException>()));
  });

  test('preserves files without a trailing newline', () {
    final noNewline = source.substring(0, source.length - 1);
    expect(parser.serialize(parser.parse(noNewline)), noNewline);
  });
}
