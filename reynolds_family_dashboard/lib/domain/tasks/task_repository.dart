import 'package:flutter/services.dart' show rootBundle;

import 'task_model.dart';
import 'task_parser.dart';

abstract interface class TaskRepository {
  Future<TaskDocument> load();
  Future<void> save(TaskDocument document);
}

class FixtureTaskRepository implements TaskRepository {
  FixtureTaskRepository({
    this.assetPath = 'assets/fixtures/tasks_seed.md',
    this.parser = const TaskParser(),
    Future<String> Function(String key)? loadAsset,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  final String assetPath;
  final TaskParser parser;
  final Future<String> Function(String key) _loadAsset;
  String? _workingCopy;

  @override
  Future<TaskDocument> load() async {
    final source = _workingCopy ??= await _loadAsset(assetPath);
    return parser.parse(source);
  }

  @override
  Future<void> save(TaskDocument document) async {
    _workingCopy = parser.serialize(document);
  }

  String? get workingCopy => _workingCopy;
}
