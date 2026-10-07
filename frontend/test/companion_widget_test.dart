import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blitzit_flutter/companion/companion_app.dart';
import 'package:blitzit_flutter/companion/companion_window.dart';
import 'package:blitzit_flutter/companion/focus_session.dart';
import 'package:blitzit_flutter/providers/persistent_task_provider.dart';
import 'package:blitzit_flutter/providers/persistent_project_provider.dart';
import 'package:blitzit_flutter/models/models.dart';

class Tasks extends PersistentTaskProvider {
  final List<Task> items = [];
  @override
  List<Task> get tasks => items;
  @override
  Future<void> toggleTaskCompletion(int id) async {
    items.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}

void main() {
  testWidgets('Task editor fits expanded companion and closes cleanly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 540);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final session = FocusSession();
    final window = CompanionWindow();
    await window.show(CompanionMode.expanded);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PersistentTaskProvider>.value(value: Tasks()),
          ChangeNotifierProvider<PersistentProjectProvider>.value(
            value: PersistentProjectProvider(),
          ),
          ChangeNotifierProvider.value(value: session),
          ChangeNotifierProvider.value(value: window),
        ],
        child: const CompanionApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    expect(find.text('Create Task'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Create Task'), findsNothing);
    expect(find.text('Today'), findsOneWidget);
    session.dispose();
  });
  testWidgets(
    'Expand, planner, collapse and repeat preserve the same session',
    (tester) async {
      final tasks = Tasks();
      tasks.items.add(
        Task(
          id: 1,
          title: 'Write the first chapter',
          column: 'Today',
          estimatedTime: 25,
          actualTime: 0,
          priority: TaskPriority.medium,
          status: TaskStatus.todo,
          reminderEnabled: false,
          reminderOffset: 0,
          isUrgent: false,
          isImportant: true,
          projectId: 1,
          ownerId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      final session = FocusSession();
      final window = CompanionWindow();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PersistentTaskProvider>.value(value: tasks),
            ChangeNotifierProvider<PersistentProjectProvider>.value(
              value: PersistentProjectProvider(),
            ),
            ChangeNotifierProvider.value(value: session),
            ChangeNotifierProvider.value(value: window),
          ],
          child: const CompanionApp(),
        ),
      );
      await tester.tap(find.byTooltip('Expand companion'));
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
      await tester.tap(find.byTooltip('Focus on Write the first chapter'));
      await tester.pump();
      expect(session.isRunning, true);
      await tester.tap(find.text('Open planner'));
      await tester.pumpAndSettle();
      expect(find.text('Your day, in focus.'), findsOneWidget);
      expect(session.taskId, 1);
      await tester.tap(find.byTooltip('Return to companion'));
      await tester.pumpAndSettle();
      expect(session.isRunning, true);
      await tester.tap(find.byTooltip('Expand companion'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Complete Write the first chapter'));
      await tester.pumpAndSettle();
      expect(session.taskId, null);
      expect(find.textContaining('A clear day.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      session.dispose();
    },
  );
}
