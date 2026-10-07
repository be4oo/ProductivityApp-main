import 'dart:io';
import 'package:blitzit_flutter/companion/companion_app.dart';
import 'package:blitzit_flutter/companion/companion_window.dart';
import 'package:blitzit_flutter/companion/completion_celebration.dart';
import 'package:blitzit_flutter/companion/focus_session.dart';
import 'package:blitzit_flutter/models/models.dart';
import 'package:blitzit_flutter/providers/persistent_project_provider.dart';
import 'package:blitzit_flutter/providers/persistent_task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Finder field(String label) => find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.labelText == label);
Future<void> settle(WidgetTester tester) async {
  // Pump bounded frames: pumpAndSettle can starve real Hive I/O while a
  // CircularProgressIndicator is waiting for the filesystem write.
  for (var pass = 0; pass < 4; pass++) {
    await tester.pump(const Duration(milliseconds: 250));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
  }
  await tester.pump(const Duration(milliseconds: 250));
}

Future<void> choose<T>(WidgetTester tester, String text) async {
  final target = find.byType(DropdownButtonFormField<T>);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await settle(tester);
  await tester.tap(find.text(text).last);
  await settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late PersistentTaskProvider tasks;
  late PersistentProjectProvider projects;
  late FocusSession session;
  late CompanionWindow window;
  late int alphaId;
  late int betaId;
  late DateTime today;
  Future<void> seed(String title,
      {DateTime? due,
      int? projectId,
      TaskStatus status = TaskStatus.todo,
      String column = 'Backlog'}) async {
    await tasks.createTask(Task(
        id: 0,
        title: title,
        column: column,
        estimatedTime: 25,
        actualTime: 0,
        priority: TaskPriority.medium,
        status: status,
        reminderEnabled: false,
        reminderOffset: 0,
        isUrgent: false,
        isImportant: true,
        projectId: projectId ?? alphaId,
        ownerId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dueDate: due,
        completedAt: status == TaskStatus.completed || status == TaskStatus.done
            ? DateTime.now()
            : null));
  }

  Future<void> launch(WidgetTester tester,
      {CompanionMode mode = CompanionMode.planner,
      Size size = const Size(1100, 850)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await window.show(mode);
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<PersistentTaskProvider>.value(value: tasks),
      ChangeNotifierProvider<PersistentProjectProvider>.value(value: projects),
      ChangeNotifierProvider<FocusSession>.value(value: session),
      ChangeNotifierProvider<CompanionWindow>.value(value: window),
    ], child: const CompanionApp()));
    await settle(tester);
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('blitzit-workflow-');
    tasks = PersistentTaskProvider();
    projects = PersistentProjectProvider();
    session = FocusSession();
    window = CompanionWindow();
    today = DateUtils.dateOnly(DateTime.now());
    await tasks.initialize(storagePath: directory.path);
    await projects.initialize(storagePath: directory.path);
    for (final id in tasks.tasks.map((t) => t.id).toList()) {
      await tasks.deleteTask(id);
    }
    for (final id in projects.projects.map((p) => p.id).toList()) {
      await projects.deleteProject(id);
    }
    for (final name in ['Alpha project', 'Beta project']) {
      await projects.createProject(Project(
          id: 0,
          name: name,
          color: '#2196F3',
          ownerId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()));
    }
    alphaId = projects.projects.first.id;
    betaId = projects.projects.last.id;
  });
  void workflowTest(
      String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        session.dispose();
        window.dispose();
        // Hive's last write future belongs to the widget fake-time zone. Close
        // while that zone is still alive, pumping until the real files close.
        var closed = false;
        final closing = Future.wait([tasks.dispose(), projects.dispose()]);
        closing.then((_) => closed = true);
        for (var pass = 0; !closed && pass < 100; pass++) {
          await tester.pump();
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 10)));
        }
        expect(closed, isTrue,
            reason: 'Temporary Hive boxes must close before fake time ends');
        await closing;
        await tester.runAsync(() async {
          await Hive.close();
          await directory.delete(recursive: true);
        });
      }
    });
  }

  workflowTest('task form validates empty title and Cancel discards changes',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('New task'));
    await settle(tester);
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(find.text('Please enter a task title'), findsOneWidget);
    expect(find.text('Create Task'), findsOneWidget);
    expect(tasks.tasks, isEmpty);
    await tester.enterText(field('Task Title'), 'Unsaved draft');
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Create Task'), findsNothing);
    expect(tasks.tasks, isEmpty);
    await tester.tap(find.text('New task'));
    await settle(tester);
    expect(tester.widget<TextField>(field('Task Title')).controller?.text,
        isEmpty);
    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'create and edit persist title description priority tags and estimate',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('New task'));
    await settle(tester);
    await tester.enterText(field('Task Title'), '  Prepare launch  ');
    await tester.enterText(
        field('Description'), 'A detailed release checklist');
    await choose<TaskPriority>(tester, 'Urgent');
    await choose<TaskStatus>(tester, 'In Progress');
    await tester.ensureVisible(field('Estimated Pomodoros'));
    await tester.enterText(field('Estimated Pomodoros'), '3');
    await tester.ensureVisible(field('Tags (comma-separated)'));
    await tester.enterText(
        field('Tags (comma-separated)'), ' release, work, ,');
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(find.text('Create Task'), findsNothing);
    final created = tasks.tasks.single;
    expect(created.title, 'Prepare launch');
    expect(created.description, 'A detailed release checklist');
    expect(created.priority, TaskPriority.urgent);
    expect(created.status, TaskStatus.inProgress);
    expect(created.tags, ['release', 'work']);
    expect(created.estimatedPomodoros, 3);
    expect(created.estimatedTime, 75);
    expect(DateUtils.dateOnly(created.dueDate!), today);
    expect(Hive.box<Task>('tasks').get(created.id)?.title, 'Prepare launch');
    await tester.tap(find.text('Prepare launch'));
    await settle(tester);
    expect(find.text('Edit Task'), findsOneWidget);
    await tester.enterText(field('Task Title'), 'Launch is ready');
    await choose<TaskPriority>(tester, 'Low');
    await tester.tap(find.text('Update'));
    await settle(tester);
    expect(tasks.tasks.single.id, created.id);
    expect(tasks.tasks.single.title, 'Launch is ready');
    expect(tasks.tasks.single.priority, TaskPriority.low);
    expect(Hive.box<Task>('tasks').get(created.id)?.title, 'Launch is ready');
    expect(tester.takeException(), isNull);
  });

  workflowTest('project filter preselects project and task can be reassigned',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('Beta project'));
    await settle(tester);
    await tester.tap(find.text('New task'));
    await settle(tester);
    await tester.enterText(field('Task Title'), 'Beta work');
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(tasks.tasks.single.projectId, betaId);
    await tester.tap(find.text('Beta work'));
    await settle(tester);
    await choose<int>(tester, 'Alpha project');
    await tester.tap(find.text('Update'));
    await settle(tester);
    expect(tasks.tasks.single.projectId, alphaId);
    expect(find.text('Beta work'), findsNothing);
    await tester.tap(find.text('Alpha project').first);
    await settle(tester);
    expect(find.text('Beta work'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  workflowTest('day arrows filter dates and creation uses displayed day',
      (tester) async {
    await tester.runAsync(() async {
      await seed('Today work', due: today);
      await seed('Tomorrow work', due: today.add(const Duration(days: 1)));
      await seed('Yesterday work',
          due: today.subtract(const Duration(days: 1)));
      await seed('Explicit Today work', column: 'Today');
      await seed('Unscheduled work');
      await seed('Already done', due: today, status: TaskStatus.done);
      await seed('Cancelled work', due: today, status: TaskStatus.cancelled);
    });
    await launch(tester);
    expect(find.text('Today work'), findsOneWidget);
    expect(find.text('Explicit Today work'), findsOneWidget);
    for (final title in [
      'Tomorrow work',
      'Yesterday work',
      'Unscheduled work',
      'Already done',
      'Cancelled work'
    ]) {
      expect(find.text(title), findsNothing);
    }
    await tester.tap(find.byTooltip('Next day'));
    await settle(tester);
    expect(find.text('Tomorrow work'), findsOneWidget);
    expect(find.text('Today work'), findsNothing);
    expect(find.text('Explicit Today work'), findsNothing);
    await tester.tap(find.text('New task'));
    await settle(tester);
    await tester.enterText(field('Task Title'), 'New tomorrow task');
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(DateUtils.dateOnly(tasks.tasks.last.dueDate!),
        today.add(const Duration(days: 1)));
    expect(find.text('New tomorrow task'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous day'));
    await settle(tester);
    await tester.tap(find.byTooltip('Previous day'));
    await settle(tester);
    expect(find.text('Yesterday work'), findsOneWidget);
    await tester.tap(find.text('Today').first);
    await settle(tester);
    expect(find.text('Today work'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'All tasks keeps cancelled tasks editable and completed history separate',
      (tester) async {
    await tester.runAsync(() async {
      await seed('Alpha today', due: today);
      await seed('Alpha backlog');
      await seed('Beta backlog', projectId: betaId);
      await seed('Completed task', status: TaskStatus.completed);
      await seed('Done task', status: TaskStatus.done);
      await seed('Cancelled task', status: TaskStatus.cancelled);
    });
    await launch(tester);
    await tester.tap(find.text('All tasks').first);
    await settle(tester);
    for (final title in ['Alpha today', 'Alpha backlog', 'Beta backlog']) {
      expect(find.text(title), findsOneWidget);
    }
    for (final title in ['Completed task', 'Done task']) {
      expect(find.text(title), findsNothing);
    }
    expect(find.text('Cancelled task'), findsOneWidget);
    expect(find.byTooltip('Focus on Cancelled task'), findsNothing);
    await tester.tap(find.text('Alpha project').first);
    await settle(tester);
    expect(find.text('Alpha today'), findsOneWidget);
    expect(find.text('Alpha backlog'), findsOneWidget);
    expect(find.text('Beta backlog'), findsNothing);
    expect(find.byTooltip('Next day'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  workflowTest('due date and time picker changes persist through edit',
      (tester) async {
    await tester
        .runAsync(() => seed('Dated task', due: DateTime(2026, 11, 12, 8)));
    await launch(tester);
    await tester.tap(find.text('All tasks').first);
    await settle(tester);
    await tester.tap(find.text('Dated task'));
    await settle(tester);
    await tester.ensureVisible(find.byIcon(Icons.calendar_today));
    await tester.tap(find.byIcon(Icons.calendar_today));
    await settle(tester);
    await tester.tap(find.byTooltip('Switch to input'));
    await settle(tester);
    final dateInput = find.descendant(
        of: find.byType(DatePickerDialog), matching: find.byType(TextField));
    await tester.enterText(dateInput, '12/15/2026');
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tester.ensureVisible(find.byIcon(Icons.access_time));
    await tester.tap(find.byIcon(Icons.access_time));
    await settle(tester);
    await tester.tap(find.byTooltip('Switch to text input mode'));
    await settle(tester);
    final timeInputs = find.descendant(
        of: find.byType(TimePickerDialog), matching: find.byType(TextField));
    await tester.enterText(timeInputs.at(0), '9');
    await tester.enterText(timeInputs.at(1), '45');
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tester.tap(find.text('Update'));
    await settle(tester);
    expect(tasks.tasks.single.dueDate, DateTime(2026, 12, 15, 9, 45));
    expect(Hive.box<Task>('tasks').get(tasks.tasks.single.id)?.dueDate,
        DateTime(2026, 12, 15, 9, 45));
    expect(tester.takeException(), isNull);
  });

  workflowTest('task completion and reopen are durable from planner',
      (tester) async {
    await tester.runAsync(() => seed('Finish and reopen', due: today));
    await launch(tester);
    final id = tasks.tasks.single.id;
    await tester.tap(find.byTooltip('Complete Finish and reopen'));
    await settle(tester);
    expect(tasks.tasks.single.status, TaskStatus.completed);
    expect(Hive.box<Task>('tasks').get(id)?.status, TaskStatus.completed);
    expect(find.text('Finish and reopen'), findsNothing);
    await tester.tap(find.text('Completed').first);
    await settle(tester);
    expect(find.text('Finish and reopen'), findsOneWidget);
    await tester.tap(find.byTooltip('Reopen Finish and reopen'));
    await settle(tester);
    expect(tasks.tasks.single.status, TaskStatus.todo);
    expect(tasks.tasks.single.completedAt, isNull);
    expect(Hive.box<Task>('tasks').get(id)?.completedAt, isNull);
    await tester.tap(find.text('Today').first);
    await settle(tester);
    expect(find.text('Finish and reopen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  workflowTest('delete task removes it from planner and Hive', (tester) async {
    await tester.runAsync(() => seed('Remove this task', due: today));
    await launch(tester);
    final id = tasks.tasks.single.id;
    await tester.tap(find.byTooltip('Task actions').first);
    await settle(tester);
    await tester.tap(find.text('Delete task').last);
    await settle(tester);
    if (find.byType(AlertDialog).evaluate().isNotEmpty) {
      await tester.tap(find.widgetWithText(FilledButton, 'Delete task').last);
      await settle(tester);
    }
    expect(tasks.tasks, isEmpty);
    expect(Hive.box<Task>('tasks').containsKey(id), isFalse);
    expect(find.text('Remove this task'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'project create validates name and persists to project navigation',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('New project'));
    await settle(tester);
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(find.text('Please enter a project name'), findsOneWidget);
    await tester.enterText(field('Project Name'), '  Gamma project  ');
    await tester.enterText(field('Description'), 'Gamma description');
    await tester.tap(find.text('Create'));
    await settle(tester);
    final project =
        projects.projects.singleWhere((p) => p.name == 'Gamma project');
    expect(project.description, 'Gamma description');
    expect(
        Hive.box<Project>('projects').get(project.id)?.name, 'Gamma project');
    expect(find.text('Gamma project'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  workflowTest('project edit and delete retain tasks without orphan selection',
      (tester) async {
    await tester
        .runAsync(() => seed('Keep my task', projectId: betaId, due: today));
    await launch(tester);
    await tester.tap(find.byTooltip('Project actions for Beta project'));
    await settle(tester);
    await tester.tap(find.text('Edit project'));
    await settle(tester);
    await tester.enterText(field('Project Name'), 'Renamed beta');
    await tester.tap(find.text('Update'));
    await settle(tester);
    expect(projects.getProjectName(betaId), 'Renamed beta');
    await tester.tap(find.text('Renamed beta').first);
    await settle(tester);
    await tester.tap(find.byTooltip('Project actions for Renamed beta'));
    await settle(tester);
    await tester.tap(find.text('Delete project').last);
    await settle(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete project').last);
    await settle(tester);
    expect(projects.getProjectById(betaId), isNull);
    expect(projects.selectedProjectId, isNull);
    expect(tasks.tasks.single.title, 'Keep my task');
    expect(tasks.tasks.single.projectId, betaId);
    expect(
        Hive.box<Task>('tasks').get(tasks.tasks.single.id)?.projectId, betaId);
    expect(tester.takeException(), isNull);
  });

  workflowTest('keyboard planner shortcut and Escape preserve focus session',
      (tester) async {
    await tester.runAsync(() => seed('Keyboard focus', due: today));
    await launch(tester, mode: CompanionMode.expanded);
    await tester.tap(find.byTooltip('Focus on Keyboard focus'));
    await tester.pump();
    final selectedId = session.taskId;
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await settle(tester);
    expect(window.mode, CompanionMode.planner);
    expect(session.taskId, selectedId);
    expect(session.isRunning, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(window.mode, CompanionMode.compact);
    expect(session.taskId, selectedId);
    expect(session.isRunning, isTrue);
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'failed task create stays open with entered text and retry error',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('New task'));
    await settle(tester);
    await tester.enterText(field('Task Title'), 'Keep this unsaved task');
    await tester.runAsync(() => Hive.box<Task>('tasks').close());
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(find.text('Create Task'), findsOneWidget);
    expect(find.text('Keep this unsaved task'), findsOneWidget);
    expect(find.text('Task wasn’t saved. Please try again.'), findsOneWidget);
    expect(tasks.tasks, isEmpty);
    expect(tester.takeException(), isNull);
  });

  workflowTest('failed project create stays open without false success',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('New project'));
    await settle(tester);
    await tester.enterText(field('Project Name'), 'Keep this unsaved project');
    await tester.runAsync(() => Hive.box<Project>('projects').close());
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(find.text('Create Project'), findsOneWidget);
    expect(find.text('Keep this unsaved project'), findsOneWidget);
    expect(
        find.text('Project wasn’t saved. Please try again.'), findsOneWidget);
    expect(projects.projects, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  workflowTest('failed completion keeps task visible and never celebrates',
      (tester) async {
    await tester.runAsync(() => seed('Unsaved completion', due: today));
    await launch(tester);
    await tester.runAsync(() => Hive.box<Task>('tasks').close());
    await tester.tap(find.byTooltip('Complete Unsaved completion'));
    await settle(tester);
    expect(tasks.tasks.single.status, TaskStatus.todo);
    expect(find.text('Unsaved completion'), findsOneWidget);
    expect(find.text('Task could not be saved. Please try again.'),
        findsOneWidget);
    expect(find.byType(CompletionCelebration), findsNothing);
    expect(tester.takeException(), isNull);
  });

  workflowTest('narrow planner filters projects through its dropdown',
      (tester) async {
    await tester.runAsync(() async {
      await seed('Narrow Alpha');
      await seed('Narrow Beta', projectId: betaId);
    });
    await launch(tester, size: const Size(600, 820));
    final filter = find.byType(DropdownButton<int>);
    await tester.tap(filter);
    await settle(tester);
    await tester.tap(find.text('All tasks').last);
    await settle(tester);
    expect(find.text('Narrow Alpha'), findsOneWidget);
    expect(find.text('Narrow Beta'), findsOneWidget);
    await tester.tap(filter);
    await settle(tester);
    await tester.tap(find.text('Beta project').last);
    await settle(tester);
    expect(find.text('Narrow Alpha'), findsNothing);
    expect(find.text('Narrow Beta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  workflowTest('repeated Create taps produce one durable task', (tester) async {
    await launch(tester);
    await tester.tap(find.text('New task'));
    await settle(tester);
    await tester.enterText(field('Task Title'), 'Single submission');
    await tester.tap(find.text('Create'));
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(tasks.tasks, hasLength(1));
    expect(
        Hive.box<Task>('tasks')
            .values
            .where((task) => task.title == 'Single submission'),
        hasLength(1));
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'local command shortcut starts focus and finish persists completion',
      (tester) async {
    await tester.runAsync(() => seed('Command task', due: today));
    await launch(tester);
    final id = tasks.tasks.single.id;
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await settle(tester);
    expect(find.text('Local task command'), findsOneWidget);
    await tester.enterText(field('Command'), 'start $id');
    await tester.tap(find.text('Run command'));
    await settle(tester);
    expect(find.text('Local task command'), findsNothing);
    expect(session.taskId, id);
    expect(session.isRunning, isTrue);
    await tester.tap(find.text('Local commands'));
    await settle(tester);
    await tester.enterText(field('Command'), 'finish $id');
    await tester.tap(find.text('Run command'));
    await settle(tester);
    expect(find.text('Local task command'), findsNothing);
    expect(tasks.tasks.single.status, TaskStatus.completed);
    expect(Hive.box<Task>('tasks').get(id)?.status, TaskStatus.completed);
    expect(session.taskId, isNull);
    expect(session.isRunning, isFalse);
    expect(tester.takeException(), isNull);
  });

  workflowTest('local commands reject malformed missing and closed task IDs',
      (tester) async {
    await tester
        .runAsync(() => seed('Closed command task', status: TaskStatus.done));
    await launch(tester);
    final id = tasks.tasks.single.id;
    await tester.tap(find.text('Local commands'));
    await settle(tester);
    for (final entry in {
      'erase 1': 'Use start <task ID> or finish <task ID>',
      'start 99999999': 'No task has that ID',
      'start $id': 'Choose an open task',
    }.entries) {
      await tester.enterText(field('Command'), entry.key);
      await tester.tap(find.text('Run command'));
      await settle(tester);
      expect(find.text(entry.value), findsOneWidget);
      expect(find.text('Local task command'), findsOneWidget);
      expect(session.taskId, isNull);
      expect(tasks.tasks.single.status, TaskStatus.done);
    }
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Local task command'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'failed local finish preserves open task and displays retry error',
      (tester) async {
    await tester.runAsync(() => seed('Unsaved command task', due: today));
    await launch(tester);
    final id = tasks.tasks.single.id;
    await tester.runAsync(() => Hive.box<Task>('tasks').close());
    await tester.tap(find.text('Local commands'));
    await settle(tester);
    await tester.enterText(field('Command'), 'finish $id');
    await tester.tap(find.text('Run command'));
    await settle(tester);
    expect(find.text('Task could not be saved. Please try again.'),
        findsOneWidget);
    expect(find.text('Local task command'), findsOneWidget);
    expect(tasks.tasks.single.status, TaskStatus.todo);
    expect(find.byType(CompletionCelebration), findsNothing);
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'expanded companion creates a real task at its native window size',
      (tester) async {
    await launch(tester,
        mode: CompanionMode.expanded, size: const Size(420, 540));
    await tester.tap(find.byTooltip('Add task'));
    await settle(tester);
    await tester.enterText(field('Task Title'), 'Native-size task');
    await choose<TaskPriority>(tester, 'High');
    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(tasks.tasks.single.title, 'Native-size task');
    expect(tasks.tasks.single.priority, TaskPriority.high);
    expect(find.text('Native-size task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'editing status to Done persists completion and reopening preserves fields',
      (tester) async {
    await tester.runAsync(() => seed('Status editor task', due: today));
    await launch(tester);
    final id = tasks.tasks.single.id;
    await tester.tap(find.text('Status editor task'));
    await settle(tester);
    await choose<TaskStatus>(tester, 'Done');
    await tester.tap(find.text('Update'));
    await settle(tester);
    expect(tasks.tasks.single.status, TaskStatus.done);
    expect(tasks.tasks.single.column, 'Done');
    expect(tasks.tasks.single.completedAt, isNotNull);
    expect(Hive.box<Task>('tasks').get(id)?.status, TaskStatus.done);
    await tester.tap(find.text('Completed').first);
    await settle(tester);
    await tester.tap(find.text('Status editor task'));
    await settle(tester);
    await choose<TaskStatus>(tester, 'To Do');
    await tester.tap(find.text('Update'));
    await settle(tester);
    expect(tasks.tasks.single.status, TaskStatus.todo);
    expect(tasks.tasks.single.completedAt, isNull);
    expect(tasks.tasks.single.title, 'Status editor task');
    expect(DateUtils.dateOnly(tasks.tasks.single.dueDate!), today);
    expect(tester.takeException(), isNull);
  });

  workflowTest('Cancel delete keeps task and active focus unchanged',
      (tester) async {
    await tester.runAsync(() => seed('Keep focused task', due: today));
    await launch(tester);
    await tester.tap(find.byTooltip('Focus on Keep focused task'));
    await settle(tester);
    final id = session.taskId;
    await tester.tap(find.byTooltip('Task actions').first);
    await settle(tester);
    await tester.tap(find.text('Delete task').last);
    await settle(tester);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(tasks.tasks.single.id, id);
    expect(Hive.box<Task>('tasks').containsKey(id), isTrue);
    expect(session.taskId, id);
    expect(session.isRunning, isTrue);
    expect(tester.takeException(), isNull);
  });

  workflowTest('failed task deletion preserves task and shows a visible error',
      (tester) async {
    await tester.runAsync(() => seed('Protected task', due: today));
    await launch(tester);
    await tester.runAsync(() => Hive.box<Task>('tasks').close());
    await tester.tap(find.byTooltip('Task actions').first);
    await settle(tester);
    await tester.tap(find.text('Delete task').last);
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete task'));
    await settle(tester);
    expect(tasks.tasks.single.title, 'Protected task');
    expect(find.text('Protected task'), findsOneWidget);
    expect(find.text('Task could not be deleted. Please try again.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'failed project deletion preserves project and its selected tasks',
      (tester) async {
    await tester.runAsync(() => seed('Project task', projectId: betaId));
    await launch(tester);
    await tester.tap(find.text('Beta project').first);
    await settle(tester);
    await tester.runAsync(() => Hive.box<Project>('projects').close());
    await tester.tap(find.byTooltip('Project actions for Beta project'));
    await settle(tester);
    await tester.tap(find.text('Delete project').last);
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete project'));
    await settle(tester);
    expect(projects.getProjectById(betaId), isNotNull);
    expect(projects.selectedProjectId, betaId);
    expect(find.text('Project task'), findsOneWidget);
    expect(find.text('Project could not be deleted. Please try again.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  workflowTest(
      'legacy named project colors remain editable without a format error',
      (tester) async {
    final project = projects.projects.first;
    await tester.runAsync(() => projects.updateProject(Project(
        id: project.id,
        name: project.name,
        color: 'blue',
        ownerId: project.ownerId,
        createdAt: project.createdAt,
        updatedAt: project.updatedAt)));
    await launch(tester);
    await tester.tap(find.byTooltip('Project actions for Alpha project'));
    await settle(tester);
    await tester.tap(find.text('Edit project'));
    await settle(tester);
    expect(find.text('Edit Project'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.enterText(field('Project Name'), 'Edited legacy project');
    await tester.tap(find.text('Update'));
    await settle(tester);
    expect(projects.getProjectName(alphaId), 'Edited legacy project');
    expect(projects.getProjectColor(alphaId), const Color(0xFF2196F3));
    expect(tester.takeException(), isNull);
  });

  for (final cancelEdit in [false, true]) {
    workflowTest(
        cancelEdit
            ? 'Cancel after opening active task editor preserves flushed focus time and original title'
            : 'saving active task editor preserves newly flushed focus time',
        (tester) async {
      const originalTitle = 'Task with unflushed focus';
      await tester.runAsync(() async {
        await seed(originalTitle, due: today);
        await tasks.updateTask(tasks.tasks.single.copyWith(actualTime: 7));
      });
      final id = tasks.tasks.single.id;
      var now = DateTime(2026, 10, 7, 9);
      final loggedMinutes = <int>[];
      session.dispose();
      session = FocusSession(
        now: () => now,
        onMinutesLogged: (taskId, minutes) async {
          final latest = tasks.tasks.singleWhere((task) => task.id == taskId);
          await tasks.updateTask(
              latest.copyWith(actualTime: latest.actualTime + minutes));
          loggedMinutes.add(minutes);
        },
      );
      await launch(tester);
      await tester.tap(find.byTooltip('Focus on $originalTitle'));
      await tester.pump();
      expect(session.isRunning, isTrue);
      expect(session.taskId, id);

      // Advance wall time without pumping the periodic timer. The task row
      // still holds actualTime=7 when its editor starts the pause/flush path.
      now = now.add(const Duration(minutes: 2, seconds: 5));
      expect(loggedMinutes, isEmpty);
      expect(tasks.tasks.single.actualTime, 7);
      expect(Hive.box<Task>('tasks').get(id)?.actualTime, 7);
      await tester.tap(find.text(originalTitle));
      await settle(tester);
      expect(find.text('Edit Task'), findsOneWidget);
      expect(session.isRunning, isFalse);
      expect(loggedMinutes, [2]);
      expect(tasks.tasks.single.actualTime, 9);
      expect(Hive.box<Task>('tasks').get(id)?.actualTime, 9);

      await tester.enterText(field('Task Title'), 'Edited focused task');
      await tester.tap(find.text(cancelEdit ? 'Cancel' : 'Update'));
      await settle(tester);
      expect(find.text('Edit Task'), findsNothing);
      final expectedTitle = cancelEdit ? originalTitle : 'Edited focused task';
      expect(tasks.tasks.single.title, expectedTitle);
      expect(tasks.tasks.single.actualTime, 9,
          reason:
              'Editor actions must never restore a pre-flush task snapshot');
      expect(Hive.box<Task>('tasks').get(id)?.title, expectedTitle);
      expect(Hive.box<Task>('tasks').get(id)?.actualTime, 9);
      expect(loggedMinutes, [2],
          reason: 'Editor actions must not log time twice');
      expect(session.taskId, id);
      expect(tester.takeException(), isNull);
    });
  }
}
