import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:blitzit_flutter/models/models.dart';
import 'package:blitzit_flutter/providers/persistent_task_provider.dart';
import 'package:blitzit_flutter/providers/persistent_project_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Tasks, completed status, actual minutes and projects survive reopening',
      () async {
    final directory = await Directory.systemTemp.createTemp('blitzit-test-');
    final first = PersistentTaskProvider();
    await first.initialize(storagePath: directory.path);
    final sampleCount = first.tasks.length;
    await first.loadTasks();
    expect(first.tasks.length, sampleCount,
        reason: 'Initial seed must not disappear on reload');
    await first.createTask(first.tasks.first
        .copyWith(title: 'Persisted focus task', actualTime: 12));
    final saved = first.tasks.last;
    await first.toggleTaskCompletion(saved.id);
    await first.dispose();
    final second = PersistentTaskProvider();
    await second.initialize(storagePath: directory.path);
    final restored = second.tasks.singleWhere((task) => task.id == saved.id);
    expect(restored.title, 'Persisted focus task');
    expect(restored.actualTime, 12);
    expect(restored.status, TaskStatus.completed);
    expect(restored.completedAt, isNotNull);
    await second.toggleTaskCompletion(saved.id);
    expect(second.tasks.singleWhere((task) => task.id == saved.id).completedAt,
        isNull);
    await second.dispose();
    final projects = PersistentProjectProvider();
    await projects.initialize(storagePath: directory.path);
    await projects.createProject(Project(
        id: 0,
        name: 'Saved project',
        color: 'green',
        ownerId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()));
    await projects.dispose();
    final reopened = PersistentProjectProvider();
    await reopened.initialize(storagePath: directory.path);
    expect(
        reopened.projects.where((project) => project.name == 'Saved project'),
        hasLength(1));
    await reopened.dispose();
    await directory.delete(recursive: true);
  });
}
