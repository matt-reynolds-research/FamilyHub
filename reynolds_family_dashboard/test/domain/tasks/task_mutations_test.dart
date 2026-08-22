import 'package:flutter_test/flutter_test.dart';
import 'package:reynolds_family_dashboard/domain/tasks/task_model.dart';
import 'package:reynolds_family_dashboard/domain/tasks/task_mutations.dart';
import 'package:reynolds_family_dashboard/domain/tasks/task_parser.dart';
import 'package:reynolds_family_dashboard/domain/tasks/task_repository.dart';

const source = '''# Tasks

## Family Tasks

- [ ] **Plan dinner** — added via text from Sara on 2026-08-20

## Open Tasks

- [ ] **Return books** — library closes at 5 — added via text from Matt on 2026-08-21

## Waiting On

## Someday / Maybe

## Done

- [x] ~~Replace bulb~~ (2026-08-20)
''';

void main() {
  const parser = TaskParser();
  const mutations = TaskMutations();

  test('add appends exact convention form and preserves unrelated bytes', () {
    final document = parser.parse(source);
    final outcome = mutations.add(
      document,
      sectionKind: TaskSectionKind.family,
      title: 'Pack lunches',
      context: 'before school',
      addedBy: 'Sara',
      addedDate: DateTime(2026, 8, 21),
    );
    expect(outcome.applied, isTrue);
    expect(
      parser.serialize(outcome.document),
      source.replaceFirst(
        '- [ ] **Plan dinner** — added via text from Sara on 2026-08-20',
        '- [ ] **Plan dinner** — added via text from Sara on 2026-08-20\n'
            '- [ ] **Pack lunches** — before school — added via text from Sara on 2026-08-21',
      ),
    );
  });

  test('add dedupes across every active section', () {
    final document = parser.parse(source);
    final outcome = mutations.add(
      document,
      sectionKind: TaskSectionKind.family,
      title: 'Return books',
    );
    expect(outcome.applied, isFalse);
    expect(outcome.document, same(document));
  });

  test('complete relocates to Done and drops annotations', () {
    final document = parser.parse(source);
    final outcome = mutations.complete(
      document,
      title: 'Return books',
      today: DateTime(2026, 8, 21),
    );
    final rendered = parser.serialize(outcome.document);
    expect(rendered, isNot(contains('library closes at 5')));
    expect(rendered, contains('- [x] ~~Return books~~ (2026-08-21)'));
    expect(outcome.document.totalRemaining, document.totalRemaining - 1);
    expect(outcome.document.done.length, document.done.length + 1);
  });

  test('repository saves through serialize and reloads the working copy',
      () async {
    final repository = FixtureTaskRepository(loadAsset: (_) async => source);
    final document = await repository.load();
    final outcome = mutations.complete(document, title: 'Plan dinner');
    await repository.save(outcome.document);
    expect((await repository.load()).done.last.title, 'Plan dinner');
  });
}
