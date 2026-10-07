import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blitzit_flutter/companion/companion_app.dart';
import 'package:blitzit_flutter/companion/companion_window.dart';
import 'package:blitzit_flutter/companion/completion_celebration.dart';
import 'package:blitzit_flutter/companion/focus_session.dart';
import 'package:blitzit_flutter/providers/persistent_task_provider.dart';
import 'package:blitzit_flutter/providers/persistent_project_provider.dart';
import 'package:blitzit_flutter/models/models.dart';
import 'widget_test.dart' as fixtures;

class CompletionTasks extends PersistentTaskProvider {
  final items = [
    fixtures.task(1, column: 'Today'),
    fixtures.task(2, column: 'Today')
  ];
  bool fail = false;
  int calls = 0;
  Completer<void>? pending;
  @override
  List<Task> get tasks => items;
  @override
  Future<void> toggleTaskCompletion(int id) async {
    calls++;
    if (pending != null) await pending!.future;
    if (fail) throw StateError('Storage unavailable');
    items.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}

Future<void> mount(WidgetTester tester, CompletionTasks tasks) async {
  final session = FocusSession();
  final window = CompanionWindow();
  addTearDown(session.dispose);
  await window.show(CompanionMode.expanded);
  await tester.pumpWidget(MultiProvider(providers: [
    ChangeNotifierProvider<PersistentTaskProvider>.value(value: tasks),
    ChangeNotifierProvider<PersistentProjectProvider>.value(
        value: PersistentProjectProvider()),
    ChangeNotifierProvider.value(value: session),
    ChangeNotifierProvider.value(value: window),
  ], child: const CompanionApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'Successful completions celebrate, allow clicks and restart cleanly',
      (tester) async {
    final tasks = CompletionTasks();
    await mount(tester, tasks);
    await tester.tap(find.byTooltip('Complete Task 1'));
    await tester.pump();
    expect(find.text('Task complete! 🎉'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.byTooltip('Complete Task 2'));
    await tester.pump();
    expect(tasks.calls, 2);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(CompletionCelebration), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(CompletionCelebration), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Failed save stays visible, reports error and never celebrates',
      (tester) async {
    final tasks = CompletionTasks()..fail = true;
    await mount(tester, tasks);
    await tester.tap(find.byTooltip('Complete Task 1'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Complete Task 1'), findsOneWidget);
    expect(find.byType(CompletionCelebration), findsNothing);
    expect(find.text('Task could not be saved. Please try again.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pending completion ignores repeated clicks and safely unmounts',
      (tester) async {
    final pending = Completer<void>();
    final tasks = CompletionTasks()..pending = pending;
    await mount(tester, tasks);
    await tester.tap(find.byTooltip('Complete Task 1'));
    await tester.pump();
    await tester.tap(find.byTooltip('Complete Task 1'));
    await tester.pump();
    expect(tasks.calls, 1);
    expect(find.byType(CompletionCelebration), findsNothing);
    await tester.pumpWidget(const SizedBox());
    pending.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Reduced motion uses a static success message and cancels on dispose',
      (tester) async {
    var complete = 0;
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: CompletionCelebration(onComplete: () => complete++),
    )));
    expect(find.text('Task complete! 🎉'), findsOneWidget);
    expect(find.byKey(const ValueKey('completion-confetti')), findsNothing);
    await tester.pump(const Duration(milliseconds: 1600));
    expect(complete, 1);
    await tester.pumpWidget(
        MaterialApp(home: CompletionCelebration(onComplete: () => complete++)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(complete, 1);
    expect(tester.takeException(), isNull);
  });
}
