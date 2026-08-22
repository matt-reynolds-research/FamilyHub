import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/tasks/task_model.dart';
import '../../theme/hub_tokens.dart';
import 'task_controller.dart';

class TaskFocusView extends ConsumerStatefulWidget {
  const TaskFocusView({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  ConsumerState<TaskFocusView> createState() => _TaskFocusViewState();
}

class _TaskFocusViewState extends ConsumerState<TaskFocusView> {
  final _titleController = TextEditingController();
  TaskSectionKind _addTarget = TaskSectionKind.open;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskControllerProvider);
    return Container(
      padding: const EdgeInsets.all(HubSpace.margin),
      decoration: BoxDecoration(
        color: HubColors.raised,
        borderRadius: BorderRadius.circular(HubRadii.screen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(onBack: widget.onBack, tasks: tasks),
          const SizedBox(height: HubSpace.gap),
          Expanded(
            child: tasks.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: HubColors.accentTasks),
              ),
              error: (error, _) => Center(
                child: Text('Couldn\'t load Tasks\n$error',
                    style: HubType.bodySecondary, textAlign: TextAlign.center),
              ),
              data: (document) => _TaskBoard(
                document: document,
                controller: _titleController,
                addTarget: _addTarget,
                onTargetChanged: (value) => setState(() => _addTarget = value),
                onAdd: _add,
                onComplete: _complete,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final outcome = await ref.read(taskControllerProvider.notifier).add(
          section: _addTarget,
          title: _titleController.text,
        );
    if (!mounted) return;
    if (outcome.applied) _titleController.clear();
    _message(outcome.message, outcome.applied);
  }

  Future<void> _complete(ActiveTask task) async {
    final outcome =
        await ref.read(taskControllerProvider.notifier).complete(task);
    if (!mounted) return;
    _message(outcome.message, outcome.applied);
  }

  void _message(String message, bool success) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? HubColors.raised : HubColors.error,
        behavior: SnackBarBehavior.floating,
      ));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.tasks});
  final VoidCallback onBack;
  final AsyncValue<TaskDocument> tasks;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(HubRadii.tile),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: HubSpace.sm, vertical: HubSpace.xs),
              child: Row(children: [
                Icon(Icons.chevron_left, color: HubColors.textSecondary),
                Text('Home', style: HubType.bodySecondary),
              ]),
            ),
          ),
          const SizedBox(width: HubSpace.tile),
          const Icon(Icons.checklist_rounded,
              color: HubColors.accentTasks, size: 22),
          const SizedBox(width: 10),
          const Text('Tasks', style: HubType.keyNumber),
          const Spacer(),
          Text(
            tasks.when(
              data: (document) => '${document.totalRemaining} remaining',
              loading: () => 'Loading…',
              error: (_, __) => 'Unavailable',
            ),
            style: HubType.bodySecondary,
          ),
        ],
      );
}

class _TaskBoard extends StatelessWidget {
  const _TaskBoard({
    required this.document,
    required this.controller,
    required this.addTarget,
    required this.onTargetChanged,
    required this.onAdd,
    required this.onComplete,
  });

  final TaskDocument document;
  final TextEditingController controller;
  final TaskSectionKind addTarget;
  final ValueChanged<TaskSectionKind> onTargetChanged;
  final VoidCallback onAdd;
  final ValueChanged<ActiveTask> onComplete;

