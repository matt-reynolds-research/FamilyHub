import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/tasks/task_model.dart';
import '../../domain/tasks/task_mutations.dart';
import '../../domain/tasks/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FixtureTaskRepository();
});

final taskControllerProvider =
    AsyncNotifierProvider<TaskController, TaskDocument>(TaskController.new);

/// Session-state seam for Tasks. Document transforms stay in [TaskMutations]
/// so touch and the Phase-3c Assistant Bar can share identical behavior.
class TaskController extends AsyncNotifier<TaskDocument> {
  static const _mutations = TaskMutations();

  @override
  Future<TaskDocument> build() => ref.watch(taskRepositoryProvider).load();

  Future<TaskMutationOutcome> add({
    required TaskSectionKind section,
    required String title,
    String? context,
  }) async {
    final outcome = _mutations.add(
      state.requireValue,
      sectionKind: section,
      title: title,
      context: context,
      addedBy: 'FamilyHub',
      addedDate: DateTime.now(),
    );
    if (outcome.applied) await _persist(outcome.document);
    return outcome;
  }

  Future<TaskMutationOutcome> complete(ActiveTask task) async {
    final outcome = _mutations.complete(
      state.requireValue,
      title: task.title,
    );
    if (outcome.applied) await _persist(outcome.document);
    return outcome;
  }

  Future<void> _persist(TaskDocument document) async {
    await ref.read(taskRepositoryProvider).save(document);
    state = AsyncData(document);
  }
}
