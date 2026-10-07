import 'dart:io';

import 'package:blitzit_flutter/models/models.dart';
import 'package:blitzit_flutter/providers/persistent_project_provider.dart';
import 'package:blitzit_flutter/providers/persistent_task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

Task _task({String title = 'Plan the launch', int projectId = 1}) => Task(
      id: 0,
      title: title,
      description: 'A task stored in a real, isolated Hive box',
      column: 'Backlog',
      estimatedTime: 50,
      actualTime: 7,
      priority: TaskPriority.high,
      status: TaskStatus.todo,
      dueDate: DateTime(2026, 11, 12, 14, 30),
      tags: ['work', 'launch'],
      estimatedPomodoros: 2,
      reminderEnabled: true,
      reminderOffset: 15,
      isUrgent: true,
      isImportant: true,
      projectId: projectId,
      ownerId: 1,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Project _project({String name = 'Launch project', String color = '#4CAF50'}) =>
    Project(
      id: 0,
      name: name,
      description: 'Launch preparation',
      color: color,
      ownerId: 1,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Durable task and project CRUD', () {
    late Directory directory;
    late PersistentTaskProvider tasks;
    late PersistentProjectProvider projects;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('blitzit-crud-');
      tasks = PersistentTaskProvider();
      projects = PersistentProjectProvider();
      await tasks.initialize(storagePath: directory.path);
      await projects.initialize(storagePath: directory.path);
    });

    tearDown(() async {
      await tasks.dispose();
      await projects.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    });

    test('create, update, reload and delete preserve every task field',
        () async {
      final originalCount = tasks.tasks.length;
      await tasks.createTask(_task());
      final created = tasks.tasks.last;
      expect(tasks.tasks.length, originalCount + 1);
      expect(created.id, greaterThan(0));
      expect(created.title, 'Plan the launch');
      expect(
          Hive.box<Task>('tasks').get(created.id)?.toJson(), created.toJson());
      final revised = created.copyWith(
        title: 'Ship the launch',
        description: 'Revised brief',
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        column: 'In Progress',
        dueDate: DateTime(2026, 12, 15, 9, 45),
        projectId: 2,
        estimatedPomodoros: 4,
        estimatedTime: 100,
        actualTime: 23,
        tags: ['release'],
        isUrgent: false,
        isImportant: false,
        reminderEnabled: false,
        reminderOffset: 0,
      );
      await tasks.updateTask(revised);
      await tasks.loadTasks();
      final restored = tasks.tasks.singleWhere((task) => task.id == created.id);
      expect(restored.title, 'Ship the launch');
      expect(restored.description, 'Revised brief');
      expect(restored.priority, TaskPriority.urgent);
      expect(restored.status, TaskStatus.inProgress);
      expect(restored.column, 'In Progress');
      expect(restored.dueDate, DateTime(2026, 12, 15, 9, 45));
      expect(restored.projectId, 2);
      expect(restored.estimatedPomodoros, 4);
      expect(restored.estimatedTime, 100);
      expect(restored.actualTime, 23);
      expect(restored.tags, ['release']);
      expect(restored.isUrgent, isFalse);
      expect(restored.isImportant, isFalse);
      expect(restored.reminderEnabled, isFalse);
      expect(restored.reminderOffset, 0);
      expect(restored.createdAt, created.createdAt);
      await tasks.deleteTask(created.id);
      await tasks.loadTasks();
      expect(tasks.tasks.where((task) => task.id == created.id), isEmpty);
      expect(Hive.box<Task>('tasks').containsKey(created.id), isFalse);
      expect(tasks.tasks.length, originalCount);
    });

    test('all priority and status enum values round-trip through Hive',
        () async {
      for (final priority in TaskPriority.values) {
        for (final status in TaskStatus.values) {
          await tasks.createTask(_task(title: '${priority.name}/${status.name}')
              .copyWith(priority: priority, status: status));
        }
      }
      await tasks.dispose();
      tasks = PersistentTaskProvider();
      await tasks.initialize(storagePath: directory.path);
      for (final priority in TaskPriority.values) {
        for (final status in TaskStatus.values) {
          final stored = tasks.tasks.singleWhere(
              (task) => task.title == '${priority.name}/${status.name}');
          expect(stored.priority, priority);
          expect(stored.status, status);
        }
      }
    });

    test('moving columns updates status and clears stale completedAt',
        () async {
      await tasks.createTask(_task());
      final id = tasks.tasks.last.id;
      await tasks.moveTaskToColumn(id, 'In Progress');
      expect(tasks.tasks.last.status, TaskStatus.inProgress);
      await tasks.moveTaskToColumn(id, 'Done');
      expect(tasks.tasks.last.status, TaskStatus.completed);
      expect(tasks.tasks.last.completedAt, isNotNull);
      await tasks.moveTaskToColumn(id, 'Today');
      expect(tasks.tasks.last.status, TaskStatus.todo);
      expect(tasks.tasks.last.completedAt, isNull);
      expect(
          tasks.getTasksByColumn('Today').map((task) => task.id), contains(id));
      await tasks.updateTaskUrgencyImportance(id, false, true);
      expect(tasks.tasks.last.isUrgent, isFalse);
      expect(tasks.tasks.last.isImportant, isTrue);
    });

    test('project lookup, selection, edit and deletion remain consistent',
        () async {
      await projects.createProject(_project());
      final created = projects.projects.last;
      projects.selectProject(created.id);
      expect(projects.selectedProjectId, created.id);
      await tasks.createTask(_task(projectId: created.id));
      expect(tasks.getTasksByProject(created.id).single.projectId, created.id);
      await projects.updateProject(Project(
        id: created.id,
        name: 'Renamed launch',
        description: 'Updated description',
        color: '#E91E63',
        ownerId: created.ownerId,
        createdAt: created.createdAt,
        updatedAt: created.updatedAt,
      ));
      await projects.loadProjects();
      expect(projects.getProjectName(created.id), 'Renamed launch');
      expect(projects.getProjectById(created.id)?.description,
          'Updated description');
      expect(projects.getProjectById(created.id)?.color, '#E91E63');
      expect(projects.getProjectById(created.id)?.createdAt, created.createdAt);
      expect(projects.selectedProjectId, created.id);
      await projects.deleteProject(created.id);
      expect(projects.selectedProjectId, isNull);
      expect(projects.getProjectById(created.id), isNull);
      expect(Hive.box<Project>('projects').containsKey(created.id), isFalse);
      expect(projects.getProjectName(created.id), 'Unknown Project');
      expect(projects.getProjectColor(created.id), Colors.grey);
    });

    test('hex colors authored by project dialog render accurately', () async {
      await projects.createProject(_project(color: '#4CAF50'));
      expect(projects.getProjectColor(projects.projects.last.id),
          const Color(0xFF4CAF50));
    });

    test('deleting another project preserves current selection', () async {
      final selected = projects.projects.first.id;
      final other = projects.projects.last.id;
      projects.selectProject(selected);
      await projects.deleteProject(other);
      expect(projects.selectedProjectId, selected);
      projects.selectProject(null);
      expect(projects.selectedProjectId, isNull);
    });

    test('new IDs after reopening never overwrite surviving records', () async {
      await tasks.createTask(_task(title: 'First persistent task'));
      final taskId = tasks.tasks.last.id;
      await projects.createProject(_project(name: 'First persistent project'));
      final projectId = projects.projects.last.id;
      await tasks.dispose();
      await projects.dispose();
      tasks = PersistentTaskProvider();
      projects = PersistentProjectProvider();
      await tasks.initialize(storagePath: directory.path);
      await projects.initialize(storagePath: directory.path);
      await tasks.createTask(_task(title: 'Second persistent task'));
      await projects.createProject(_project(name: 'Second persistent project'));
      expect(tasks.tasks.last.id, greaterThan(taskId));
      expect(projects.projects.last.id, greaterThan(projectId));
      expect(tasks.tasks.singleWhere((task) => task.id == taskId).title,
          'First persistent task');
      expect(projects.getProjectName(projectId), 'First persistent project');
    });

    test('an intentionally empty workspace stays empty after reopening',
        () async {
      for (final id in tasks.tasks.map((task) => task.id).toList()) {
        await tasks.deleteTask(id);
      }
      for (final id
          in projects.projects.map((project) => project.id).toList()) {
        await projects.deleteProject(id);
      }
      await tasks.dispose();
      await projects.dispose();
      tasks = PersistentTaskProvider();
      projects = PersistentProjectProvider();
      await tasks.initialize(storagePath: directory.path);
      await projects.initialize(storagePath: directory.path);
      expect(tasks.tasks, isEmpty,
          reason: 'Deleted demo tasks must not resurrect');
      expect(projects.projects, isEmpty,
          reason: 'Deleted demo projects must not resurrect');
    });

    for (final operation in ['create', 'update', 'delete']) {
      test('failed task $operation leaves the previous state intact', () async {
        final before = tasks.tasks.map((task) => task.toJson()).toList();
        final existing = tasks.tasks.first;
        await Hive.box<Task>('tasks').close();
        final Future<void> action;
        switch (operation) {
          case 'create':
            action = tasks.createTask(_task(title: 'Cannot persist'));
          case 'update':
            action =
                tasks.updateTask(existing.copyWith(title: 'Cannot persist'));
          default:
            action = tasks.deleteTask(existing.id);
        }
        await expectLater(action, throwsA(anything));
        expect(tasks.tasks.map((task) => task.toJson()).toList(), before);
      });
      test('failed project $operation preserves records and selection',
          () async {
        final existing = projects.projects.first;
        projects.selectProject(existing.id);
        final before =
            projects.projects.map((project) => project.toJson()).toList();
        await Hive.box<Project>('projects').close();
        final Future<void> action;
        switch (operation) {
          case 'create':
            action = projects.createProject(_project(name: 'Cannot persist'));
          case 'update':
            action = projects.updateProject(Project(
              id: existing.id,
              name: 'Cannot persist',
              color: existing.color,
              ownerId: existing.ownerId,
              createdAt: existing.createdAt,
              updatedAt: existing.updatedAt,
            ));
          default:
            action = projects.deleteProject(existing.id);
        }
        await expectLater(action, throwsA(anything));
        expect(projects.projects.map((project) => project.toJson()).toList(),
            before);
        expect(projects.selectedProjectId, existing.id);
      });
    }

    for (final deleteAll in [false, true]) {
      test(
          'task IDs stay monotonic after deleting ${deleteAll ? 'all' : 'highest'} and reopening',
          () async {
        await tasks.createTask(_task(title: 'Highest task'));
        final highest = tasks.tasks.last.id;
        final ids =
            deleteAll ? tasks.tasks.map((task) => task.id).toList() : [highest];
        for (final id in ids) {
          await tasks.deleteTask(id);
        }
        await tasks.dispose();
        tasks = PersistentTaskProvider();
        await tasks.initialize(storagePath: directory.path);
        await tasks.createTask(_task(title: 'After deletion'));
        expect(tasks.tasks.last.id, greaterThan(highest));
      });
      test(
          'project IDs stay monotonic after deleting ${deleteAll ? 'all' : 'highest'} and reopening',
          () async {
        await projects.createProject(_project(name: 'Removed project'));
        final removedId = projects.projects.last.id;
        await tasks
            .createTask(_task(title: 'Orphan work', projectId: removedId));
        final ids = deleteAll
            ? projects.projects.map((project) => project.id).toList()
            : [removedId];
        for (final id in ids) {
          await projects.deleteProject(id);
        }
        await projects.dispose();
        projects = PersistentProjectProvider();
        await projects.initialize(storagePath: directory.path);
        await projects.createProject(_project(name: 'Unrelated new project'));
        final newId = projects.projects.last.id;
        expect(newId, greaterThan(removedId));
        expect(tasks.getTasksByProject(newId), isEmpty,
            reason:
                'Deleting a project must never reassign its tasks to a new unrelated project');
        expect(tasks.tasks.last.projectId, removedId);
      });
    }

    test('initialization failures report unavailable storage without fake data',
        () async {
      await tasks.dispose();
      await projects.dispose();
      final blocker = File('${directory.path}/not_a_directory');
      await blocker.writeAsString('Storage failure fixture');
      tasks = PersistentTaskProvider();
      projects = PersistentProjectProvider();
      await tasks.initialize(storagePath: '${blocker.path}/child');
      await projects.initialize(storagePath: '${blocker.path}/child');
      expect(tasks.isInitialized, isFalse);
      expect(tasks.initializationError, isNotNull);
      expect(projects.isInitialized, isFalse);
      expect(projects.initializationError, isNotNull);
      expect(tasks.tasks, isEmpty);
      expect(projects.projects, isEmpty);
      await expectLater(tasks.createTask(_task()), throwsStateError);
      await expectLater(projects.createProject(_project()), throwsStateError);
    });

    test('legacy done status reopens and clears its completion timestamp',
        () async {
      await tasks.createTask(_task().copyWith(
          status: TaskStatus.done,
          column: 'Done',
          completedAt: DateTime(2026, 1, 2)));
      final id = tasks.tasks.last.id;
      await tasks.toggleTaskCompletion(id);
      expect(tasks.tasks.last.status, TaskStatus.todo);
      expect(tasks.tasks.last.completedAt, isNull);
      expect(Hive.box<Task>('tasks').get(id)?.completedAt, isNull);
    });

    test('missing ID metadata backfills from existing task and project records',
        () async {
      await Hive.box<Task>('tasks')
          .put(900, _task(title: 'Legacy task').copyWith(id: 900));
      await Hive.box<Project>('projects').put(
          800,
          Project(
              id: 800,
              name: 'Legacy project',
              color: 'blue',
              ownerId: 1,
              createdAt: DateTime(2025),
              updatedAt: DateTime(2025)));
      await tasks.dispose();
      await projects.dispose();
      await Hive.deleteBoxFromDisk('task_metadata');
      await Hive.deleteBoxFromDisk('project_metadata');
      tasks = PersistentTaskProvider();
      projects = PersistentProjectProvider();
      await tasks.initialize(storagePath: directory.path);
      await projects.initialize(storagePath: directory.path);
      await tasks.createTask(_task());
      await projects.createProject(_project());
      expect(tasks.tasks.last.id, greaterThan(900));
      expect(projects.projects.last.id, greaterThan(800));
      expect(tasks.tasks.singleWhere((task) => task.id == 900).title,
          'Legacy task');
      expect(projects.getProjectName(800), 'Legacy project');
    });

    test('unavailable ID metadata rejects creation without mutating records',
        () async {
      final beforeTasks = tasks.tasks.map((task) => task.toJson()).toList();
      final beforeProjects =
          projects.projects.map((project) => project.toJson()).toList();
      await Hive.box<int>('task_metadata').close();
      await Hive.box<int>('project_metadata').close();
      await expectLater(tasks.createTask(_task()), throwsA(anything));
      await expectLater(projects.createProject(_project()), throwsA(anything));
      expect(tasks.tasks.map((task) => task.toJson()).toList(), beforeTasks);
      expect(projects.projects.map((project) => project.toJson()).toList(),
          beforeProjects);
    });

    test('missing task actions reject without changing any data', () async {
      final before = tasks.tasks.map((task) => task.toJson()).toList();
      await expectLater(tasks.toggleTaskCompletion(-100), throwsStateError);
      await expectLater(tasks.moveTaskToColumn(-100, 'Done'), throwsStateError);
      await expectLater(tasks.updateTaskUrgencyImportance(-100, true, true),
          throwsStateError);
      expect(tasks.tasks.map((task) => task.toJson()).toList(), before);
    });
  });
}