  @override
  Widget build(BuildContext context) {
    final family = document.activeTasks(TaskSectionKind.family);
    final open = document.activeTasks(TaskSectionKind.open);
    final waiting = document.activeTasks(TaskSectionKind.waiting);
    final someday = document.activeTasks(TaskSectionKind.someday);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Counts(document: document),
        const SizedBox(height: HubSpace.gap),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: _TaskSection(
                  title: 'Family Tasks', tasks: family, onComplete: onComplete),
            ),
            const SizedBox(width: HubSpace.zone),
            Container(width: 1, color: HubColors.hairline),
            const SizedBox(width: HubSpace.zone),
            Expanded(
              child: _TaskSection(
                  title: 'Open Tasks', tasks: open, onComplete: onComplete),
            ),
          ]),
        ),
        if (waiting.isNotEmpty || someday.isNotEmpty) ...[
          const SizedBox(height: HubSpace.sm),
          Text(
            'Waiting ${waiting.length}  ·  Someday ${someday.length}',
            style: HubType.caption,
          ),
        ],
        const SizedBox(height: HubSpace.tile),
        Row(children: [
          SegmentedButton<TaskSectionKind>(
            segments: const [
              ButtonSegment(value: TaskSectionKind.open, label: Text('Open')),
              ButtonSegment(
                  value: TaskSectionKind.family, label: Text('Family')),
            ],
            selected: {addTarget},
            onSelectionChanged: (value) => onTargetChanged(value.single),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              foregroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? HubColors.page
                      : HubColors.textSecondary),
              backgroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? HubColors.accentTasks
                      : Colors.transparent),
            ),
          ),
          const SizedBox(width: HubSpace.tile),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onAdd(),
              textInputAction: TextInputAction.done,
              style: HubType.body,
              decoration: InputDecoration(
                hintText: 'Add a task',
                hintStyle: HubType.bodyMuted,
                filled: true,
                fillColor: HubColors.tile,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: HubSpace.tile, vertical: HubSpace.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HubRadii.tile),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: HubSpace.sm),
          IconButton.filled(
            tooltip: 'Add task',
            onPressed: onAdd,
            style: IconButton.styleFrom(
                backgroundColor: HubColors.accentTasks,
                foregroundColor: HubColors.page),
            icon: const Icon(Icons.add),
          ),
        ]),
        const SizedBox(height: HubSpace.sm),
        const Text(
          'Seeded working copy · author shows who added it, not who owns it',
          style: HubType.caption,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _Counts extends StatelessWidget {
  const _Counts({required this.document});
  final TaskDocument document;

  @override
  Widget build(BuildContext context) => Row(children: [
        _Count(
            label: 'Family',
            value: document.activeTasks(TaskSectionKind.family).length),
        _Count(
            label: 'Open',
            value: document.activeTasks(TaskSectionKind.open).length),
        _Count(
            label: 'Waiting',
            value: document.activeTasks(TaskSectionKind.waiting).length),
        _Count(
            label: 'Someday',
            value: document.activeTasks(TaskSectionKind.someday).length),
      ]);
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Text('$label  $value',
            style: HubType.label.copyWith(color: HubColors.textSecondary)),
      );
}

class _TaskSection extends StatelessWidget {
  const _TaskSection(
      {required this.title, required this.tasks, required this.onComplete});
  final String title;
  final List<ActiveTask> tasks;
  final ValueChanged<ActiveTask> onComplete;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$title  · ${tasks.length}', style: HubType.labelPrimary),
          const SizedBox(height: HubSpace.sm),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text('All caught up', style: HubType.bodyMuted))
                : ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) =>
                        Container(height: 1, color: HubColors.hairline),
                    itemBuilder: (_, index) {
                      final task = tasks[index];
                      return InkWell(
                        onTap: () => onComplete(task),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: HubSpace.sm),
                          child: Row(children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: Checkbox(
                                value: false,
                                onChanged: (_) => onComplete(task),
                                side: const BorderSide(
                                    color: HubColors.textMuted, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: HubSpace.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.title, style: HubType.body),
                                  if (task.context != null)
                                    Text(task.context!,
                                        style: HubType.caption,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  Text(_provenance(task),
                                      style: HubType.caption),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
}

String _provenance(ActiveTask task) {
  if (task.addedBy == null || task.addedDate == null) return 'No provenance';
  return 'Added by ${task.addedBy} · ${DateFormat('MMM d').format(task.addedDate!)}';
}
